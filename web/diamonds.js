// Diamonds 38 -- JavaScript port of the HP 38G aplet by Doug Cannon / Detlef Mueller.
// Routine-by-routine transliteration of src/DIAM38.S. The screen is modelled exactly as
// the calculator's display memory (34 nibbles per row, low bit = leftmost pixel), so the
// ball's pixel-mask collision and bounce rules behave like the original.
'use strict';

(() => {
  // ---------------------------------------------------------------- data
  const G = {};
  for (const k in DIAMONDS_DATA) G[k] = Uint8Array.from(DIAMONDS_DATA[k], c => parseInt(c, 16));

  const W = 34;                 // nibbles per display row (136 px, 131 visible)
  const FIELD = 0x45;           // nibble address of the playing field (x=4, y=2)
  const TICK = 1000 / 8192;     // ms per TIMER2 tick
  const T_IT = 10.5e-6;         // s per countdown-loop iteration (calibrated from the sound-off delays)
  const SLOW = 0xF0, NORMAL = 0xA0, FAST = 0x50, SPEED_UP = 0x50;
  const BONUS_TIME = 0x70, NLEVELS = G.levels[0] + 16 * G.levels[1];
  const FRAME_CPU = 20;         // ticks: estimated CPU time per frame (only matters at SUPER speed)
  const WA_UNIT = 40;           // ticks per waWAIT iteration ("#000CC is about 1 second")
  const RELEASE_MAX = 600;      // ms cap on the "wait until they stop pressing" loops

  const scr = new Uint8Array(W * 64);
  const buf = new Uint8Array(24 * 60);

  const rd = (a, at, n) => { let v = 0; for (let i = n - 1; i >= 0; i--) v = v * 16 + a[at + i]; return v; };
  const wr = (a, at, n, v) => { for (let i = 0; i < n; i++) { a[at + i] = v & 15; v >>>= 4; } };
  const blit = (src, off, at, w, lines) => {
    for (let l = 0; l < lines; l++) for (let k = 0; k < w; k++) scr[at + l * W + k] = src[off + l * w + k];
  };

  const BALL = [0, 1, 2, 3, 4].map(l => rd(G.ball, l * 2, 2));
  const dbMask = (i, l) => rd(G.dbMasks, i * 15 + l * 3, 3);
  const cbMask = (i, l) => rd(G.cbMasks, i * 15 + l * 3, 3);

  // ---------------------------------------------------------------- input
  const down = new Set();
  let latch = new Set();        // keys pressed since the last sleep, so short taps are never missed
  const held = k => down.has(k) || latch.has(k);
  const anyHeld = () => { for (const s of [down, latch]) for (const k of s) if (k !== 'ON') return true; return false; };

  // ---------------------------------------------------------------- clock
  // Game logic runs on a virtual clock (ms) and sleeps whenever it gets ahead of real time.
  const EXIT = { exit: true };
  const t0 = performance.now();
  const now = () => performance.now() - t0;
  const sleep = ms => new Promise(r => setTimeout(r, ms));
  let vt = 0, frameStart = 0, running = false;

  async function advance(ms) {
    vt += ms;
    let lag = vt - now();
    if (lag < -250) { vt = now(); lag = 0; }          // tab was hidden: drop the missed time
    if (lag > 0.5) { latch = new Set(); await sleep(lag); }
    if (running && held('ON')) throw EXIT;
  }
  async function udDelay(n) { await advance((n + 1) * TICK); frameStart = vt; }
  async function waWait(n) {     // delay, returns true early if a key is pressed
    for (let i = 0; i <= n; i++) {
      await advance(WA_UNIT * TICK);
      frameStart = vt;
      if (anyHeld()) return true;
    }
    return false;
  }
  async function waitRelease(maxMs = Infinity) {
    const end = vt + maxMs;
    while (anyHeld() && vt < end) await advance(5);
  }

  // ---------------------------------------------------------------- sound
  // Each routine toggled the beeper from countdown loops; we rebuild the same square waves.
  let actx = null, soundOn = true;
  try { soundOn = localStorage.getItem('diamonds38.sound') !== 'off'; } catch (e) { /* storage blocked */ }
  const rep = (n, h, l) => Array.from({ length: n }, () => [h, l]);
  const SOUNDS = {
    wall: () => rep(9, 0x51, 0x29),
    brick: () => rep(8, 0x21, 0x41),
    mode: () => rep(17, 0x71, 0x21),
    diamond: () => { const s = []; for (let d = 0x66; d > 0x50; d--) s.push([d + 1, 0x66 - d + 1]); return s; },
    dead: () => { let s = []; for (let d = 0x90; d !== 0x100; d += 2) s = s.concat(rep(3, d + 1, 0x21)); return s; },
    darrow: () => { let s = [], d = 0x80; do { s = s.concat(rep(3, d + 1, 0x11)); d -= 4; } while (d > 0x50); return s; },
    key: () => {
      let s = [], d = 0x21;
      for (;;) { s = s.concat(rep(4, d + 1, d + 1)); if (d < 0x30) { d += 16; if (d === 0x34) return s; } else d -= 15; }
    },
    lock: () => {
      let s = [], d = 0x90;
      for (;;) { s = s.concat(rep(9, d + 1, d + 1)); if (d < 0x90) d += 0x51; else { d -= 0x50; if (d === 0x41) return s; } }
    },
    bonus: () => { const s = []; for (let i = 0, b = 0x60; i < 17; i++, b -= 2) s.push([b + 1, b - 0x20 + 1]); return s; },
    life: () => {
      let s = [];
      for (let d = 0x15; d >= 1; d--) s = s.concat(rep(4, d + 1, d + 1));
      for (let d = 1; d <= 0x14; d++) s = s.concat(rep(4, d + 1, d + 1));
      return s;
    },
    menuUp: () => { let s = [], d = 0x60; do { s = s.concat(rep(5, d + 1, d + 1)); d -= 4; } while (d > 0x20); return s; },
    menuDown: () => { let s = [], d = 0x20; do { s = s.concat(rep(5, d + 1, d + 1)); d += 4; } while (d < 0x60); return s; },
    myth: () => {
      let s = [], d = 0x21, a = 0;
      for (;;) { s = s.concat(rep(4, d + 1, d + 1)); if (d < 0x30) { d += 16; a++; if (a >= 0x30) return s; } else d -= 14; }
    },
    tune: () => { let s = []; for (let d = 0x80; d !== 0; d -= 0x10) s = s.concat(rep(25, d + 1, d + 1)); return s; },
    blip: () => rep(33, 0x13, 0xF),
  };
  const sndCache = {};

  function audioInit() {
    if (!actx) { try { actx = new (window.AudioContext || window.webkitAudioContext)(); } catch (e) { return; } }
    if (actx.state === 'suspended') actx.resume();
  }
  function soundBuffer(name) {
    if (sndCache[name]) return sndCache[name];
    const segs = SOUNDS[name](), sr = actx.sampleRate;
    let total = 0;
    for (const [h, l] of segs) total += h + l;
    const n = Math.ceil(total * T_IT * sr) + 1;
    const b = actx.createBuffer(1, n, sr), d = b.getChannelData(0);
    let t = 0, y = 0;
    for (const [h, l] of segs) {
      const a = Math.floor(t * T_IT * sr), m = Math.floor((t + h) * T_IT * sr), e = Math.floor((t + h + l) * T_IT * sr);
      for (let i = a; i < m; i++) d[i] = 1;
      for (let i = m; i < e; i++) d[i] = -1;
      t += h + l;
    }
    for (let i = 0; i < n; i++) { y += (d[i] - y) * 0.45; d[i] = y * 0.13; }   // soften the edges a touch
    return (sndCache[name] = { buf: b, ms: total * T_IT * 1000 });
  }
  function play(name) {
    let ms = 0;
    for (const [h, l] of SOUNDS[name]()) ms += (h + l) * T_IT * 1000;
    if (!actx) return ms;
    const s = soundBuffer(name), src = actx.createBufferSource();
    src.buffer = s.buf;
    src.connect(actx.destination);
    src.start(Math.max(actx.currentTime, actx.currentTime + (vt - now()) / 1000));
    return ms;
  }
  async function snd(name, offTicks = null) {   // offTicks: the delay the original used with sound off
    if (soundOn) await advance(play(name));
    else if (offTicks !== null) await udDelay(offTicks);
  }
  function toggleSound() {
    soundOn = !soundOn;
    try { localStorage.setItem('diamonds38.sound', soundOn ? 'on' : 'off'); } catch (e) { /* ignore */ }
    if (soundOn) play('blip');
  }

  // ---------------------------------------------------------------- state
  const S = {
    x: 0, y: 0, dir: 0, pos: 0, sh: 0, lvl: null,
    mode: 1, bricks: 0, diamonds: 0, speed: NORMAL, speedToggle: NORMAL, level: 0,
    lives: 0, score: 0, nextLife: 5000, bonusTime: BONUS_TIME, myth: 0,
    st1: false, st2: false, rev: false, dead: false, won: false, st6: false, key: false, erase: false,
    paused: false, screen: 'entry',
  };
  const levelData = i => G.levels.subarray(5 + i * 85, 5 + (i + 1) * 85);

  // ---------------------------------------------------------------- static screens
  function isInitScn() {
    scr[0] = 8; scr.fill(15, 1, 25);
    scr[W] = 12; scr.fill(15, W + 1, W + 25);
    for (let r = 2; r < 62; r++) scr[r * W] = 12;
    scr[62 * W] = 12; scr.fill(15, 62 * W + 1, 62 * W + 25);
    scr[63 * W] = 8; scr.fill(15, 63 * W + 1, 63 * W + 25);
    for (let r = 0; r < 64; r++) for (let k = 0; k < 8; k++) scr[r * W + 25 + k] = G.panel[r * 8 + k];
  }
  function cfClear() { for (let r = 0; r < 60; r++) scr.fill(0, FIELD + r * W, FIELD + r * W + 24); }
  function dmDrawMenu() {
    blit(G.menu, 0, 0x67, 24, 58);
    const i = S.speedToggle === SLOW ? 0 : S.speedToggle === NORMAL ? 1 : S.speedToggle === FAST ? 2 : 3;
    blit(G.speed, i * 40, 0x5E5, 8, 5);
  }
  const dmDrawHelp = () => blit(G.help, 0, 103, 24, 55);

  // ---------------------------------------------------------------- status panel
  function scDraw(score) {
    const T = G.score, d = [0, 1, 2, 3, 4].map(i => Math.floor(score / 10 ** i) % 10);
    for (let L = 0; L < 6; L++) {
      const b = L * 70;
      let v = T[b + d[0]] << 8;
      v = (v | rd(T, b + 10 + 2 * d[1], 2)) << 4;
      v = (v | rd(T, b + 30 + 2 * d[2], 2)) << 4;
      v |= rd(T, b + 50 + 2 * d[3], 2);
      wr(scr, 0x5F + L * W, 5, v);
      scr[0x5E + L * W] = T[b + d[4]];
    }
  }
  async function addScore(n) {
    S.score = (S.score + n) % 100000;
    await scDisp();
  }
  async function scDisp() {
    scDraw(S.score);
    if (S.nextLife > S.score) return;
    S.nextLife = Math.min(S.nextLife + 5000, 99999);
    S.lives++;
    dlDrawLives();
    await snd('life');
  }
  function deDrawLevel() {
    const T = G.levelNum, lev = S.level + 1, d0 = lev % 10, d1 = Math.floor(lev / 10) % 10;
    for (let L = 0; L < 6; L++) {
      const b = L * 40;
      wr(scr, 0x1B6 + L * W, 3, (rd(T, b + 2 * d0, 2) << 4) | rd(T, b + 20 + 2 * d1, 2));
    }
  }
  function dlDrawLives() {
    let b = S.lives - 1;
    if (b > 4) b = 3;
    const mask = b <= 0 ? 0 : 2 ** (7 * b) - 1;
    for (let l = 0; l < 5; l++) wr(scr, 0x7CE + l * W, 7, rd(G.lives, l * 7, 7) & mask);
    if (S.lives - 1 >= 5) [0x08, 0x08, 0x3E, 0x08, 0x08].forEach((v, l) => wr(scr, 0x7D3 + l * W, 2, v));
  }
  function hbDrawKey() {
    for (let l = 0; l < 4; l++) wr(scr, 0x508 + l * W, 3, S.key ? rd(G.key, l * 3, 3) : 0);
  }
  function emDrawBrick(b) { blit(G.bricks, b * 18, 0x4E2, 3, 6); }
  function beBonusDraw() { wr(scr, 0x3F4, 7, 0x7FFFFFF); wr(scr, 0x3F4 + W, 7, 0x7FFFFFF); }
  function beBonusErs() {
    const v = ((rd(scr, 0x3F4, 7) & 0x3FFFFFF) >>> 1) | 0x4000000;
    wr(scr, 0x3F4, 7, v); wr(scr, 0x3F4 + W, 7, v);
    return (v & 0xFFFFF) !== 0;
  }

  // ---------------------------------------------------------------- bricks
  function dsDrawScn() {
    S.bricks = 0; S.diamonds = 0;
    for (let c = 0; c < 8; c++) for (let r = 0; r < 10; r++) {
      const b = S.lvl[5 + c * 10 + r];
      if (b === 1) S.bricks++;
      if (b === 2) S.diamonds++;
      if ((b & 8) && !(b & 1)) S.bricks++;
      for (let l = 0; l < 6; l++) for (let k = 0; k < 3; k++) buf[(r * 6 + l) * 24 + c * 3 + k] = G.bricks[b * 18 + l * 3 + k];
    }
  }
  function dsQuickDraw() {
    dsDrawScn();
    for (let r = 0; r < 60; r++) for (let k = 0; k < 24; k++) scr[FIELD + r * W + k] = buf[r * 24 + k];
  }
  async function sdDisolve() {
    dsDrawScn();
    cfClear();
    for (let i = 0; i < 0x500; i++) {
      const off = 2 * Math.floor(Math.random() * 0x2D0);
      if (buf[off] | buf[off + 1]) {
        const a = FIELD + Math.floor(off / 24) * W + (off % 24);
        scr[a] = buf[off]; scr[a + 1] = buf[off + 1];
        buf[off] = buf[off + 1] = 0;
      }
      if ((i & 15) === 15) await advance(16 * 0.45);
    }
    for (let r = 0; r < 60; r++) for (let k = 0; k < 24; k++) if (buf[r * 24 + k]) scr[FIELD + r * W + k] = buf[r * 24 + k];
  }
  function hbErsBrick(row, col) {
    let a = row * 0xCC + col * 3 + FIELD;
    for (let l = 0; l < 6; l++, a += W) scr.fill(0, a, a + 3);
  }

  // ---------------------------------------------------------------- ball movement
  async function mvMove() {
    for (let depth = 0; ; depth++) {
      const d = S.dir;
      let tx = S.x, ty = S.y;
      if ((d & 1) && ty > 0) ty--;
      if ((d & 2) && ty + 1 < 0x3C) ty++;
      if ((d & 4) && tx > 0) tx--;
      if ((d & 8) && tx + 1 < 0x7F) tx++;
      const pos = (tx >> 2) + ty * W, sh = tx & 3;
      S.pos = pos; S.sh = sh;
      if (!S.erase) {
        if (depth > 24) return;          // boxed in: the original would recurse until RSTK overflowed
        const r = await cbChkBounce(pos, sh);
        if (r === 'stop') return;
        if (r === 'again') continue;
      }
      S.x = tx; S.y = ty;
      for (let l = 0; l < 5; l++) {
        const a = pos + l * W, v = BALL[l] << sh, c = rd(scr, a, 2);
        wr(scr, a, 2, S.erase ? c & ~v : c | v);
      }
      // erase the trailing edge of the previous ball position
      let a, m;
      if (d & 1) { a = pos + W; if (d & 4) m = 1; else if (d & 8) { m = 2; a--; } else m = 0; }
      else if (d & 2) { a = pos - W; if (d & 4) m = 4; else if (d & 8) { m = 5; a--; } else m = 3; }
      else return;
      for (let l = 0; l < 5; l++, a += W) wr(scr, a, 3, rd(scr, a, 3) & ~(dbMask(m, l) << sh));
      return;
    }
  }

  async function cbChkBounce(pos, sh) {
    const d = S.dir;
    const mi = (d & 1) ? ((d & 8) ? 4 : (d & 4) ? 5 : 3) : ((d & 8) ? 1 : (d & 4) ? 2 : 0);
    const hit = [];
    for (let l = 0; l < 5; l++) hit[l] = rd(scr, pos + l * W, 3) & (cbMask(mi, l) << sh);
    let r3 = d, bounced = false;
    for (let D = 4; D >= 0; D--) {
      const c = hit[4 - D];
      if (c) { bounced = true; r3 = boBounce(d, r3, c, D, sh); }
    }
    if (!bounced) return 'ok';
    S.st1 = true;
    S.dir = r3;
    await hbHitBrick(pos, hit);
    return (S.dead || S.won) ? 'stop' : 'again';
  }

  // a = direction before the bounce, r3 = new direction being built, D = 4 - (ball line hit)
  function boBounce(a, r3, c, D, sh) {
    const U = () => { r3 = (r3 & 0xC) | 1; }, Dn = () => { r3 = (r3 & 0xC) | 2; };
    const L = () => { r3 = (r3 & 3) | 4; }, R = () => { r3 = (r3 & 3) | 8; };
    const x = c >> sh;
    if (a & 1) {
      if (a & 4) {                                    // up-left
        if (D === 4) Dn();
        else if (D === 3) { if (x & 2) { Dn(); R(); } else if (x & 1) R(); }
        else if (D !== 0) R();
      } else if (a & 8) {                             // up-right
        if (D === 4) Dn();
        else if (D === 3) { if (x & 8) { Dn(); L(); } else if (x & 16) L(); }
        else if (D !== 0) L();
      } else {                                        // up
        if (D === 4) Dn();
        else if (x & 1) { Dn(); R(); } else if (x & 16) { Dn(); L(); }
      }
    } else if (a & 2) {
      if (a & 4) {                                    // down-left
        if (D === 0) U();
        else if (D === 1) { if (x & 2) { U(); R(); } else if (x & 1) R(); }
        else R();
      } else if (a & 8) {                             // down-right
        if (D === 0) U();
        else if (D === 1) { if (x & 8) { U(); L(); } else if (x & 16) L(); }
        else L();
      } else {                                        // down
        if (D === 0) U();
        else if (x & 1) { U(); R(); } else if (x & 16) { U(); L(); }
      }
    }
    return r3;
  }

  async function hbHitBrick(pos, h) {
    if (h[0]) { await hbOut(pos, h[0]); if (S.dead) return; if (h[3]) await hbOut(pos + 3 * W, h[3]); return; }
    if (h[4]) { await hbOut(pos + 4 * W, h[4]); if (S.dead) return; if (h[1]) await hbOut(pos + W, h[1]); return; }
    if (h[1]) return hbOut(pos + W, h[1]);
    if (h[2]) return hbOut(pos + 2 * W, h[2]);
    if (h[3]) return hbOut(pos + 3 * W, h[3]);
  }
  function hbOut(a, c) {
    if (!(c & 0xF)) a += (c & 0xF0) ? 1 : 2;
    return hbHit(a);
  }

  async function hbHit(a) {
    const off = a - FIELD;
    if (off < 0) return hbWall();
    const row = Math.floor(off / W), col = Math.floor((off % W) / 3);
    if (col > 7) return hbWall();
    const brow = Math.floor(row / 6);
    if (brow > 9) return hbWall();
    const b = S.lvl[5 + col * 10 + brow];
    if (!b) return hbWall();

    if (b === S.mode) {                               // regular / white brick in the right mode
      if (--S.bricks === 0) S.st6 = true;
      hbErsBrick(brow, col);
      await addScore(3);
      return snd('brick', 0x42);
    }
    if (S.st6 && b === 2) {                           // diamond
      if (--S.diamonds === 0) S.won = true;
      hbErsBrick(brow, col);
      await snd('diamond', 0xE2);
      return addScore(100);
    }
    if (b & 8) {
      if ((b & 1) && b - 1 !== S.mode) {              // paintbrush: change erase mode
        S.mode = b - 1;
        emDrawBrick(S.mode);
        return snd('mode', 0xE2);
      }
      return hbWall();
    }
    if (!(b & 4)) return hbWall();                    // white/diamond/wall acting as a wall
    if (!(b & 2)) {
      if (b & 1) {                                    // lock
        if (!S.key) return hbWall();
        S.key = false; hbErsBrick(brow, col); hbDrawKey();
        await snd('lock', 0x42);
        return addScore(50);
      }
      if (S.key) return hbWall();                     // key (only one at a time)
      S.key = true; hbErsBrick(brow, col); hbDrawKey();
      await snd('key', 0x42);
      return addScore(25);
    }
    if (!(b & 1)) return hbDead();                    // cross
    S.rev = !S.rev;                                   // double arrow
    hbErsBrick(brow, col);
    return snd('darrow', 0x42);
  }

  const hbWall = () => snd('wall', 0x5E);

  async function hbDead() {
    S.dir = 0; S.erase = true; await mvMove(); S.erase = false;
    if (!S.myth) {
      S.lives--;
      if (S.lives === 0) blit(G.gameOver, 0, 0x334, 18, 15);
    }
    if (soundOn) await snd('dead');
    else { await waitRelease(RELEASE_MAX); await waWait(0xCC); }
    S.dead = true;
  }

  // ---------------------------------------------------------------- banners
  async function grGetReady() {
    const save = [];
    for (let l = 0; l < 15; l++) for (let k = 0; k < 18; k++) save.push(scr[0x334 + l * W + k]);
    blit(G.getReady, 0, 0x334, 18, 15);
    await waitRelease(RELEASE_MAX);
    await waWait(0x198);
    await waitRelease(RELEASE_MAX);
    blit(save, 0, 0x334, 18, 15);
  }

  async function cnCongrats() {
    if (soundOn) { await waWait(0x66); await snd('tune'); }
    await waWait(0x66);
    if (scr[0x3F4] & 1) {
      blit(G.bonus, 0, 0x337, 12, 15);
      for (;;) {
        const more = beBonusErs();
        await addScore(25);
        await snd('bonus', 0xD7);
        if (!more) break;
        await udDelay(0xC0);
      }
    } else blit(G.noBonus, 0, 0x335, 16, 15);
    await waWait(0x132);
  }

  // ---------------------------------------------------------------- main loops
  async function meMainEvent() {
    S.st1 = S.st2 = S.rev = S.dead = S.won = S.erase = false;
    if (held('J') && held('O') && held('E')) { S.myth = 1; await snd('myth'); }   // the "myth"
    frameStart = vt;
    for (;;) {
      if (held('SHIFT')) { S.myth = 0; S.lives = 1; await hbDead(); return; }
      if (held('DEL')) { S.dead = true; await hbDead(); return; }
      if (held('ENTER')) {
        while (held('ENTER')) await advance(5);
        S.paused = true;
        while (!anyHeld()) await advance(10);
        S.paused = false;
        await waitRelease();
      }
      let chk;
      if (!S.st1) chk = true;
      else if (S.st2) { S.st1 = false; chk = true; }
      else { S.st2 = true; chk = false; }
      if (chk) {
        S.st2 = false;
        if (held('LEFT')) S.dir = (S.dir & 3) | (S.rev ? 8 : 4);
        else if (held('RIGHT')) S.dir = (S.dir & 3) | (S.rev ? 4 : 8);
        else S.dir &= 3;
      }
      await mvMove();
      if (S.dead || S.won) return;
      if (--S.bonusTime === 0) { S.bonusTime = BONUS_TIME; beBonusErs(); }
      const target = frameStart + (Math.max(S.speed, FRAME_CPU) + 1) * TICK;
      await advance(Math.max(0, target - vt));
      frameStart = vt;
    }
  }

  function nextLevel() {
    if (++S.level >= NLEVELS) {
      S.speed -= SPEED_UP;
      if (S.speed < 0) S.speed = 1;
      S.level = 0;
    }
  }

  async function game() {
    S.speed = S.speedToggle; S.lives = 5; S.nextLife = 5000; S.level = 0; S.score = 0;
    await scDisp();
    let fresh = true;
    for (;;) {
      if (fresh) { S.lvl = levelData(S.level); deDrawLevel(); beBonusDraw(); await sdDisolve(); }
      else dsQuickDraw();
      S.st6 = false; S.key = false; hbDrawKey();
      S.mode = 1; emDrawBrick(1);
      S.bonusTime = BONUS_TIME;
      dlDrawLives();
      S.x = S.lvl[0] + 16 * S.lvl[1]; S.y = S.lvl[2] + 16 * S.lvl[3]; S.dir = S.lvl[4];
      await grGetReady();
      if (S.myth) {
        if (held('U')) { nextLevel(); fresh = true; continue; }
        if (held('D')) { S.level = S.level === 0 ? NLEVELS - 1 : S.level - 1; fresh = true; continue; }
      }
      await meMainEvent();
      if (S.won) {
        S.dir = 0; S.erase = true; await mvMove(); S.erase = false;
        await cnCongrats();
        nextLevel(); fresh = true; continue;
      }
      if (S.lives === 0) return;
      fresh = false;
    }
  }

  async function menuLoop() {
    let st = 'menu';
    for (;;) {
      if (st === 'menu') cfClear();
      if (st !== 'check') { dmDrawMenu(); S.myth = 0; await waitRelease(); }
      st = 'check';
      if (!await waWait(0x18E70)) return;              // ~5 minutes idle: back to the aplet screen
      if (held('A')) { await game(); await waWait(0xCC); st = 'menu'; }
      else if (held('B')) {
        const c = S.speedToggle - SPEED_UP;
        if (c < 0) { S.speedToggle = SLOW; await snd('menuDown'); } else { S.speedToggle = c; await snd('menuUp'); }
        st = 'redraw';
      } else if (held('C')) { cfClear(); dmDrawHelp(); await waitRelease(); await waWait(0x800); st = 'menu'; }
    }
  }

  async function action() {
    S.screen = 'game'; running = true;
    scr.fill(0); isInitScn();
    S.speedToggle = NORMAL;
    try { await menuLoop(); } catch (e) { if (e !== EXIT) throw e; }
    running = false; S.paused = false;
    while (down.size || latch.size) { latch = new Set(); await sleep(20); }
    vt = Math.max(vt, now());
    entryScreen();
  }

  // ---------------------------------------------------------------- aplet start screen (RPL _Entry)
  const F57 = {
    P: '11110 10001 10001 11110 10000 10000 10000', r: '00000 00000 10110 11001 10000 10000 10000',
    e: '00000 00000 01110 10001 11111 10000 01110', s: '00000 00000 01111 10000 01110 00001 11110',
    E: '11111 10000 10000 11110 10000 10000 11111', N: '10001 10001 11001 10101 10011 10001 10001',
    T: '11111 00100 00100 00100 00100 00100 00100', R: '11110 10001 10001 11110 10100 10010 10001',
    t: '01000 01000 11100 01000 01000 01001 00110', o: '00000 00000 01110 10001 10001 10001 01110',
    a: '00000 00000 01110 00001 01111 10001 01111', '.': '00000 00000 00000 00000 00000 01100 01100',
    D: '11100 10010 10001 10001 10001 10010 11100', I: '01110 00100 00100 00100 00100 00100 01110',
    A: '01110 10001 10001 11111 10001 10001 10001', M: '10001 11011 10101 10101 10001 10001 10001',
    O: '01110 10001 10001 10001 10001 10001 01110', S: '01111 10000 10000 01110 00001 00001 11110',
    ' ': '00000 00000 00000 00000 00000 00000 00000',
  };
  const F35 = {
    V: '101 101 101 101 010', 1: '010 110 010 010 111', '.': '000 000 000 000 010',
    '(': '001 010 010 010 001', c: '000 011 100 100 011', ')': '100 010 010 010 100',
    D: '110 101 101 101 110', M: '101 111 111 101 101', 9: '111 101 111 001 111',
    8: '111 101 111 101 111', 3: '111 001 011 001 111',
  };
  function setPx(x, y, on) {
    if (x < 0 || x > 130 || y < 0 || y > 63) return;
    const a = y * W + (x >> 2), m = 1 << (x & 3);
    scr[a] = on ? scr[a] | m : scr[a] & ~m;
  }
  function text(str, x, y, font, pitch, h) {
    for (let r = 0; r < h; r++) for (let c = 0; c < str.length * pitch; c++) setPx(x + c, y + r, 0);
    [...str].forEach((ch, i) => {
      const g = (font[ch] || font[' '] || '').split(' ');
      g.forEach((row, r) => [...row].forEach((b, c) => { if (b === '1') setPx(x + i * pitch + c, y + r, 1); }));
    });
  }
  function line(x1, y1, x2, y2) {
    for (let x = Math.min(x1, x2); x <= Math.max(x1, x2); x++)
      for (let y = Math.min(y1, y2); y <= Math.max(y1, y2); y++) setPx(x, y, 1);
  }
  function entryScreen() {
    S.screen = 'entry';
    scr.fill(0);
    text('Press ENTER', 4, 24, F57, 6, 8);
    text('to start...', 4, 32, F57, 6, 8);
    text('V1.1(c)DM98', 83, 57, F35, 4, 6);
    for (let r = 0; r < 36; r++) for (let x = 0; x < 47; x++)
      setPx(80 + x, 20 + r, (G.entryGrob[r * 12 + (x >> 2)] >> (x & 3)) & 1);
    text('DIAMONDS', 80, 6, F57, 6, 8);
    line(78, 1, 128, 1); line(128, 2, 128, 17); line(78, 17, 127, 17);
    line(78, 2, 78, 16); line(79, 18, 129, 18); line(129, 2, 129, 17);
    text('38', 100, 36, F35, 4, 6);
  }

  // ---------------------------------------------------------------- LCD renderer
  const canvas = document.getElementById('lcd');
  const ctx = canvas.getContext('2d');
  const inten = new Float32Array(131 * 64);
  const bg = document.createElement('canvas');
  let pitch = 1, lastT = performance.now();

  function resize() {
    const dpr = window.devicePixelRatio || 1;
    const w = canvas.clientWidth;
    canvas.width = Math.round(w * dpr);
    canvas.height = Math.round(w * 64 / 131 * dpr);
    pitch = canvas.width / 131;
    bg.width = canvas.width; bg.height = canvas.height;
    const b = bg.getContext('2d');
    const gr = b.createLinearGradient(0, 0, bg.width, bg.height);
    gr.addColorStop(0, '#bccaa6'); gr.addColorStop(1, '#aab993');
    b.fillStyle = gr; b.fillRect(0, 0, bg.width, bg.height);
    b.fillStyle = 'rgba(40,60,30,0.045)';                 // the faint matrix of unlit pixels
    const g = pitch * 0.12;
    for (let y = 0; y < 64; y++) for (let x = 0; x < 131; x++) b.fillRect(x * pitch + g, y * pitch + g, pitch - g, pitch - g);
  }
  window.addEventListener('resize', resize);
  resize();

  const LEVELS_Q = 8;
  function frame(t) {
    const dt = Math.min(100, t - lastT); lastT = t;
    const kOn = 1 - Math.exp(-dt / 22), kOff = 1 - Math.exp(-dt / 40);   // slow STN liquid crystal
    for (let y = 0; y < 64; y++) for (let x = 0; x < 131; x++) {
      const i = y * 131 + x, on = (scr[y * W + (x >> 2)] >> (x & 3)) & 1;
      inten[i] += (on - inten[i]) * (on ? kOn : kOff);
    }
    ctx.drawImage(bg, 0, 0);
    const g = pitch * 0.12, s = pitch * 0.2;
    for (const pass of [0, 1]) {
      for (let q = 1; q <= LEVELS_Q; q++) {
        ctx.beginPath();
        let any = false;
        for (let i = 0; i < inten.length; i++) {
          if (Math.ceil(inten[i] * LEVELS_Q - 0.15) !== q) continue;
          const x = i % 131, y = (i / 131) | 0;
          ctx.rect(x * pitch + g + (pass ? 0 : s), y * pitch + g + (pass ? 0 : s), pitch - g, pitch - g);
          any = true;
        }
        if (!any) continue;
        ctx.fillStyle = pass ? `rgba(26,36,22,${(q / LEVELS_Q) * 0.94})` : `rgba(30,45,20,${(q / LEVELS_Q) * 0.16})`;
        ctx.fill();
      }
    }
    document.body.classList.toggle('paused', S.paused);
    document.body.classList.toggle('muted', !soundOn);
    requestAnimationFrame(frame);
  }

  // ---------------------------------------------------------------- key wiring
  const KEYMAP = {
    ArrowLeft: 'LEFT', ArrowRight: 'RIGHT', ArrowUp: 'UP', ArrowDown: 'DOWN',
    Enter: 'ENTER', ' ': 'ENTER', Backspace: 'DEL', Delete: 'DEL', Shift: 'SHIFT', Escape: 'ON',
    '-': 'NEG', m: 'NEG', a: 'A', b: 'B', c: 'C', j: 'J', o: 'O', e: 'E', u: 'U', d: 'D',
  };
  function press(k) {
    audioInit();
    if (!down.has(k) && k === 'NEG') toggleSound();
    down.add(k); latch.add(k);
    if (S.screen === 'entry' && k === 'ENTER') action();
    document.querySelectorAll(`[data-key="${k}"]`).forEach(el => el.classList.add('down'));
  }
  function release(k) {
    down.delete(k);
    document.querySelectorAll(`[data-key="${k}"]`).forEach(el => el.classList.remove('down'));
  }
  window.addEventListener('keydown', e => {
    if (e.ctrlKey || e.metaKey || e.altKey) return;
    if (e.target.closest && e.target.closest('a, input, textarea, select, [contenteditable]')) return;
    const k = KEYMAP[e.key] || KEYMAP[e.key.toLowerCase()];
    if (!k) return;
    e.preventDefault();
    if (!e.repeat) press(k);
  });
  window.addEventListener('keyup', e => {
    const k = KEYMAP[e.key] || KEYMAP[e.key.toLowerCase()];
    if (k) release(k);
    if (e.key === 'Shift') release('SHIFT');
  });
  window.addEventListener('blur', () => [...down].forEach(release));
  document.querySelectorAll('[data-key]').forEach(el => {
    const k = el.dataset.key;
    el.addEventListener('pointerdown', e => { e.preventDefault(); el.setPointerCapture(e.pointerId); press(k); });
    for (const ev of ['pointerup', 'pointercancel']) el.addEventListener(ev, () => release(k));
    el.addEventListener('contextmenu', e => e.preventDefault());
  });
  canvas.addEventListener('pointerdown', () => { if (S.screen === 'entry') { press('ENTER'); setTimeout(() => release('ENTER'), 120); } });

  if (/[?&]debug\b/.test(location.search)) window.__diamonds = { S, scr };

  entryScreen();
  requestAnimationFrame(frame);
})();
