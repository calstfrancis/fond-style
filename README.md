# fond-style

The shared interface layer for the Fond suite — Rubric, Zerkalo, Skrizhal, Iskra
and the rest. One stylesheet, `style/fond.css`, defining the part of the design
that should not differ between apps: how surfaces stack, how a section is
announced, how a row of content is set, how the status bar behaves.

Everything is expressed in libadwaita's named colours, so colour scheme and
accent changes are picked up for free in every app at once.

## Why a copy per app, not a dependency

Each app is built as its own flatpak from its own git repository, so anything
the build needs has to be committed inside that repository. A crate dependency
would work for the Rust apps and nothing for the Python ones.

So `style/fond.css` is the canonical copy, and each app carries a vendored copy
at `style/fond.css` of its own. `sync.sh` pushes the canonical file out;
`check.sh` reports any app whose copy has drifted. Wire `check.sh` into an app's
CI the way `check-versions.sh` already is, and drift becomes a failed build
rather than something to notice by eye.

## Using it

**Rust** — concatenate at compile time, app rules after the shared ones:

```rust
const FOND_CSS: &str = include_str!("../../style/fond.css");

let css = gtk4::CssProvider::new();
css.load_from_data(&format!("{FOND_CSS}\n{GLOBAL_CSS}"));
```

**Python** — read the vendored file at startup:

```python
_FOND = Path(__file__).parent / "style" / "fond.css"
css.load_from_data((_FOND.read_text() + APP_CSS).encode())
```

## The classes

| Class | For |
|---|---|
| `.fond-chrome` / `.fond-sidebar` / `.fond-ground` / `.fond-view` | the four surfaces, darkest chrome to lightest content |
| `.fond-edge-top` / `.fond-edge-bottom` | a hairline where a bar meets content |
| `.fond-section` + `-title` / `-meta` / `-dot` | a section header: dot, small caps, count |
| `.fond-card` + `-first` / `-last` | a group of rows reading as one object |
| `row.fond-row` + `.fond-row-title` / `-detail` / `-meta` | a single-line row |
| `.fond-list` | the list a card group lives in; also carries selection |
| `.fond-cue` | a drawn dot; give it a 9×9 size request and a colour |
| `.fond-statusbar`, `.fond-toggle-active`, `.fond-metric` | the status bar and its words |
| `headerbar button.fond-pill` | the one bordered control in a header bar |
| `headerbar .fond-title-btn` | the window title, which is text and not a control |
| `.fond-quiet` | a control that should not shout |
| `.fond-onhover` | drag handles and secondary affordances |
| `.fond-search` | an unframed search field inside a list |

## Things learned the expensive way

These are in the stylesheet as comments too, because each one cost a round of
"why does that still look wrong":

- **Adwaita's `@headerbar_bg_color` is pure white in the light scheme.** Raising
  a toolbar gives you the separator but no tint. The chrome surface has to come
  from `@sidebar_bg_color`.
- **`row.activatable` beats a bare class.** It sets a min-height *and* 10px of
  padding on the row's child box, so a single-line row silently renders at 52px
  until a selector with `row` in it says otherwise.
- **`border-radius: 50%` does not round a 9px box** in GTK's renderer. Use an
  absolute value.
- **`background: currentColor` is not resolved** the way it is on the web. Emit
  real colour values.
- **A header-bar button with no `valign` fills the bar's height**, and
  `min-height` cannot cap it.
- **Icon names are shared between themes; the drawings are not.** Under KDE a
  libadwaita app resolves them from Breeze and ends up mixing two icon
  languages. Pin `gtk-icon-theme-name` to Adwaita at startup.
