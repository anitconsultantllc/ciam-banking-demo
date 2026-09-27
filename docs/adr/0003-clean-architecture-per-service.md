# 3. Clean architecture in every backend service

Date: 2026-09-27 · Status: Accepted

## Context
Services contain business rules (transfer state machine, limits, KYC) that must stay testable without Spring, JPA or Kafka, and must not erode as the code grows.

## Decision
Each service with business logic has four modules/projects. Dependencies point inward only:

| Java (Maven module) | .NET (project) | Contains |
|---|---|---|
| `*-domain` | `*.Domain` | Entities, value objects, domain events. No framework dependencies. |
| `*-application` | `*.Application` | Use cases and ports (interfaces) |
| `*-infrastructure` | `*.Infrastructure` | JPA/EF, Kafka, RabbitMQ, HTTP clients: implementations of the ports |
| `*-api` | `*.Api` / `*.Worker` | Host, controllers, security, DI wiring |

Build-time module dependencies make wrong-direction imports a compile error. ArchUnit (Java) and NetArchTest (.NET) enforce finer rules, for example "domain must not import `org.springframework`".

The API Gateway is exempt. It is configuration plus filters and has no business logic to protect.

## Consequences
- More modules than a single-project service. That's accepted in exchange for enforced boundaries and fast, framework-free domain tests.
- Mapping between JPA entities and domain objects happens in infrastructure adapters.
