#!/usr/bin/env python3
"""Check direct project-type dependencies in the current single-target layout.

This source-level guard complements SwiftLint's framework-import rules and isolated
Domain compilation. It is not a replacement for separate compiler modules.
"""
import re
import sys
from pathlib import Path

LAYERS = ("Application", "Domain", "Data", "Presentation")
FORBIDDEN = {
    "Application": (),
    "Domain": ("Application", "Data", "Presentation"),
    "Data": ("Application", "Presentation"),
    "Presentation": ("Application", "Data"),
}
DECLARATION = re.compile(r"\b(?:class|struct|enum|actor|protocol|typealias)\s+(\w+)")
# Preserve newlines so diagnostics keep their source locations. SwiftLint handles imports.
NON_CODE = re.compile(r'//[^\n]*|/\*[\s\S]*?\*/|"""[\s\S]*?"""|"(?:\\.|[^"\\])*"')


def source_code(text):
    return NON_CODE.sub(lambda match: re.sub(r"[^\n]", " ", match.group()), text)


def violations(root):
    sources = {
        layer: {path: source_code(path.read_text()) for path in sorted((root / layer).rglob("*.swift"))}
        for layer in LAYERS
    }
    types = {
        layer: {name for code in files.values() for name in DECLARATION.findall(code)}
        for layer, files in sources.items()
    }
    for layer, files in sources.items():
        forbidden = {name: owner for owner in FORBIDDEN[layer] for name in types[owner]}
        for path, code in files.items():
            for token in re.finditer(r"\b\w+\b", code):
                name = token.group()
                if name in forbidden:
                    line = code.count("\n", 0, token.start()) + 1
                    yield f"{path}:{line}: error: {layer} must not reference {forbidden[name]} type {name}"


if __name__ == "__main__":
    root = Path(__file__).resolve().parents[1] / "Buffet"
    errors = list(violations(root))
    if errors:
        print("\n".join(errors), file=sys.stderr)
        sys.exit(1)
    print("Architecture dependency checks passed.")
