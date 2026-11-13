"""Create compact review sheets from the unmodified Android screenshots."""
from pathlib import Path
from PIL import Image, ImageDraw

root = Path(__file__).resolve().parent.parent
for theme in ("light", "dark"):
    files = sorted((root / "docs" / "screenshots").glob(f"{theme}-*.png"))
    if len(files) != 21:
        raise SystemExit(f"Expected 21 {theme} screenshots, found {len(files)}")
    sheet = Image.new("RGB", (1260, 1290), "#e9edf3")
    draw = ImageDraw.Draw(sheet)
    for index, path in enumerate(files):
        with Image.open(path) as source:
            thumb = source.convert("RGB")
            thumb.thumbnail((172, 395))
        x, y = (index % 7) * 180, (index // 7) * 430
        sheet.paste(thumb, (x + 4, y + 3))
        draw.text((x + 4, y + 403), path.stem.split("-", 2)[-1], fill="#1e3243")
    sheet.save(root / "docs" / f"overview-{theme}.jpg", quality=88)
