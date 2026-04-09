#!/usr/bin/env bash
# bubblewrap_gemini.sh — run Gemini CLI inside a bubblewrap sandbox.
#
# Usage:
#   bwgemini                        Launch Gemini CLI (default)
#   bubblewrap_gemini.sh -c <cmd>   Run an arbitrary bash command in the sandbox
#
# The sandbox gives read-only access to system paths and write access to:
#   $PWD, ~/.gemini, ~/.npm, ~/.m2, ~/.agents
# SSH agent, D-Bus/GNOME Keyring, GPG, and GitHub CLI auth are forwarded.

# When invoked with no arguments, default to launching gemini.
if [ $# -eq 0 ]; then
  set -- -c "gemini"
fi

# Resolve the repo root relative to this script so skills symlink targets are accessible
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
REPO_SKILLS_BIND=()
[ -d "$REPO_ROOT/skills" ] && REPO_SKILLS_BIND=(--ro-bind "$REPO_ROOT/skills" "$REPO_ROOT/skills")

# Optional paths - only bind if they exist
OPTIONAL_BINDS=()
[ -d "$HOME/.nvm" ]   && OPTIONAL_BINDS+=(--ro-bind "$HOME/.nvm"    "$HOME/.nvm")
[ -d "$HOME/.sdkman" ] && OPTIONAL_BINDS+=(--ro-bind "$HOME/.sdkman" "$HOME/.sdkman")
[ -d "$HOME/.local" ] && OPTIONAL_BINDS+=(--ro-bind "$HOME/.local"  "$HOME/.local")

# SSH agent socket - only bind if SSH_AUTH_SOCK is set and exists
SSH_BINDS=()
SSH_ENV=()
if [ -n "$SSH_AUTH_SOCK" ] && [ -S "$SSH_AUTH_SOCK" ]; then
  SSH_BINDS=(--ro-bind "$(dirname "$SSH_AUTH_SOCK")" "$(dirname "$SSH_AUTH_SOCK")"
             --ro-bind "$SSH_AUTH_SOCK" "$SSH_AUTH_SOCK")
  SSH_ENV=(--setenv SSH_AUTH_SOCK "$SSH_AUTH_SOCK")
fi

# D-Bus session bus - required for GNOME Keyring / Secret Service access
DBUS_BINDS=()
DBUS_ENV=()
XDG_RUNTIME="/run/user/$(id -u)"
if [ -S "$XDG_RUNTIME/bus" ]; then
  DBUS_BINDS=(--bind "$XDG_RUNTIME/bus" "$XDG_RUNTIME/bus")
  DBUS_ENV=(--setenv DBUS_SESSION_BUS_ADDRESS "unix:path=$XDG_RUNTIME/bus")
fi

# GNOME Keyring sockets - needed for secret service credential retrieval
KEYRING_BINDS=()
if [ -d "$XDG_RUNTIME/keyring" ]; then
  KEYRING_BINDS=(--bind "$XDG_RUNTIME/keyring" "$XDG_RUNTIME/keyring")
fi

# GitHub CLI config - read-only so Gemini can run gh read commands
GH_BINDS=()
if [ -d "$HOME/.config/gh" ]; then
  GH_BINDS=(--ro-bind "$HOME/.config/gh" "$HOME/.config/gh")
fi

# GPG configuration
GPG_ENV=()
[ -n "$GPG_SIGNING_KEY_ID" ] && GPG_ENV=(--setenv GPG_SIGNING_KEY_ID "$GPG_SIGNING_KEY_ID")

# SSH known_hosts - only bind if the file exists
SSH_KNOWN_HOSTS_BIND=()
[ -f "$HOME/.ssh/known_hosts" ] && SSH_KNOWN_HOSTS_BIND=(--ro-bind "$HOME/.ssh/known_hosts" "$HOME/.ssh/known_hosts")

# .gitconfig - only bind if the file exists
GITCONFIG_BIND=()
[ -f "$HOME/.gitconfig" ] && GITCONFIG_BIND=(--ro-bind "$HOME/.gitconfig" "$HOME/.gitconfig")

# Java/Maven env vars - only set if defined in parent shell
JAVA_ENV=()
[ -n "$JAVA_HOME" ]   && JAVA_ENV=(--setenv JAVA_HOME "$JAVA_HOME")
MAVEN_ENV=()
[ -n "$MAVEN_HOME" ]  && MAVEN_ENV=(--setenv MAVEN_HOME "$MAVEN_HOME")

GPG_BINDS=()
if [ -d "$HOME/.gnupg" ]; then
  GPG_BINDS=(--bind "$HOME/.gnupg" "$HOME/.gnupg")
fi

GPG_SOCKDIR=$(gpgconf --list-dirs socketdir 2>/dev/null)
if [ -n "$GPG_SOCKDIR" ] && [ -d "$GPG_SOCKDIR" ]; then
  GPG_BINDS+=(--bind "$GPG_SOCKDIR" "$GPG_SOCKDIR")
fi

# Gemini CLI specific paths
mkdir -p "$HOME/.gemini" "$HOME/.agents" "$HOME/.npm" "$HOME/.m2"

bwrap \
  --ro-bind /usr /usr \
  --ro-bind /lib /lib \
  --ro-bind /lib64 /lib64 \
  --ro-bind /bin /bin \
  --ro-bind /etc/resolv.conf /etc/resolv.conf \
  --ro-bind /etc/hosts /etc/hosts \
  --ro-bind /etc/ssl /etc/ssl \
  --ro-bind /etc/passwd /etc/passwd \
  --ro-bind /etc/group /etc/group \
  "${SSH_KNOWN_HOSTS_BIND[@]}" \
  --tmpfs /tmp \
  "${SSH_BINDS[@]}" \
  "${GPG_ENV[@]}" \
  "${GITCONFIG_BIND[@]}" \
  "${OPTIONAL_BINDS[@]}" \
  --bind "$HOME/.npm" "$HOME/.npm" \
  --bind "$HOME/.agents" "$HOME/.agents" \
  --bind "$HOME/.gemini" "$HOME/.gemini" \
  "${REPO_SKILLS_BIND[@]}" \
  --bind "$HOME/.m2" "$HOME/.m2" \
  --bind "$PWD" "$PWD" \
  "${GPG_BINDS[@]}" \
  "${GH_BINDS[@]}" \
  "${DBUS_BINDS[@]}" \
  "${KEYRING_BINDS[@]}" \
  --proc /proc \
  --dev /dev \
  --setenv HOME "$HOME" \
  --setenv USER "$USER" \
  "${JAVA_ENV[@]}" \
  "${MAVEN_ENV[@]}" \
  "${SSH_ENV[@]}" \
  "${DBUS_ENV[@]}" \
  --share-net \
  --unshare-pid \
  --die-with-parent \
  --chdir "$PWD" \
  "$(which bash)" "$@"
