# Diamonds 38

The Diamonds game from the HP 38G graphing calculator, ported to run in a web browser.

**Play it: https://www.msawtell.com/diamonds/**

Ported by [Martin Sawtell](https://www.msawtell.com/).

We played this on our HP 38Gs in high school. This port runs the original game in a browser, on a
green monochrome 131 x 64 LCD like the calculator's.

## Original authors

Diamonds 38 was written by **Douglas R. Cannon**, who wrote Diamonds for the HP48 in 1993 and ported
it to the HP 38G in 1996-97, and **Detlef Mueller**, who finished the HP 38G aplet and released it in
1998. Their version is based on **Oliver Dreer's** Diamonds for the Macintosh. Paul Hart converted the
source to SASM format, and Jim Donnelly and Jean-Yves Avenard helped with the HP 38G conversion.

The original game and its source code were downloaded from hpcalc.org:
https://www.hpcalc.org/details/529

They released it as freeware with source. From `diam38/DIAM38.TXT`:

> Diamonds 38 is freeware. You have the game, you have the source code. You can play it, you can
> modify it, you can give it away, you can sell it. Just be sure that you have fun with it.

All credit for the game design, the 50 levels, the graphics and the sounds goes to them. This port is
shared on the same terms.

## How the port works

It is not an emulator. Emulating the calculator would need HP's ROM, which can't be redistributed.
The game itself is self-contained Saturn assembly that only touches the screen memory, the keyboard
and a hardware timer, so `web/diamonds.js` is a routine-by-routine translation of `src/DIAM38.S` into
JavaScript:

- The screen is modelled as the calculator's own display memory (34 nibbles per row), so the ball's
  pixel-mask collisions and bounce rules behave exactly like the original.
- Frame timing uses the original's timer delays (8192 ticks per second).
- The levels and all graphics (bricks, ball, menu, help screen, banners, score digits) are pulled
  straight out of the source's `NIBHEX` data by `tools/extract.py`, which writes `web/data.js`.
- The beeps are rebuilt as square waves from the original's speaker-toggling delay loops.

Two things are approximations: the fonts on the "Press ENTER" start screen (the calculator's ROM
fonts aren't in the source), and the speed of the fastest setting, SUPER, which depended on how fast
the calculator's CPU was.

## Running it

`web/` is a static site with no build step and no dependencies. Serve the folder with any web server,
for example:

```
cd web && python3 -m http.server 8000
```

then open http://localhost:8000/. To regenerate `web/data.js` from the assembly source, run
`python3 tools/extract.py`.

## Controls

| Key | Action |
|---|---|
| Enter / Space | Start, then pause and resume during a game |
| A, B, C | Menu: play, change speed, show keys |
| Left / Right | Steer the ball |
| Backspace | Restart the level (costs a life) |
| Shift | Give up the current game |
| M or - | Sound on/off |
| Esc | Exit (the calculator's ON key) |

There's an on-screen keypad for phones. The original's cheat code still works: read the comments
in `src/DIAM38.S` near the "Myths and Rumors" section.

## Files

- `web/`: the browser version (`index.html`, `diamonds.js`, generated `data.js`)
- `src/`: the original Saturn assembly source (line endings converted to LF)
- `diam38/`, `diam38.zip`: the original release as downloaded from hpcalc.org (`DIAM38.TXT` converted to LF)
- `tools/extract.py`: pulls the levels and graphics out of the assembly source
