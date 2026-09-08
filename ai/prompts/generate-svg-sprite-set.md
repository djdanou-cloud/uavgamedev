# Prompt: generate-svg-sprite-set (v1, 2026-09-08)

Used by art cards (CAD-FP-045, E-VS-06, E-AL-05). Replace `{{CARD_ID}}` and `{{SPRITE_IDS}}` (comma-separated ids from `docs/production/01-design-bible.md` §B.13).

---

You are authoring flat vector sprites as SVG text for a 2D "tactical display" game. Every sprite is code you write by hand; you must not use, embed, trace or reference any raster image, photo, external asset, font, or generated image.

Card: `{{CARD_ID}}`. Sprites to produce: `{{SPRITE_IDS}}`.

1. Read `AGENTS.md` §2 (naming), `docs/production/01-design-bible.md` §B.13 (palette, sizes, icon legend), the card, and `docs/art/style.md` if it exists.
2. Claim the card as in `/ai/prompts/implement-from-card.md` steps 3–5 (branch `card/{{CARD_ID}}-svg`).
3. For each sprite id write `art/svg/<sprite_id>.svg` obeying all of:
   - `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">`, no `width`/`height`, no `<text>`, `<image>`, `<filter>`, gradients, masks, `<use>`, or external references.
   - Elements limited to `path`, `circle`, `rect`, `polygon`, `line`, `polyline`, `g`.
   - `stroke-width="4"` for outlines (2 for inner detail), `stroke-linecap="round"`, `stroke-linejoin="round"`.
   - Colours only from: `#35D0FF` friendly, `#FF5A3C` hostile, `#FFB03C` hostile_high, `#E6F0FF` text, `#FFFFFF` track, `#B26BFF` ew, `#FFC53D` warning, `none`. Entity sprites use one colour (friendly for `emp_*`, hostile for `thr_*`; `thr_srbm` uses hostile_high); UI glyphs use `#E6F0FF`.
   - Silhouette readable at 26 dp: no detail smaller than 6 units on the 64 canvas; ≤ 12 elements; glyph fills at least 60 % of the canvas in one dimension; 2-unit clear margin.
   - Directional sprites point up (−y); the legend row in §B.13 defines the shape — implement that shape, not a "better" one.
   - Fictional: nothing that resembles a real insignia, roundel, flag, manufacturer logo or a recognisable real vehicle silhouette.
   - ≤ 30 lines per file, no comments needed.
4. Append each path to `art/AUTHORED.txt` (one per line). No licence row is needed for authored files.
5. Run the sprite tests: `tools/test.sh res://test/unit/art/test_cad_svg_set.gd` (parses at 2×, palette check, viewBox). If the atlas builder exists, run `tools/atlas.sh` and check the rebuilt atlas is committed.
6. Produce a contact sheet for the human: run the builder or the test's render step so 128 px PNGs exist under `user://` (or the atlas PNG), and describe in the handoff where to look.
7. Finish per `/ai/prompts/implement-from-card.md` step 10.

Reply in the chat only with: branch, status, list of sprite ids written, test exit code.
