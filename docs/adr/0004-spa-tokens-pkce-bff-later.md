# 4. SPAs use Authorization Code + PKCE with in-memory tokens

Date: 2026-09-27 · Status: Accepted

## Context
Both frontends are single-page apps. Options: (a) public OIDC client with PKCE, tokens held in memory; (b) Backend-for-Frontend (BFF), where a server-side component holds the tokens and the browser gets only an httpOnly session cookie.

## Decision
Use (a) for this demo: PKCE (S256), 5-minute access tokens, refresh-token rotation, and tokens kept in memory, never in `localStorage`.

## Consequences
- Simpler topology, and the OIDC flow is visible in the browser, which helps the demo.
- An XSS bug could still use the token while the page is open. A strict CSP reduces that risk.
- For a production bank we would move to (b). The IETF's guidance for browser-based apps recommends a BFF for high-risk apps. The gateway is the natural place for it.
