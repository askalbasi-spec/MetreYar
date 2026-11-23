"""Draws the MetreYar launcher icon with Pillow (same mark as the in-app
animated logo, at rest).

Run:  python3 tools/make_icon.py
"""
import os

from PIL import Image, ImageDraw

OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "icon")
S = 1024
GOLD = (214, 173, 85)


def main():
    base = Image.new("RGBA", (S, S), (14, 27, 52, 255))
    d = ImageDraw.Draw(base)
    # three rising bars
    for i, h in enumerate((.28, .40, .50)):
        x = S * (.2 + i * .22)
        hh = S * h
        shade = int(184 + (241 - 184) * i / 2), int(145 + (213 - 145) * i / 2), int(60 + (140 - 60) * i / 2)
        d.rounded_rectangle((x, S * .78 - hh, x + S * .16, S * .78), S * .04, fill=shade)
    d.line((S * .14, S * .8, S * .86, S * .8), fill=(230, 230, 230), width=int(S * .02))
    # level vial with the bubble at rest
    d.rounded_rectangle((S * .25, S * .14, S * .75, S * .26), S * .06, outline=(255, 255, 255), width=int(S * .02))
    r = S * .045
    d.ellipse((S * .5 - r, S * .2 - r, S * .5 + r, S * .2 + r), fill=(124, 255, 178))
    # gold frame
    mask = Image.new("L", (S, S), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, S - 1, S - 1), 230, fill=255)
    ImageDraw.Draw(base).rounded_rectangle((8, 8, S - 9, S - 9), 224, outline=GOLD, width=18)
    icon = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    icon.paste(base, (0, 0), mask)
    os.makedirs(OUT, exist_ok=True)
    icon.resize((512, 512), Image.LANCZOS).save(os.path.join(OUT, "app_icon.png"))
    for name, px in (("mdpi", 48), ("hdpi", 72), ("xhdpi", 96), ("xxhdpi", 144), ("xxxhdpi", 192)):
        folder = os.path.join(OUT, "android", f"mipmap-{name}")
        os.makedirs(folder, exist_ok=True)
        icon.resize((px, px), Image.LANCZOS).save(os.path.join(folder, "ic_launcher.png"))


if __name__ == "__main__":
    main()
