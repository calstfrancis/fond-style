#!/usr/bin/env python3
"""make-frames.py — generate the Fond desktop theme's 9-slice SVGs.

Plasma paints panels, popups and list rows from SVGs sliced into nine pieces:
four corners, four edges, and a centre that tiles. Every piece is a separate
element found by id, so the files are mostly geometry — which is exactly the
kind of thing that should be generated rather than drawn by hand and then
maintained by hand. Change RADIUS or HAIRLINE here and every frame in the
theme moves together.

Colour works the same way it does in fond.css. Nothing here is a literal
colour: shapes are painted `fill:currentColor` and carry a `ColorScheme-*`
class, and Plasma rewrites the embedded `current-color-scheme` stylesheet at
runtime from whichever colour scheme is active. So the theme follows Fond
Light and Fond Dark for free, the same way the apps follow libadwaita.

    ./make-frames.py          write the SVGs into ../desktoptheme/fond/

The values in the stylesheet below are only what a plain SVG viewer sees when
opening the file outside Plasma; they are Fond Light, so the files at least
look right in an editor.
"""

from pathlib import Path

# ── The design constants, shared with fond.css ────────────────────────────
RADIUS = 10       # .fond-card / .fond-first / .fond-last corner radius
HAIRLINE = 0.15   # @borders is currentColor at 15%
WASH_HOVER = 0.05  # .fond-search:focus-within
WASH_SELECT = 0.09  # .fond-list row.fond-row:selected
CHROME_TINT = 0.04  # stands in for sidebar_bg being darker than window_bg

OUT = Path(__file__).resolve().parent.parent / "desktoptheme" / "fond"

# Fond Light, for viewing the files outside Plasma. Plasma replaces this whole
# block at runtime, so these values never reach the screen in a live session.
STYLESHEET = """    .ColorScheme-Text            { color:#323237; }
    .ColorScheme-Background      { color:#fafafb; }
    .ColorScheme-Highlight       { color:#3584e4; }
    .ColorScheme-ViewText        { color:#333338; }
    .ColorScheme-ViewBackground  { color:#ffffff; }
    .ColorScheme-ViewHover       { color:#3584e4; }
    .ColorScheme-ViewFocus       { color:#3584e4; }
    .ColorScheme-ButtonText      { color:#323237; }
    .ColorScheme-ButtonBackground{ color:#ffffff; }
    .ColorScheme-ButtonHover     { color:#3584e4; }
    .ColorScheme-ButtonFocus     { color:#3584e4; }"""

EDGE = 8   # length of each straight edge tile
GAP = 2    # blank canvas between pieces, so no bounding box bleeds into another


def frame(prefix, radius, fill_class, fill_opacity, border_opacity,
          borders="tlrb", margin=None, origin=(0, 0)):
    """One 9-slice frame. Returns (svg_fragment, width, height).

    `borders` says which outer sides get the hairline — a panel docked to the
    bottom of the screen only wants one, a floating popup wants all four.
    """
    p = f"{prefix}-" if prefix else ""
    r = radius
    c = max(r, 1) + 1          # corner piece size: the radius plus 1px to meet the edge
    ox, oy = origin

    xs = [ox, ox + c + GAP, ox + c + GAP + EDGE + GAP]
    ys = [oy, oy + c + GAP, oy + c + GAP + EDGE + GAP]
    w, h = xs[2] + c, ys[2] + c

    out = []

    def rect(eid, x, y, rw, rh):
        out.append(
            f'    <rect id="{eid}" class="{fill_class}" x="{x}" y="{y}" '
            f'width="{rw}" height="{rh}" '
            f'style="fill:currentColor;fill-opacity:{fill_opacity};stroke:none"/>')

    def stroke(d):
        out.append(
            f'    <path class="ColorScheme-Text" d="{d}" '
            f'style="fill:none;stroke:currentColor;stroke-width:1;'
            f'stroke-opacity:{border_opacity};stroke-linecap:butt"/>')

    def corner(eid, x, y, sx, sy):
        """A rounded corner. (sx, sy) is the direction the arc opens toward."""
        if r <= 0:
            rect(eid, x, y, c, c)
            return
        # Centre of the arc, always the inner corner of the piece.
        cx, cy = x + (0 if sx > 0 else c), y + (0 if sy > 0 else c)
        cx += r * sx
        cy += r * sy
        # Fill: the piece square with the outside of the arc bitten out.
        ax, ay = cx - r * sx, cy              # arc start, on the vertical run
        bx, by = cx, cy - r * sy              # arc end, on the horizontal run
        far_x = x + (c if sx > 0 else 0)
        far_y = y + (c if sy > 0 else 0)
        sweep = 1 if (sx * sy) > 0 else 0
        out.append(
            f'    <path id="{eid}" class="{fill_class}" '
            f'd="M {ax},{ay} A {r},{r} 0 0 {sweep} {bx},{by} '
            f'L {far_x},{by} L {far_x},{far_y} L {ax},{far_y} Z" '
            f'style="fill:currentColor;fill-opacity:{fill_opacity};stroke:none"/>')
        if border_opacity:
            # Same arc, inset half a stroke so the hairline sits inside the shape.
            ri = r - 0.5
            i_ax = cx - ri * sx
            i_by = cy - ri * sy
            stroke(f"M {i_ax},{ay} A {ri},{ri} 0 0 {sweep} {bx},{i_by}")

    corner(f"{p}topleft", xs[0], ys[0], 1, 1)
    corner(f"{p}topright", xs[2], ys[0], -1, 1)
    corner(f"{p}bottomleft", xs[0], ys[2], 1, -1)
    corner(f"{p}bottomright", xs[2], ys[2], -1, -1)

    rect(f"{p}top", xs[1], ys[0], EDGE, c)
    rect(f"{p}bottom", xs[1], ys[2], EDGE, c)
    rect(f"{p}left", xs[0], ys[1], c, EDGE)
    rect(f"{p}right", xs[2], ys[1], c, EDGE)
    rect(f"{p}center", xs[1], ys[1], EDGE, EDGE)

    if border_opacity:
        if "t" in borders:
            stroke(f"M {xs[1]},{ys[0] + 0.5} L {xs[1] + EDGE},{ys[0] + 0.5}")
        if "b" in borders:
            stroke(f"M {xs[1]},{ys[2] + c - 0.5} L {xs[1] + EDGE},{ys[2] + c - 0.5}")
        if "l" in borders:
            stroke(f"M {xs[0] + 0.5},{ys[1]} L {xs[0] + 0.5},{ys[1] + EDGE}")
        if "r" in borders:
            stroke(f"M {xs[2] + c - 0.5},{ys[1]} L {xs[2] + c - 0.5},{ys[1] + EDGE}")

    if margin is not None:
        # Only the size of a hint rect matters, never where it sits. Plasma
        # reads the width of the left/right hints and the height of the
        # top/bottom ones as the frame's content margins.
        for side, mw, mh in (("left", margin, 1), ("right", margin, 1),
                             ("top", 1, margin), ("bottom", 1, margin)):
            out.append(
                f'    <rect id="{p}hint-{side}-margin" x="{ox}" y="{oy}" '
                f'width="{mw}" height="{mh}" style="opacity:0;fill:none"/>')

    return "\n".join(out), w, h


def document(body, w, h, note):
    return f"""<?xml version="1.0" encoding="UTF-8"?>
<!-- {note}
     Generated by plasma/tools/make-frames.py — do not edit by hand. -->
<svg xmlns="http://www.w3.org/2000/svg" version="1.1"
     width="{w}" height="{h}" viewBox="0 0 {w} {h}">
  <defs>
    <style type="text/css" id="current-color-scheme">
{STYLESHEET}
    </style>
  </defs>
  <g id="fond">
{body}
  </g>
</svg>
"""


def write(relpath, body, w, h, note):
    path = OUT / relpath
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(document(body, w, h, note))
    print(f"  {relpath}")


def stacked(*frames):
    """Lay several frames down the canvas so their ids never collide."""
    parts, y, w = [], 0, 0
    for kwargs in frames:
        body, fw, fh = frame(origin=(0, y), **kwargs)
        parts.append(body)
        y += fh + GAP * 2
        w = max(w, fw)
    return "\n".join(parts), w, y - GAP * 2


def main():
    print(f"writing to {OUT}")

    # Popups, applet backgrounds, dialogs and tooltips are all the same object
    # in Fond: a card. One radius, one hairline, no shadow or gradient.
    card = dict(prefix="", radius=RADIUS, fill_class="ColorScheme-Background",
                fill_opacity=1, border_opacity=HAIRLINE, margin=6)
    for rel, note in (
        ("widgets/background.svg", "Applet and popup background — a Fond card."),
        ("dialogs/background.svg", "Dialog background — a Fond card."),
        ("widgets/tooltip.svg", "Tooltip — a Fond card."),
        ("opaque/widgets/background.svg", "Applet background, opaque variant."),
        ("opaque/dialogs/background.svg", "Dialog background, opaque variant."),
        ("translucent/widgets/background.svg", "Applet background, translucent variant."),
        ("translucent/dialogs/background.svg", "Dialog background, translucent variant."),
    ):
        body, w, h = frame(**card)
        write(rel, body, w, h, note)

    # The panel is chrome: the darkest plane, and the one thing on screen that
    # should never draw attention to itself.
    body, w, h = frame(prefix="", radius=RADIUS,
                       fill_class="ColorScheme-Background",
                       fill_opacity=1, border_opacity=HAIRLINE, margin=2)
    write("widgets/panel-background.svg", body, w, h,
          "Panel background — .fond-chrome.")

    # A plasmoid's header and footer strips, each with the hairline where it
    # meets content: .fond-edge-bottom and .fond-edge-top.
    body, w, h = stacked(
        dict(prefix="header", radius=0, fill_class="ColorScheme-Text",
             fill_opacity=CHROME_TINT, border_opacity=HAIRLINE, borders="b"),
        dict(prefix="footer", radius=0, fill_class="ColorScheme-Text",
             fill_opacity=CHROME_TINT, border_opacity=HAIRLINE, borders="t"),
    )
    write("widgets/plasmoidheading.svg", body, w, h,
          "Plasmoid header and footer — .fond-chrome with a hairline edge.")

    # Selection is a wash across the row, never an accent fill or an outline.
    # Square, because a Fond row runs the full width of its list.
    body, w, h = stacked(
        dict(prefix="normal", radius=0, fill_class="ColorScheme-Text",
             fill_opacity=0, border_opacity=0),
        dict(prefix="hover", radius=0, fill_class="ColorScheme-Text",
             fill_opacity=WASH_HOVER, border_opacity=0),
        dict(prefix="pressed", radius=0, fill_class="ColorScheme-Text",
             fill_opacity=WASH_SELECT, border_opacity=0),
        dict(prefix="selected", radius=0, fill_class="ColorScheme-Text",
             fill_opacity=WASH_SELECT, border_opacity=0),
        dict(prefix="section", radius=0, fill_class="ColorScheme-Text",
             fill_opacity=0, border_opacity=0),
    )
    write("widgets/listitem.svg", body, w, h,
          "List rows — selection is a wash, not an accent bar.")


if __name__ == "__main__":
    main()
