#!/usr/bin/env -S uv run --quiet --script
# /// script
# requires-python = ">=3.10"
# dependencies = [
#     "dbus-python",
# ]
# ///

"""
Set a window to a specific resolution by title.

Usage:
    set-res <window_title> <width> <height>
    set-res --list

Examples:
    set-res "Firefox" 1920 1080
    set-res --list
"""

import sys
import subprocess
import re
from typing import Optional, Tuple, List


def run_command(cmd: list[str]) -> Tuple[int, str, str]:
    result = subprocess.run(cmd, capture_output=True, text=True)
    return result.returncode, result.stdout, result.stderr


def list_windows() -> None:
    """List all windows with their titles."""
    print("=== KWin Windows (Wayland) ===")
    try:
        import dbus
        session_bus = dbus.SessionBus()
        kwin = session_bus.get_object('org.kde.KWin', '/KWin')

        # Get window IDs
        returncode, stdout, _ = run_command(['qdbus', 'org.kde.KWin', '/KWin', 'org.kde.KWin.windowList'])
        if returncode == 0:
            window_ids = [w.strip() for w in stdout.strip().split('\n') if w.strip().isdigit()]

            for wid in window_ids:
                _, caption, _ = run_command([
                    'qdbus', 'org.kde.KWin', f'/Windows/{wid}',
                    'org.kde.KWin.Window.caption'
                ])
                caption = caption.strip()
                if caption:
                    print(f"  [{wid}] {caption}")
    except Exception as e:
        print(f"Error listing KWin windows: {e}")

    print("\n=== XWayland Windows (wmctrl) ===")
    returncode, stdout, _ = run_command(['wmctrl', '-l'])
    if returncode == 0:
        for line in stdout.strip().split('\n'):
            if line:
                parts = line.split(None, 3)
                if len(parts) >= 4:
                    print(f"  [{parts[0]}] {parts[3]}")


def find_kwin_window_by_title(title: str) -> Optional[str]:
    """Find a window ID by title using KWin D-Bus interface."""
    returncode, stdout, _ = run_command(['qdbus', 'org.kde.KWin', '/KWin', 'org.kde.KWin.windowList'])
    if returncode != 0:
        return None

    window_ids = [w.strip() for w in stdout.strip().split('\n') if w.strip().isdigit()]

    for wid in window_ids:
        _, caption, _ = run_command([
            'qdbus', 'org.kde.KWin', f'/Windows/{wid}',
            'org.kde.KWin.Window.caption'
        ])
        caption = caption.strip()
        if title.lower() in caption.lower():
            return wid

    return None


def resize_kwin_window(window_id: str, width: int, height: int) -> bool:
    """Resize a window using KWin D-Bus interface."""
    try:
        # Get current geometry to preserve position
        returncode, geometry, _ = run_command([
            'qdbus', 'org.kde.KWin', f'/Windows/{window_id}',
            'org.kde.KWin.Window.frameGeometry'
        ])

        if returncode != 0:
            return False

        # Parse geometry: x,y,width,height
        match = re.search(r'(\d+),(\d+),(\d+),(\d+)', geometry)
        if not match:
            print(f"Warning: Could not parse geometry: {geometry}")
            x, y = 0, 0
        else:
            x, y = int(match.group(1)), int(match.group(2))

        # Set new geometry
        returncode, stdout, stderr = run_command([
            'qdbus', 'org.kde.KWin', f'/Windows/{window_id}',
            'org.kde.KWin.Window.setFrameGeometry',
            f'{x},{y},{width},{height}'
        ])

        if returncode != 0:
            print(f"Error setting geometry: {stderr}")
            return False

        print(f"Resized window to {width}x{height} at position ({x},{y})")
        return True

    except Exception as e:
        print(f"Error resizing window: {e}")
        return False


def find_xwayland_window_by_title(title: str) -> Optional[str]:
    """Find a window ID by title using wmctrl."""
    returncode, stdout, _ = run_command(['wmctrl', '-l'])
    if returncode != 0:
        return None

    for line in stdout.strip().split('\n'):
        if line and title.lower() in line.lower():
            parts = line.split(None, 3)
            if len(parts) >= 4:
                return parts[0]

    return None


def resize_xwayland_window(window_id: str, width: int, height: int) -> bool:
    """Resize an XWayland window using wmctrl."""
    try:
        # wmctrl -i -r <window_id> -e 0,-1,-1,width,height
        # Format: gravity,x,y,width,height (-1 keeps current value)
        returncode, stdout, stderr = run_command([
            'wmctrl', '-i', '-r', window_id, '-e', f'0,-1,-1,{width},{height}'
        ])

        if returncode != 0:
            print(f"Error resizing XWayland window: {stderr}")
            return False

        print(f"Resized XWayland window to {width}x{height}")
        return True

    except Exception as e:
        print(f"Error resizing XWayland window: {e}")
        return False


def set_window_resolution(title: str, width: int, height: int) -> bool:
    """Set a window to a specific resolution by title."""

    # Try KWin first (native Wayland)
    print(f"Searching for window with title containing: {title}")
    window_id = find_kwin_window_by_title(title)

    if window_id:
        print(f"Found KWin window ID: {window_id}")
        if resize_kwin_window(window_id, width, height):
            return True

    # Fall back to XWayland
    window_id = find_xwayland_window_by_title(title)
    if window_id:
        print(f"Found XWayland window ID: {window_id}")
        if resize_xwayland_window(window_id, width, height):
            return True

    print(f"Error: No window found with title containing '{title}'")
    print("Use --list to see all available windows")
    return False


def main():
    if len(sys.argv) == 2 and sys.argv[1] == '--list':
        list_windows()
        return 0

    if len(sys.argv) != 4:
        print(__doc__)
        return 1

    title = sys.argv[1]
    try:
        width = int(sys.argv[2])
        height = int(sys.argv[3])
    except ValueError:
        print("Error: Width and height must be integers")
        print(__doc__)
        return 1

    if width <= 0 or height <= 0:
        print("Error: Width and height must be positive")
        return 1

    success = set_window_resolution(title, width, height)
    return 0 if success else 1


if __name__ == '__main__':
    sys.exit(main())
