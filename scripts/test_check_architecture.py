import tempfile
import unittest
from pathlib import Path

from check_architecture import violations


class ArchitectureChecksTests(unittest.TestCase):
    def check_sources(self, sources):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            for name, content in sources.items():
                path = root / name
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text(content)
            return list(violations(root))

    def test_rejects_reverse_dependencies_without_framework_imports(self):
        for layer in ("Domain", "Presentation"):
            with self.subTest(layer=layer):
                errors = self.check_sources({
                    "Data/Storage.swift": "final class Storage {}",
                    f"{layer}/Feature.swift": "struct Feature { let storage: Storage }",
                })
                self.assertEqual(len(errors), 1)
                self.assertIn(f"{layer} must not reference Data type Storage", errors[0])

    def test_rejects_data_to_presentation(self):
        errors = self.check_sources({
            "Presentation/Screen.swift": "struct Screen {}",
            "Data/Storage.swift": "struct Storage { let screen: Screen }",
        })
        self.assertEqual(len(errors), 1)

    def test_allows_inward_dependencies_and_composition(self):
        errors = self.check_sources({
            "Domain/Product.swift": "struct Product {}",
            "Data/Storage.swift": "struct Storage { let product: Product }",
            "Presentation/Screen.swift": "struct Screen { let product: Product }",
            "Application/Container.swift": "struct Container { let storage: Storage; let screen: Screen }",
        })
        self.assertEqual(errors, [])

    def test_ignores_comments_and_plain_strings(self):
        errors = self.check_sources({
            "Data/Storage.swift": "struct Storage {}",
            "Domain/Product.swift": '// Storage\n/* Storage */\nlet label = "Storage"',
        })
        self.assertEqual(errors, [])


if __name__ == "__main__":
    unittest.main()
