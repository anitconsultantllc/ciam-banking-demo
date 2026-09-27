# CIAM Banking Demo

A small online-banking platform showing customer identity (CIAM), microservices and full-stack development working together:

- **Keycloak** for customer identity: self-registration, email verification, MFA, step-up authentication, brute-force protection
- **Java 25 / Spring Boot 4** microservices in clean architecture: Customer, Account, Transfer (saga orchestrator)
- **Kafka** event backbone with a transactional outbox in every service
- **C# / .NET 10** Notification Service, which queues email on **RabbitMQ** for durable delivery
- **React** customer portal and **Angular** back-office
- **OpenTelemetry → Jaeger** tracing across HTTP and Kafka

The architecture diagrams, request flows and design decisions are in [`docs/blueprint.html`](docs/blueprint.html). Open it in a browser.

Local URLs and logins: [`docs/LOCAL-CREDENTIALS.md`](docs/LOCAL-CREDENTIALS.md). Remaining work: [`docs/ROADMAP.md`](docs/ROADMAP.md).

## Status

| Phase | Scope | State |
|---|---|---|
| 1 | Foundation: repo, compose infrastructure, Keycloak realm, Kafka topics, CI | ✅ done |
| 2 | Customer + Account services | next |
| 3 | Transfer Service (saga) | |
| 4 | Notification Service (.NET) | |
| 5 | React customer portal | |
| 6 | Angular back-office | |
| 7 | Gateway, tracing, end-to-end tests | |

## Prerequisites

| Tool | Version | Check |
|---|---|---|
| Docker + Compose v2 | 28+ | `docker compose version` |
| JDK | 25 (Temurin) | `java -version` |
| .NET SDK | 10 | `dotnet --version` |
| Node.js | 22+ | `node -v` |

Maven comes from the wrapper (`./mvnw`), so you don't need to install it.

## Run the infrastructure

```bash
cp .env.example .env                    # once
docker compose --profile infra up -d    # Postgres, Keycloak, Kafka, RabbitMQ, Mailpit, Jaeger
docker compose ps                       # wait until everything shows (healthy)
```

| What | URL | Sign in |
|---|---|---|
| Keycloak admin console | http://localhost:8180/admin | `admin` / `admin_dev_pw` |
| Keycloak account page (as a customer) | http://localhost:8180/realms/bank/account | `alice` / `Passw0rd!2026` |
| RabbitMQ management | http://localhost:15672 | `bank` / `rabbit_dev_pw` |
| Mailpit inbox | http://localhost:8025 | — |
| Jaeger traces | http://localhost:16686 | — |

### Test users (realm `bank`)

| User | Roles | Use for |
|---|---|---|
| `alice`, `bob` | customer | Customer portal, transfers between them |
| `sam` | support_agent | Back-office: search, KYC review, lock/unlock |
| `ada` | admin, support_agent | Back-office admin |

All share the password in `TEST_USER_PASSWORD` (`.env`).

## Reset everything

```bash
docker compose --profile all down -v    # -v deletes the volumes, so the realm re-imports on next start
```

## Repository layout

```
infra/          compose-mounted config: Keycloak realm, Postgres init, Kafka topics
contracts/      JSON Schemas for events, shared by Java and C#
libs/           shared Java plumbing (outbox, security), no business logic
services/       one folder per microservice
frontends/      React customer portal, Angular back-office
e2e/            Playwright tests against the full stack
docs/           blueprint, ADRs, per-phase walkthroughs
```
