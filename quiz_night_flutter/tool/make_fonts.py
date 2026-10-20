"""Builds the bundled fonts in assets/fonts from the google/fonts originals.

Usage (needs `pip install fonttools`):
  1. Download into SRC_DIR from https://github.com/google/fonts/tree/main/ofl :
       bricolagegrotesque/BricolageGrotesque[opsz,wdth,wght].ttf  -> Bricolage.ttf
       figtree/Figtree[wght].ttf                                  -> Figtree.ttf
       notosans/NotoSans[wdth,wght].ttf                           -> NotoSans.ttf
       notosanssymbols2/NotoSansSymbols2-Regular.ttf              -> NotoSansSymbols2.ttf
  2. python make_fonts.py SRC_DIR ../assets/fonts

Each variable font is pinned to static weights and subset to Latin plus the
Nigerian letters (Yoruba, Igbo, Hausa). NotoSansAfr holds only the Nigerian
letters and NotoSansSymbols only the UI symbols (check, cross, arrows, star,
stopwatch); both are per-glyph fallbacks.
"""
import sys, os
from fontTools.ttLib import TTFont
from fontTools.varLib import instancer
from fontTools import subset

src, out = sys.argv[1], sys.argv[2]
# Nigerian letters: Yoruba ẹ ọ ṣ ń + tone marks, Igbo ị ụ ṅ, Hausa ɓ ɗ ƙ ƴ ʼ.
NIGERIAN = ("U+0143-0144,U+0181,U+018A,U+0198-0199,U+01B3-01B4,U+01F8-01F9,U+0253,U+0257,U+02BC,"
            "U+0300-0304,U+0323,U+0329,U+1E3E-1E3F,U+1E44-1E45,U+1E62-1E63,U+1EB8-1EB9,U+1ECA-1ECD,U+1EE4-1EE5")
PUNCT = "U+2013-2014,U+2018-201D,U+2022,U+2026,U+20A6,U+2122,U+2212"
# Primary fonts: Basic Latin, Latin-1, Latin Extended-A (accented vowels) and the Nigerian
# letters they happen to have; anything missing falls back to NotoSansAfr per glyph.
LATIN = "U+0020-007E,U+00A0-017F," + NIGERIAN + "," + PUNCT
AFRICAN = "U+0020," + NIGERIAN + ",U+20A6"

def build(src_file, axes, unicodes, dest):
    font = TTFont(os.path.join(src, src_file))
    if "fvar" in font:
        font = instancer.instantiateVariableFont(font, axes)
    opts = subset.Options()
    opts.layout_features = ['*']          # keep tnum (tabular figures), kern, marks
    opts.name_IDs = ['*']
    opts.notdef_outline = True
    opts.hinting = False                  # Flutter/CanvasKit does not use TT hints
    sub = subset.Subsetter(opts)
    sub.populate(unicodes=subset.parse_unicodes(unicodes))
    sub.subset(font)
    font.save(os.path.join(out, dest))
    print(f"{dest:32} {os.path.getsize(os.path.join(out, dest)):>7} bytes")

build("Bricolage.ttf", {"wght": 800, "wdth": 100, "opsz": 48}, LATIN, "BricolageGrotesque-ExtraBold.ttf")
for w, name in [(400, "Regular"), (700, "Bold"), (800, "ExtraBold")]:
    build("Figtree.ttf", {"wght": w}, LATIN, f"Figtree-{name}.ttf")
for w, name in [(400, "Regular"), (700, "Bold"), (800, "ExtraBold")]:
    build("NotoSans.ttf", {"wght": w, "wdth": 100}, AFRICAN, f"NotoSansAfr-{name}.ttf")
# UI symbols none of the text fonts have: ✓ ✕ ▲ ▼ ★ ⏱ (and their heavy forms).
SYMBOLS = "U+0020,U+2713-2716,U+25B2,U+25BC,U+2605,U+23F1"
build("NotoSansSymbols2.ttf", {}, SYMBOLS, "NotoSansSymbols-Regular.ttf")
