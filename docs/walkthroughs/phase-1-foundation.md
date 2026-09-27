# Phase 1 walkthrough: Foundation

**Goal:** everything the services will need exists and runs, before any Java is written.
**Time to go through it:** about 30 minutes.

## What was built

| File | What it does | .NET analogy |
|---|---|---|
| `pom.xml` | Parent POM. Java 25, Spring Boot 4.0.8 as parent, Spring Cloud BOM, module list (empty until Phase 2) | `.sln` + `Directory.Build.props` + `Directory.Packages.props` |
| `mvnw`, `.mvn/wrapper/` | Downloads and runs Maven 3.9.16 on first use | `global.json` pinning the SDK |
| `docker-compose.yml` | Postgres, Keycloak, Kafka, RabbitMQ, Mailpit, Jaeger under profile `infra` | Same as in .NET projects |
| `.env.example` | Every port and dev credential in one place. Nothing is hard-coded in the compose file. | `appsettings.Development.json` + user secrets |
| `infra/postgres/init-databases.sh` | One database + one owner role per service | — |
| `infra/kafka/create-topics.sh` | Creates the 5 topics. Broker auto-create is **off**. | — |
| `infra/keycloak/realm-bank.json` | The whole CIAM setup as code, imported on first start | — |
| `.github/workflows/ci.yml` | Validates compose + realm, lints scripts, runs `./mvnw verify` | Azure Pipelines / GH Actions YAML you know |
| `docs/adr/0001-0004` | Why Kafka + RabbitMQ, why clean architecture, why PKCE | — |

## Key concepts to understand

### 1. Maven's parent POM and the "BOM"
Our `pom.xml` inherits from `spring-boot-starter-parent`. That parent contains a `<dependencyManagement>` block with tested version numbers for about 300 libraries (Jackson, Hibernate, Kafka client, Testcontainers…). When a module says "I need `spring-kafka`" **without a version**, Maven takes the version from there. A **BOM** ("bill of materials", like `spring-cloud-dependencies`) is the same idea as a standalone file you import. This is Central Package Management, but inherited.

### 2. Maven lifecycle ≈ `dotnet` verbs
`./mvnw verify` runs, in order: `validate → compile → test → package → integration-test → verify`. Asking for a phase runs every phase before it. `install` goes one step further and copies the built jars into `~/.m2/repository`, so other modules on your machine can use them (a bit like a local NuGet feed).

We configured **failsafe** so `*Test.java` runs in `test` (fast unit tests) and `*IT.java` runs in `integration-test` (Testcontainers, slower).

### 3. Why Keycloak's issuer is always `localhost:8180`
A JWT's `iss` claim must match exactly what the API expects. The browser reaches Keycloak at `localhost:8180`, but a container would normally reach it at `keycloak:8080`, which would produce a different issuer and every token would be rejected. We fixed that in `docker-compose.yml` by using the same port inside and outside the container and pinning `KC_HOSTNAME`. Services running in containers will fetch signing keys from `http://keycloak:8180/...` but still expect `iss = http://localhost:8180/realms/bank`.

### 4. How step-up MFA is wired (read `authenticationFlows` in the realm file)
```
browser-stepup
├── Cookie                              (already signed in? done)
└── stepup-forms
    ├── level 1 (if requested level ≥ 1) → username + password
    └── level 2 (if requested level ≥ 2) → OTP form (forces TOTP setup if missing)
```
A normal login gets `acr = 1`. When the Transfer Service returns "needs acr 2", the React app sends the user back with `acr_values=2`. Keycloak sees level 1 is already satisfied (cookie) and only asks for the TOTP code. Level 2 expires after 300 seconds (`loa-max-age`), so a later transfer asks again.

### 5. Kafka topics and keys
| Topic | Key | Why that key |
|---|---|---|
| `transfer.commands` | `accountId` | All debits and credits for one account are processed in order |
| `transfer.events` | `transferId` | All events for one transfer stay in order |

Kafka only guarantees ordering *within a partition*, and the key decides the partition. This is one of the most common Kafka interview questions.

## Try it yourself

1. **Start the stack**
   ```bash
   cd ~/Documents/ciam-banking-demo
   docker compose --profile infra up -d
   docker compose ps          # all "healthy"; kafka-init "Exited (0)" is correct, it's a one-shot job
   ```
2. **Look at the realm as an admin.** Open http://localhost:8180/admin, sign in as `admin` / `admin_dev_pw`, and switch to realm **bank**. Look at *Authentication → browser-stepup*, *Realm roles*, *Clients*, and *Realm settings → Security defenses → Brute force detection*.
3. **Sign in as a customer and enrol MFA.** Open http://localhost:8180/realms/bank/account as `alice` / `Passw0rd!2026`. Go to *Account security → Signing in → Set up Authenticator application* and scan the code with Google or Microsoft Authenticator. You'll use it for step-up in Phase 5.
4. **Watch brute-force protection.** Sign out, then enter a wrong password for `bob` 5 times. In the admin console, *Users → bob* now shows a temporary lockout.
5. **Check that verification emails arrive.** On the sign-in page, click *Register* and create a user. The verification email appears in Mailpit at http://localhost:8025.
6. **List the Kafka topics**
   ```bash
   docker compose exec kafka /opt/kafka/bin/kafka-topics.sh --bootstrap-server kafka:29092 --describe --topic transfer.commands
   ```
7. **Check the Java toolchain**
   ```bash
   export JAVA_HOME=~/.jdks/jdk-25.0.4.1+1 PATH=~/.jdks/jdk-25.0.4.1+1/bin:$PATH
   ./mvnw -v              # Maven 3.9.16, Java 25
   ```
   Tip: in IntelliJ, *File → Project Structure → SDK → Add JDK* and point it at `~/.jdks/jdk-25.0.4.1+1`.

## Interview angle
- "Our whole identity configuration is code (`realm-bank.json`). It's reviewed in PRs and reproducible in every environment."
- "Auto-creating topics is off, so a typo in a topic name fails fast instead of quietly creating a new topic."
- "Each service has its own database and credentials, so 'database per service' is enforced by Postgres, not just by convention."
