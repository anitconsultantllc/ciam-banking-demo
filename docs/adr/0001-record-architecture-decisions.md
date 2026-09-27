# 1. Record architecture decisions

Date: 2026-09-27 · Status: Accepted

## Context
Decisions about this system (why Kafka *and* RabbitMQ, why clean architecture, why PKCE rather than a BFF) need to be explainable later, to reviewers, interviewers and future maintainers.

## Decision
We keep lightweight Architecture Decision Records in `docs/adr/`, one Markdown file per decision, numbered in order. A superseded ADR stays in place and is marked as superseded.

## Consequences
Every significant choice has a short written rationale next to the code it affects.
