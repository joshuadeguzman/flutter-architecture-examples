"""Renders every SVG in a folder to a 2x PNG, with Google Sans loaded.

Needs macOS with Google Chrome installed. Usage: python3 render.py <dir>
"""
import re
import subprocess
import sys
from pathlib import Path

CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
FONTS = (
    "https://fonts.googleapis.com/css2?family=Google+Sans+Flex:wght@400;500;600"
    "&family=Google+Sans+Code:wght@400&display=block"
)

folder = Path(sys.argv[1]).resolve()
for svg in sorted(folder.glob("*.svg")):
    text = svg.read_text()
    w, h = re.search(r'<svg[^>]*?width="(\d+)" height="(\d+)"', text).groups()
    html = svg.with_suffix(".html")
    html.write_text(
        f'<!doctype html><html><head><link href="{FONTS}" rel="stylesheet">'
        "<style>html,body{margin:0;background:#fff}svg{display:block}</style>"
        f"</head><body>{text}</body></html>"
    )
    subprocess.run(
        [CHROME, "--headless=new", "--disable-gpu", "--hide-scrollbars",
         "--force-device-scale-factor=2", f"--window-size={w},{h}",
         "--virtual-time-budget=6000", f"--screenshot={svg.with_suffix('.png')}",
         html.as_uri()],
        check=True, capture_output=True,
    )
    print(svg.with_suffix(".png").name, w, h)
