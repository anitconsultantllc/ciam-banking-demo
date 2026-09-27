# CIAM Banking Demo: project notes for Claude

Interview-prep demo for a Senior Technical Manager role (CIAM, microservices, Java, Angular, React, full stack; C# and Corillian are nice-to-haves). Whaylon has 25 years of .NET and about 10 of Java. Explain Java/Spring concepts with .NET analogies.

## Start here
- Progress and remaining tasks: `docs/ROADMAP.md`. Keep it updated as tasks finish.
- Design: `docs/blueprint.html`, with ADRs in `docs/adr/`
- Local URLs and credentials: `docs/LOCAL-CREDENTIALS.md`
- Per-phase guides: `docs/walkthroughs/`

## Working agreements
- Build phase by phase. At the end of each phase, write a walkthrough and let Whaylon run it before continuing.
- Deliver work in visible pieces. Don't go minutes without an update.
- Clean architecture per service (ADR 0003). No hard-coded config: use `.env` or database config tables.
- Commit per phase. End commit messages with the Co-Authored-By line.

## Toolchain
- JDK 25 lives in `~/.jdks/jdk-25.0.4.1+1`. Set `JAVA_HOME` to it before running `./mvnw`.
- Start infra: `docker compose --profile infra up -d`
