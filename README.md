# Cortex Music — iOS (beta)

A **Cortex Music** iOS héja: WKWebView + háttér-lejátszás + zárképernyős vezérlés.
Belső lejátszó: `Resources/www/music.html` (YouTube/SoundCloud embed + helyi fájlok).

- Alap: saját kód (MIT a Riff ihlette UI-val) — a Riff MIT licence: https://github.com/rootscripts/riff
- Verzió: 0.1.0 (1)
- Bundle: `eu.cortanime.music`

## Építés (GitHub Actions, macOS runner)
Push a `main`-re vagy `workflow_dispatch` → `Build iOS IPA` workflow → artifact: `CortexMusic-ipa`.
A repo **nyilvános** → a macOS CI **ingyenes és korlátlan** (a kvóta-kérdés így szűnik meg).

Telepítés: AltStore / Sideloadly / TestFlight (utóbbihoz App Store Connect szükséges).
