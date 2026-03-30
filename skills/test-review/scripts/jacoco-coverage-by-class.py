#!/usr/bin/env python3
"""Parse target/site/jacoco/jacoco.xml and print a coverage summary."""
import sys
import xml.etree.ElementTree as ET

if len(sys.argv) < 2:
    print("Usage: jacoco-coverage-by-class.py <ClassName> [ClassName2 ...]", file=sys.stderr)
    sys.exit(1)

class_filters = sys.argv[1:]
jacoco_xml = "target/site/jacoco/jacoco.xml"

try:
    root = ET.parse(jacoco_xml).getroot()
except FileNotFoundError:
    print(f"ERROR: {jacoco_xml} not found. Run 'mvn test jacoco:report' first.", file=sys.stderr)
    sys.exit(1)

for class_filter in class_filters:
    print(f"=== {class_filter} ===")
    found = False
    for pkg in root.findall('package'):
        for cls in pkg.findall('class'):
            if class_filter in cls.get('name', ''):
                found = True
                print(cls.get('name'))
                for c in cls.findall('counter'):
                    missed = int(c.get("missed"))
                    covered = int(c.get("covered"))
                    total = missed + covered
                    pct = round(covered / total * 100, 1) if total else 0.0
                    print(f"  {c.get('type')}: {covered}/{total} ({pct}%)")
    if not found:
        print(f"  No classes matching '{class_filter}' found.")
    print()