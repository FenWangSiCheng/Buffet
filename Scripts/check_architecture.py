#!/usr/bin/env python3
"""Check source-layer dependencies and typecheck Domain without application/framework sources."""
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "PayPayPay" / "PayPayPay"
LAYERS = ("Domain", "Data", "Presentation", "Application")
files = {layer: sorted((SOURCE / layer).rglob("*.swift")) for layer in LAYERS}

def identifiers(path):
    # This guard is intentionally lightweight; it supplements, rather than replaces, module isolation.
    source = re.sub(r"//[^\n]*|/\*.*?\*/", "", path.read_text(), flags=re.S)
    return source, set(re.findall(r"\b(?:class(?!\s+(?:func|var|let))|struct|enum|protocol|typealias)\s+(\w+)", source))

types = {layer: set().union(*(identifiers(path)[1] for path in paths)) for layer, paths in files.items()}
forbidden = {
    "Domain": types["Data"] | types["Presentation"] | types["Application"] |
              {"SwiftUI", "UIKit", "Moya", "Combine", "UserDefaults", "Codable", "Decodable", "JSONDecoder"},
    "Data": types["Presentation"] | types["Application"] | {"SwiftUI", "UIKit"},
    "Presentation": types["Data"] | types["Application"] | {"Moya", "UserDefaults", "JSONDecoder"},
}
errors = []
for layer, blocked in forbidden.items():
    for path in files[layer]:
        source, _ = identifiers(path)
        matches = sorted(set(re.findall(r"\b\w+\b", source)) & blocked)
        if matches:
            errors.append(f"{path.relative_to(ROOT)}: forbidden references: {', '.join(matches)}")
if errors:
    sys.exit("\n".join(errors))
subprocess.run(["xcrun", "swiftc", "-swift-version", "6", "-typecheck", *map(str, files["Domain"])], check=True)
print("Architecture checks passed; Domain typechecks independently in Swift 6.")
