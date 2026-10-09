"""Showcase hygiene check: JSON/XML must parse, and nothing sensitive or company-specific may be committed."""
import os, re, sys, json
import xml.dom.minidom as minidom

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
SKIP_DIRS = {".git", "node_modules", ".sfdx", ".sf"}
SKIP_FILES = {"validate.py"}
BINARY = (".zip", ".png", ".jpg", ".jpeg", ".gif")

# Add your employer's name, product names, customers and internal object names here.
COMPANY_TERMS = ["hikeedu", "dotsquare", "manipal", "symbiosis", "amity", "shoolini", "sharda", "nmims",
                 "lead_opportunity__c", "lead_activity__c", "user_details__c", "hike_"]

PATTERNS = {
    "JWT-like token": re.compile(r"eyJ[A-Za-z0-9_-]{20,}"),
    "recording link": re.compile(r"recording\?callId="),
    "long token query value": re.compile(r"[?&]token=[A-Za-z0-9%]{20,}"),
    "org username": re.compile(r"@[A-Za-z0-9.-]+\.(sandbox|dotsquare)\b", re.I),
    "Indian mobile number": re.compile(r"(?<!\d)(?:\+?91)?[6-9]\d{9}(?!\d)"),
}
errors = []

for base, dirs, files in os.walk(ROOT):
    dirs[:] = [d for d in dirs if d not in SKIP_DIRS]
    for name in files:
        path = os.path.join(base, name)
        rel = os.path.relpath(path, ROOT)
        if name in SKIP_FILES or name.endswith(BINARY):
            continue
        try:
            if name.endswith(".json"):
                json.load(open(path, encoding="utf-8"))
            elif name.endswith(".xml"):
                minidom.parse(path)
        except Exception as e:
            errors.append(f"{rel}: does not parse ({e})")
        try:
            text = open(path, encoding="utf-8").read()
        except Exception:
            continue
        low = text.lower()
        for term in COMPANY_TERMS:
            if term in low:
                errors.append(f"{rel}: contains company-specific term '{term}'")
        for label, rx in PATTERNS.items():
            if rx.search(text):
                errors.append(f"{rel}: looks like a {label}")

if errors:
    print("Problems found:")
    for e in errors:
        print(" -", e)
    sys.exit(1)
print("OK: files valid, nothing sensitive or company-specific found.")
