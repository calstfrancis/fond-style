# Fond for Plasma

The suite's interface language, applied to the desktop it runs on.

`../style/fond.css` settles how a Fond app looks; this settles how the panel,
the popups, the window titlebars and every Qt application around them look, so
that Zerkalo open next to System Settings reads as one desktop rather than two.

## What it is

| Piece | Path | Does |
|---|---|---|
| Colour schemes | `color-schemes/Fond{Light,Dark}.colors` | the palette, for Qt apps, Breeze and Plasma |
| Desktop theme | `desktoptheme/fond/` | panel, popups, tooltips, list rows |
| Look-and-feel | `look-and-feel/io.github.calstfrancis.fond/` | binds the above into one entry, plus decoration and widget-style defaults |
| Frame generator | `tools/make-frames.py` | writes the theme's 9-slice SVGs |

## Installing

```sh
./install.sh            # into ~/.local/share, then tells you how to apply it
./install.sh --apply    # and apply to the running session
./install.sh --uninstall
```

Nothing needs root and nothing overwrites the system Breeze it sits beside.
`--apply` is separate because it is a visible change to a running session
rather than a file drop.

The look-and-feel sets **Fond Light**. For dark, System Settings → Colors →
Fond Dark; the desktop theme follows either without being switched, for the
reason in the next section.

## The palette is libadwaita's, not an invention

Every value in the two `.colors` files is lifted from libadwaita's own named
colours — `#fafafb` window, `#ebebed` sidebar, `#f3f3f5` ground, `#ffffff`
view, and the dark set beside them. A Qt window therefore sits at exactly the
tone of a Fond app next to it, which is the whole point; a palette that was
merely *similar* would be worse than one that was obviously different.

The surface stack maps onto Plasma's colour sets directly:

| fond.css | libadwaita | Plasma |
|---|---|---|
| `.fond-chrome` / `.fond-sidebar` | `@sidebar_bg_color` | `Colors:Header` |
| `.fond-ground` | `@secondary_sidebar_bg_color` | `Colors:Complementary` |
| `.fond-view` | `@view_bg_color` | `Colors:View` |
| `.fond-card` | `@card_bg_color` | `Colors:Button` |

`Colors:Header` takes the *sidebar* colour rather than `@headerbar_bg_color`,
which is the same call fond.css records in its Surfaces header: Adwaita's
header bar is pure white in the light scheme, so using it gives no separation
from content at all. Chrome has to be the darker plane.

## Nothing in the SVGs is a colour

The desktop theme ships **no `colors` file**, deliberately. A theme that ships
one pins its own palette and stops following the colour scheme. Without one,
Plasma rewrites each SVG's embedded `current-color-scheme` stylesheet at
runtime from whichever scheme is active, so shapes painted `fill:currentColor`
under a `ColorScheme-*` class pick up Fond Light or Fond Dark for free.

That is fond.css's own rule — *nothing is hardcoded, so a change of colour
scheme or accent is picked up for free* — arriving at the same place by a
different mechanism. It is also why one set of SVGs serves both schemes.

The literal values in each SVG's stylesheet are Fond Light, and exist only so
the files look right opened in an editor. They never reach a live session.

## What the frames say

`tools/make-frames.py` generates every SVG from four constants that are the
same four decisions as in fond.css:

- **`RADIUS = 10`** — `.fond-card`'s corner. Popups, dialogs, tooltips and
  applet backgrounds are all the same object in Fond: a card.
- **`HAIRLINE = 0.15`** — `@borders`, which is `currentColor` at 15%. One
  hairline, no shadow, no gradient, no bevel.
- **`WASH_SELECT = 0.09` / `WASH_HOVER = 0.05`** — list selection is a wash
  across the row, exactly as in `.fond-list row.fond-row:selected`, and square
  rather than rounded because a Fond row runs the full width of its list. Not
  an accent fill and not an outline; a selected row should read as current, not
  shout.
- **`CHROME_TINT = 0.04`** — plasmoid headers and footers. The SVG classes
  Plasma exposes have no equivalent of `Colors:Header`, so chrome is made by
  laying `ColorScheme-Text` over the background at 4%, which darkens on a light
  scheme and lightens on a dark one. The same one-rule-serves-both-schemes
  trick `.fond-list`'s selection uses.

Change a constant and every frame in the theme moves together. The files are
generated — edit the script, not the SVGs.

## Where it stops

- **The widget style is stock Breeze**, configured quietly in `defaults`
  (separators off, scrollbar steppers off, flat titlebar with the hairline
  separator on). Fond is not a different set of widgets, it is a different set
  of decisions about surfaces, edges and emphasis, and Breeze configured this
  way lands closer to Adwaita than any heavier Qt style does.
- **No Kvantum theme.** It would buy rounder, more Adwaita-like Qt widgets at
  the cost of a second styling engine to keep in step with the colour schemes.
  Worth revisiting only if stock Breeze proves too square in practice.
- **No fonts are set.** A look-and-feel can impose them; this one does not,
  since the choice is Cal's rather than the design language's.
- **No preview image**, so the System Settings tile is blank. Needs a
  screenshot of an applied desktop, which is a chicken-and-egg job for after
  it has been looked at.
- **Selection stays accent-blue outside plasmoid lists.** fond.css neutralises
  selection only *within* Fond lists and leaves `@accent` doing its normal work
  elsewhere; Qt and Kirigami apps expect the same, so `Colors:Selection` is the
  Adwaita blue.
