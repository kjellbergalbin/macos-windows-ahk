from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


def source(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


class WindowManagementContractTests(unittest.TestCase):
    def test_module_is_wired_and_independently_configurable(self):
        config = source("config.ahk")
        entrypoint = source("macOS-Windows.ahk")

        self.assertIn("static EnableWindowManagement := true", config)
        self.assertIn("static EnableDisplayControls  := true", config)
        self.assertIn("static EnableWindowTiling     := true", config)
        self.assertIn("static EnableWideLayouts      := true", config)
        self.assertIn("#Include modules\\window-management.ahk", entrypoint)

    def test_selected_rectangle_style_shortcuts_are_declared(self):
        module = source("modules/window-management.ahk")

        expected_bindings = [
            "^!#Left::MoveActiveWindowToAdjacentMonitor(-1)",
            "^!#Right::MoveActiveWindowToAdjacentMonitor(1)",
            "^!Enter::ToggleActiveWindowMaximize()",
            "^!#h::MaximizeActiveWindowHeight()",
            "^!#a::TileActiveWindow(0, 0, 0.5, 1)",
            "^!#d::TileActiveWindow(0.5, 0, 0.5, 1)",
            "^!#w::TileActiveWindow(0, 0, 1, 0.5)",
            "^!#s::TileActiveWindow(0, 0.5, 1, 0.5)",
            "^!#q::TileActiveWindow(0, 0, 0.5, 0.5)",
            "^!#e::TileActiveWindow(0.5, 0, 0.5, 0.5)",
            "^!#z::TileActiveWindow(0, 0.5, 0.5, 0.5)",
            "^!#c::TileActiveWindow(0.5, 0.5, 0.5, 0.5)",
            "^!#1::TileActiveWindow(0, 0, 1 / 3, 1)",
            "^!#2::TileActiveWindow(1 / 3, 0, 1 / 3, 1)",
            "^!#3::TileActiveWindow(2 / 3, 0, 1 / 3, 1)",
            "^!+#1::TileActiveWindow(0, 0, 2 / 3, 1)",
            "^!+#2::TileActiveWindow(1 / 6, 0, 2 / 3, 1)",
            "^!+#3::TileActiveWindow(1 / 3, 0, 2 / 3, 1)",
        ]

        for binding in expected_bindings:
            self.assertIn(binding, module)

    def test_placement_uses_work_areas_and_restores_maximized_windows(self):
        module = source("modules/window-management.ahk")

        self.assertIn("MonitorGetWorkArea", module)
        self.assertIn("WinRestore", module)
        self.assertIn("WinMove", module)
        self.assertIn("GetActiveWindowMonitor", module)
        self.assertIn("FindAdjacentMonitor", module)


if __name__ == "__main__":
    unittest.main()
