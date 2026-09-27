# Local credentials and URLs

Dev-only values for the local docker compose stack. The source of truth is `.env` (copied from `.env.example`). If you change a value there, update this page.

## Keycloak

| Page | URL | Username | Password |
|---|---|---|---|
| Admin console | http://localhost:8180/admin | `admin` | `admin_dev_pw` |
| Customer account page | http://localhost:8180/realms/bank/account | `alice` | `Passw0rd!2026` |

The admin console opens in the `master` realm. Switch to realm **bank** with the dropdown at the top left.

### Test users (realm `bank`), all with password `Passw0rd!2026`

| User | Email | Roles | Use for |
|---|---|---|---|
| `alice` | alice@example.test | customer | Customer portal, sender in transfer demos |
| `bob` | bob@example.test | customer | Customer portal, receiver, brute-force demo |
| `sam` | sam@ciambank.local | support_agent | Back-office: search, KYC review, lock/unlock |
| `ada` | ada@ciambank.local | admin, support_agent | Back-office admin |

### Service clients

| Client | Secret | Used by |
|---|---|---|
| `customer-service` | `customer-svc-dev-secret` | Customer Service → Keycloak Admin API (lock/unlock users) |

## Other tools

| Tool | URL / host | Username | Password |
|---|---|---|---|
| RabbitMQ management | http://localhost:15672 | `bank` | `rabbit_dev_pw` |
| Postgres (superuser) | `localhost:5432` | `postgres` | `postgres_dev_pw` |
| Postgres (per service) | `localhost:5432`, db `<svc>_db` | `<svc>_user` (e.g. `customer_user`) | `app_dev_pw` |
| Mailpit inbox | http://localhost:8025 | — | — |
| Jaeger traces | http://localhost:16686 | — | — |
| Kafka (from your IDE) | `localhost:9092` | — | — |
| Kafka (from containers) | `kafka:29092` | — | — |
