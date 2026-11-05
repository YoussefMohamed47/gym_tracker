"""Generate the LiftFuel splash Lottie (512x512, 60fps, ~1.9s).

Usage: python3 tool/generate_splash_lottie.py assets/animations/splash_logo.json

Frames 0-34: tile pops in, bolt drops in. From frame NATIVE_FRAME the logo is
still (tile + bolt only): that frame is what the native splash shows, and the
Flutter splash starts playing from it, so the hand-over is seamless.
Then the ring draws itself and pulses out.
"""
import json, sys

FPS = 60
OP = 112  # ~1.9 s
NATIVE_FRAME = 35  # tile + bolt settled, ring not started
W = H = 512
C = [W / 2, H / 2, 0]

LIME = [0.780, 0.957, 0.463, 1]     # #C7F476
MINT = [0.463, 0.867, 0.671, 1]     # #76DDAB
DARK = [0.035, 0.055, 0.071, 1]     # #090E12

EASE_OUT = {"o": {"x": [0.25], "y": [0]}, "i": {"x": [0.2], "y": [1]}}
OVERSHOOT = {"o": {"x": [0.3], "y": [0]}, "i": {"x": [0.35], "y": [1.45]}}


def static(v):
    return {"a": 0, "k": v}


def anim(frames, ease=EASE_OUT):
    """frames: list of (t, value). Last keyframe holds."""
    ks = []
    for idx, (t, v) in enumerate(frames):
        k = {"t": t, "s": v if isinstance(v, list) else [v]}
        if idx < len(frames) - 1:
            k.update(ease)
        ks.append(k)
    return {"a": 1, "k": ks}


def transform(p=None, s=None, r=None, o=None, a=None):
    return {
        "o": o or static(100),
        "r": r or static(0),
        "p": p or static(C),
        "a": a or static([0, 0, 0]),
        "s": s or static([100, 100, 100]),
    }


def group(name, items):
    return {
        "ty": "gr", "nm": name,
        "it": items + [{
            "ty": "tr", "p": static([0, 0]), "a": static([0, 0]),
            "s": static([100, 100]), "r": static(0), "o": static(100),
            "sk": static(0), "sa": static(0),
        }],
    }


def layer(ind, name, shapes, ks, ip=0, op=OP):
    return {
        "ddd": 0, "ind": ind, "ty": 4, "nm": name, "sr": 1,
        "ks": ks, "ao": 0, "shapes": shapes,
        "ip": ip, "op": op, "st": 0, "bm": 0,
    }


fill = lambda c: {"ty": "fl", "c": static(c), "o": static(100), "r": 1}
stroke = lambda c, w, o=static(100): {
    "ty": "st", "c": static(c), "o": o, "w": static(w), "lc": 2, "lj": 2}

bolt_pts = [[14, -70], [-42, 8], [-5, 8], [-17, 70], [42, -11], [5, -11]]
bolt = {
    "ty": "sh",
    "ks": static({
        "c": True, "v": bolt_pts,
        "i": [[0, 0]] * len(bolt_pts), "o": [[0, 0]] * len(bolt_pts),
    }),
}

layers = [
    # 1. Bolt on top: drops in after the tile lands.
    layer(1, "bolt", [group("bolt", [bolt, fill(DARK)])], transform(
        p=anim([(16, [W / 2, H / 2 - 40, 0]), (34, C)]),
        s=anim([(16, [40, 40, 100]), (34, [100, 100, 100])], OVERSHOOT),
        o=anim([(16, 0), (24, 100)]),
    ), ip=16),
    # 2. Lime tile: pops in with a little turn.
    layer(2, "tile", [group("tile", [
        {"ty": "rc", "p": static([0, 0]), "s": static([220, 220]), "r": static(58)},
        fill(LIME),
    ])], transform(
        s=anim([(0, [0, 0, 100]), (22, [100, 100, 100])], OVERSHOOT),
        r=anim([(0, -18), (22, 0)]),
    )),
    # 3. Ring that draws itself around the tile.
    layer(3, "ring-draw", [group("ring", [
        {"ty": "el", "p": static([0, 0]), "s": static([300, 300])},
        stroke(LIME, 8),
        {"ty": "tm", "s": static(0), "e": anim([(36, 0), (70, 100)]),
         "o": static(-90), "m": 1},
    ])], transform(r=anim([(36, -40), (70, 0)])), ip=36),
    # 4. Pulse: the finished ring expands and fades.
    layer(4, "ring-pulse", [group("pulse", [
        {"ty": "el", "p": static([0, 0]), "s": static([300, 300])},
        stroke(MINT, 6, anim([(70, 90), (106, 0)])),
    ])], transform(s=anim([(70, [100, 100, 100]), (106, [150, 150, 100])])),
        ip=70),
]

doc = {
    "v": "5.7.4", "fr": FPS, "ip": 0, "op": OP, "w": W, "h": H,
    "nm": "LiftFuel splash", "ddd": 0, "assets": [], "layers": layers,
}

out = sys.argv[1]
with open(out, "w") as f:
    json.dump(doc, f, separators=(",", ":"))
print("wrote", out)
