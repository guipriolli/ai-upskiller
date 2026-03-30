#!/usr/bin/env python3
"""Parse target/site/jacoco/jacoco.xml and print a coverage summary."""
import sys
import xml.etree.ElementTree as ET

jacoco_xml = "target/site/jacoco/jacoco.xml"

try:
    root = ET.parse(jacoco_xml).getroot()
except FileNotFoundError:
    print(f"ERROR: {jacoco_xml} not found. Run 'mvn test jacoco:report' first.", file=sys.stderr)
    sys.exit(1)

for c in root.findall("counter"):
    missed = int(c.get("missed"))
    covered = int(c.get("covered"))
    total = missed + covered
    pct = round(covered / total * 100, 1) if total else 0.0
    print(f"{c.get('type')}: {covered}/{total} ({pct}%)")
