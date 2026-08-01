#!/usr/bin/env python3
"""
Renders assets/demo.gif — an animated replay of a cold-recall session.

Usage:  python3 assets/make_demo.py
Needs:  pillow  (pip install pillow)

Condensed from the real transcript in
examples/session-biology-molecules-of-life.md
"""

import os
import random
from PIL import Image, ImageDraw, ImageFont

random.seed(7)   # reproducible typing rhythm

# ── canvas ───────────────────────────────────────────────────────────────────
W, H = 900, 620
PAD = 26
GUTTER = 14
BAR_H = 42            # title bar
INPUT_H = 54          # composer

# ── palette (dark; reads in both GitHub themes) ──────────────────────────────
BG       = (13, 17, 23)
PANEL    = (22, 27, 34)
COMPOSER = (18, 23, 30)
BUBBLE_U = (31, 41, 55)
BUBBLE_A = (22, 27, 34)
BORDER   = (48, 54, 61)
TEXT     = (222, 228, 236)
DIM      = (139, 148, 158)
FAINT    = (94, 103, 113)
ACCENT   = (233, 143, 74)
GREEN    = (86, 211, 100)
RED      = (248, 113, 113)
BLUE     = (110, 168, 254)


def _font_dir():
    """Locate DejaVu, which is what this design is metric-tuned for."""
    cands = []
    try:                                    # matplotlib bundles DejaVu — most
        import matplotlib                   # portable source, works everywhere
        cands.append(os.path.join(os.path.dirname(matplotlib.__file__),
                                  "mpl-data", "fonts", "ttf"))
    except Exception:
        pass
    cands += [
        "/usr/share/fonts/truetype/dejavu",          # Debian / Ubuntu
        "/usr/share/fonts/dejavu",                   # Fedora / Arch
        "/usr/local/share/fonts/dejavu",
        os.path.expanduser("~/Library/Fonts"),       # macOS
        "/Library/Fonts",
        "C:/Windows/Fonts",                          # Windows
    ]
    for c in cands:
        if os.path.isfile(os.path.join(c, "DejaVuSans.ttf")):
            return c
    raise SystemExit(
        "DejaVu fonts not found.\n"
        "Easiest fix:  pip install matplotlib   (it bundles them)\n"
        "Or install the 'dejavu-fonts' package for your OS."
    )


FONT_DIR = _font_dir()


def font(n, s):
    return ImageFont.truetype(os.path.join(FONT_DIR, n), s)


F_REG   = font("DejaVuSans.ttf", 15)
F_BOLD  = font("DejaVuSans-Bold.ttf", 15)
F_SM    = font("DejaVuSans.ttf", 13)
F_SMB   = font("DejaVuSans-Bold.ttf", 13)
F_MONO  = font("DejaVuSansMono.ttf", 13)
F_TITLE = font("DejaVuSans-Bold.ttf", 14)
F_TINY  = font("DejaVuSans.ttf", 11)
F_INPUT = font("DejaVuSans.ttf", 14)

MAXW = W - 2 * PAD - 110


def wrap(d, text, f, maxw):
    words, lines, cur = text.split(), [], ""
    for w in words:
        t = f"{cur} {w}".strip()
        if d.textlength(t, font=f) <= maxw or not cur:
            cur = t
        else:
            lines.append(cur)
            cur = w
    if cur:
        lines.append(cur)
    return lines


# ── messages ─────────────────────────────────────────────────────────────────
class Msg:
    def __init__(self, who, lines, label=None, label_col=DIM):
        self.who, self.lines = who, lines
        self.label, self.label_col = label, label_col


def measure(d, m, n):
    inner, h = 0, 14
    if m.label:
        h += 20
    for (t, f, c) in m.lines[:n]:
        if t == "":
            h += 8
            continue
        for l in wrap(d, t, f, MAXW - 32):
            inner = max(inner, d.textlength(l, font=f))
            h += f.size + 7
    h += 14
    w = min(MAXW, max(int(inner) + 32, 170))
    if m.label:
        w = max(w, int(d.textlength(m.label, font=F_TINY)) + 40)
    return w, h


def draw_msg(d, m, n, x, y, w, h):
    right = m.who == "user"
    d.rounded_rectangle([x, y, x + w, y + h], radius=12,
                        fill=BUBBLE_U if right else BUBBLE_A,
                        outline=BORDER, width=1)
    if right:
        d.rounded_rectangle([x, y, x + 3, y + h], radius=2, fill=BLUE)
    cy = y + 12
    if m.label:
        d.text((x + 16, cy), m.label, font=F_TINY, fill=m.label_col)
        cy += 20
    for (t, f, c) in m.lines[:n]:
        if t == "":
            cy += 8
            continue
        for l in wrap(d, t, f, MAXW - 32):
            d.text((x + 16, cy), l, font=f, fill=c)
            cy += f.size + 7


def titlebar(d):
    d.rectangle([0, 0, W, BAR_H], fill=PANEL)
    d.line([0, BAR_H, W, BAR_H], fill=BORDER)
    for i, col in enumerate([(255, 95, 86), (255, 189, 46), (39, 201, 63)]):
        d.ellipse([18 + i * 20, 15, 30 + i * 20, 27], fill=col)
    d.text((92, 13), "cold-recall", font=F_TITLE, fill=TEXT)
    d.text((178, 14), "— Biology session", font=F_SM, fill=DIM)
    tag = "vault + anki connected"
    d.text((W - PAD - d.textlength(tag, font=F_TINY), 16), tag,
           font=F_TINY, fill=GREEN)


def composer(d, typed, caret):
    """The message box the user types into."""
    top = H - INPUT_H
    d.rectangle([0, top, W, H], fill=COMPOSER)
    d.line([0, top, W, top], fill=BORDER)
    bx0, by0, bx1, by1 = PAD, top + 9, W - PAD - 46, H - 11
    d.rounded_rectangle([bx0, by0, bx1, by1], radius=9,
                        fill=(26, 32, 40),
                        outline=BLUE if typed else BORDER, width=1)
    tx = bx0 + 14
    ty = by0 + (by1 - by0 - F_INPUT.size) / 2 - 1
    if typed:
        shown = typed
        while d.textlength(shown, font=F_INPUT) > (bx1 - bx0 - 34):
            shown = shown[1:]          # scroll like a real input
        d.text((tx, ty), shown, font=F_INPUT, fill=TEXT)
        cx = tx + d.textlength(shown, font=F_INPUT) + 2
    else:
        d.text((tx, ty), "Message Claude…", font=F_INPUT, fill=FAINT)
        cx = tx
    if caret:
        d.line([cx, by0 + 10, cx, by1 - 10], fill=BLUE, width=2)
    # send button
    sx0, sy0 = W - PAD - 36, top + 11
    on = bool(typed)
    d.rounded_rectangle([sx0, sy0, sx0 + 32, sy0 + 32], radius=9,
                        fill=BLUE if on else (30, 36, 44))
    ar = TEXT if on else FAINT
    cxm, cym = sx0 + 16, sy0 + 16
    d.line([cxm, cym + 7, cxm, cym - 7], fill=ar, width=2)
    d.line([cxm - 6, cym - 1, cxm, cym - 7], fill=ar, width=2)
    d.line([cxm + 6, cym - 1, cxm, cym - 7], fill=ar, width=2)


def render(state, typed="", caret=False, thinking=None):
    """state: [(Msg, nlines)]. thinking: 0..2 = active dot, or None."""
    img = Image.new("RGB", (W, H), BG)
    d = ImageDraw.Draw(img)

    boxes, total = [], 0
    for m, n in state:
        w, h = measure(d, m, n)
        boxes.append((m, n, w, h))
        total += h + GUTTER
    if thinking is not None:
        total += 38 + GUTTER

    top = BAR_H + 16
    avail = H - INPUT_H - top - 14
    y = top if total <= avail else top + (avail - total)

    for (m, n, w, h) in boxes:
        x = W - PAD - w if m.who == "user" else PAD
        if y + h > 0 and y < H:
            draw_msg(d, m, n, x, y, w, h)
        y += h + GUTTER

    if thinking is not None:
        d.rounded_rectangle([PAD, y, PAD + 78, y + 38], radius=12,
                            fill=BUBBLE_A, outline=BORDER, width=1)
        for i in range(3):
            cx = PAD + 22 + i * 17
            r = 4 if i == thinking else 3
            col = TEXT if i == thinking else FAINT
            d.ellipse([cx - r, y + 19 - r, cx + r, y + 19 + r], fill=col)

    titlebar(d)
    composer(d, typed, caret)
    return img


# ── script content ───────────────────────────────────────────────────────────
U1 = "Biology, ~/Resources/Bio/Topic 1, Molecules of Life"
U2 = ("ice floats bc at 0°C the molecules vibrate less so stronger "
      "h bonds form, making it less dense i think")

M_USER1 = Msg("user", [(U1, F_MONO, TEXT)])

M_READBACK = Msg("claude", [
    ("No Biology notes yet — clean slate.", F_REG, TEXT),
    ("", None, None),
    ("Physics  [[Significant Figures]]", F_SMB, TEXT),
    ("learning (2) — 8 days overdue", F_SM, RED),
    ("", None, None),
    ("Today explains your Physics density anchor.", F_SM, BLUE),
], label="READ-BACK  ·  vault + anki", label_col=DIM)

M_ASK = Msg("claude", [
    ("I'm not teaching a thing until I know", F_REG, TEXT),
    ("what's actually missing.", F_REG, TEXT),
    ("", None, None),
    ("Why does ice float? Give me the causal", F_BOLD, TEXT),
    ("chain — structure to consequence. Not", F_BOLD, TEXT),
    ("the conclusion.", F_BOLD, TEXT),
    ("", None, None),
    ("\"I don't know\" is a valid answer.", F_SM, DIM),
], label="RETRIEVAL FIRST — COLD", label_col=ACCENT)

M_USER2 = Msg("user", [
    ("ice floats bc at 0°C the molecules vibrate", F_REG, TEXT),
    ("less so stronger h bonds form, making it", F_REG, TEXT),
    ("less dense i think", F_REG, TEXT),
])

M_CAUGHT = Msg("claude", [
    ("Right answer. Broken route.", F_BOLD, TEXT),
    ("", None, None),
    ("Does cooling the room change the", F_REG, TEXT),
    ("electronegativity of oxygen?", F_REG, TEXT),
    ("", None, None),
    ("Bond strength is a property of the", F_BOLD, ACCENT),
    ("bond, not of the temperature.", F_BOLD, ACCENT),
    ("", None, None),
    ("You were one word away — you said", F_SM, DIM),
    ("\"vibrate less\" and walked straight", F_SM, DIM),
    ("past it. Finish the thought.", F_SM, DIM),
], label="✗  WRONG ROUTE, RIGHT ANSWER", label_col=RED)

M_COMMIT = Msg("claude", [
    ("4 notes written.   0 cards.", F_BOLD, TEXT),
    ("", None, None),
    ("[[Hydrogen Bonding]]      learning (2)", F_MONO, DIM),
    ("[[Properties of Water]]   learning (2)", F_MONO, DIM),
    ("[[Surface Tension]]       learning (1)", F_MONO, DIM),
    ("", None, None),
    ("Nothing is solid. Every conclusion you", F_REG, TEXT),
    ("reached came by a flawed route.", F_REG, TEXT),
    ("", None, None),
    ("The vault is not going to flatter you.", F_BOLD, ACCENT),
], label="COMMITTED  ·  vault updated", label_col=GREEN)

for m in (M_USER1, M_READBACK, M_ASK, M_USER2, M_CAUGHT, M_COMMIT):
    m.lines = [(t, f or F_REG, c or TEXT) for (t, f, c) in m.lines]


# ── timeline builder ─────────────────────────────────────────────────────────
class Reel:
    def __init__(self):
        self.frames, self.durs, self.state = [], [], []

    def push(self, img, ms):
        self.frames.append(img)
        self.durs.append(ms)

    def idle(self, ms, blinks=0):
        if blinks:
            for _ in range(blinks):
                self.push(render(self.state, "", True), 380)
                self.push(render(self.state, "", False), 380)
        else:
            self.push(render(self.state, "", False), ms)

    def type(self, text, cps=3):
        """Type into the composer with a human-ish rhythm."""
        i = 0
        while i < len(text):
            i = min(len(text), i + cps)
            ch = text[i - 1]
            ms = 150 if ch in ",." else (95 if ch == " " else 60)
            ms += random.randint(-12, 22)
            self.push(render(self.state, text[:i], True), ms)
        self.push(render(self.state, text, True), 480)   # beat before send

    def send(self, msg):
        self.state.append([msg, len(msg.lines)])
        self.push(render(self.state, "", False), 420)

    def think(self, cycles=2):
        for _ in range(cycles):
            for k in range(3):
                self.push(render(self.state, "", False, thinking=k), 170)

    def reveal(self, msg, hold):
        self.state.append([msg, 0])
        for n in range(1, len(msg.lines) + 1):
            self.state[-1][1] = n
            blank = msg.lines[n - 1][0] == ""
            self.push(render(self.state), 20 if blank else 58)
        self.push(render(self.state), hold)


def build():
    r = Reel()
    r.idle(0, blinks=1)
    r.type(U1)
    r.send(M_USER1)
    r.think(2)
    r.reveal(M_READBACK, 1700)
    r.reveal(M_ASK, 2200)
    r.idle(0, blinks=1)
    r.type(U2, cps=4)
    r.send(M_USER2)
    r.think(2)
    r.reveal(M_CAUGHT, 2900)
    r.think(1)
    r.reveal(M_COMMIT, 3400)
    r.idle(2200)
    return r.frames, r.durs


if __name__ == "__main__":
    frames, durs = build()
    out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "demo.gif")
    pal = [f.convert("P", palette=Image.ADAPTIVE, colors=48) for f in frames]
    pal[0].save(out, save_all=True, append_images=pal[1:],
                duration=durs, loop=0, optimize=True, disposal=2)
    print(f"wrote {out}  ({len(frames)} frames, {sum(durs)/1000:.1f}s, "
          f"{os.path.getsize(out)/1e6:.2f} MB)")
