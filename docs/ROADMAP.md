# Roadmap

The build plan from `docs/blueprint.html`, broken into tasks. Tick a box when a task is done and committed. Each phase ends with a walkthrough in `docs/walkthroughs/` and a hands-on check by Whaylon before the next phase starts.

## Open decisions
- [ ] **GitHub account for the repo:** `gh` is signed in as `anitconsultantllc`, while commits use `colemanwhaylon`. Pick the owner and public/private, then push and confirm CI goes green.

## Phase 1: Foundation ✅
- [x] Parent POM (Java 25, Spring Boot 4.0.8, Spring Cloud 2025.1.3) + Maven wrapper 3.9.16
- [x] docker compose `infra` profile: Postgres, Keycloak, Kafka (KRaft), RabbitMQ, Mailpit, Jaeger
- [x] Keycloak realm as code: roles, PKCE clients, admin service account, brute force, step-up flow, test users
- [x] Kafka topics script (auto-create disabled)
- [x] CI workflow skeleton, ADRs 0001–0004, Phase 1 walkthrough
- [ ] Push to GitHub (blocked on the open decision above)

## Phase 2: Customer + Account services
- [ ] `libs/java-platform`: event envelope, transactional outbox + relay, processed-events (idempotent consumer), Keycloak role converter, problem+json handler
- [ ] `contracts/events/*.schema.json` for customer and account events
- [ ] Customer Service, four modules: profile created on first login (JIT, from JWT `sub`), KYC status, consents, staff audit log
- [ ] Customer Service: lock/unlock through the Keycloak Admin API with a Resilience4j circuit breaker, publishes `CustomerLocked`
- [ ] Account Service, four modules: opens checking + savings on `CustomerRegistered`, balances with `@Version` optimistic locking
- [ ] Flyway migrations, database-driven config tables
- [ ] ArchUnit layer tests, domain unit tests, Testcontainers integration tests
- [ ] Dockerfiles + compose `apps` profile entries
- [ ] Phase 2 walkthrough (IntelliJ debugging, Spring DI, JPA vs EF Core)

## Phase 3: Transfer Service
- [ ] Transfer aggregate + state machine (PENDING → DEBITED → COMPLETED | COMPENSATING → FAILED)
- [ ] `POST /api/transfers` with `Idempotency-Key`, `202 Accepted`, `GET /api/transfers/{id}`
- [ ] Step-up check: `acr` < 2 above the `transfer_config` threshold → 401 `insufficient_user_authentication`
- [ ] Orchestrated saga over `transfer.commands` / `transfer.replies`, with the refund compensation
- [ ] Account Service command handlers (debit, credit, refund)
- [ ] Tests, including "Account Service down mid-transfer" recovery
- [ ] Phase 3 walkthrough

## Phase 4: Notification Service (.NET 10)
- [ ] Solution with Domain / Application / Infrastructure / Worker + tests
- [ ] Kafka consumer (Confluent.Kafka) → RabbitMQ quorum queue, publisher confirms
- [ ] Sender BackgroundService: MailKit SMTP → Mailpit, delivery limit 5, dead-letter queue
- [ ] Email templates in `notification_db`, topology declared at startup
- [ ] xUnit + Testcontainers, NetArchTest, Dockerfile, CI job
- [ ] Phase 4 walkthrough

## Phase 5: React customer portal
- [ ] Vite + React + TypeScript, react-oidc-context (PKCE, in-memory tokens)
- [ ] Dashboard, accounts, transfer form with step-up handling, polling transfer status (TanStack Query)
- [ ] Security settings: MFA, sessions, consents
- [ ] Vitest + React Testing Library + MSW, nginx image with CSP, CI job
- [ ] Phase 5 walkthrough

## Phase 6: Angular back-office
- [ ] Angular workspace, angular-auth-oidc-client, HTTP interceptor, role guards
- [ ] Customer search/detail, KYC review queue, lock/unlock, audit trail
- [ ] Unit tests, nginx image, CI job
- [ ] Phase 6 walkthrough

## Phase 7: Gateway, tracing, polish
- [ ] Spring Cloud Gateway: routing, JWT check, CORS, per-user rate limiting
- [ ] OpenTelemetry Java agent + .NET OTel, with trace context through Kafka headers → Jaeger
- [ ] Playwright end-to-end: register → MFA → transfer → email in Mailpit
- [ ] CI: e2e job, image publishing to GHCR on `main`
- [ ] README demo script (5 minutes), `docs/interview-cheat-sheet.md`
- [ ] Rehearse the demo
