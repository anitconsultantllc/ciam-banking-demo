# 2. Kafka as the event backbone, RabbitMQ for outbound delivery

Date: 2026-09-27 · Status: Accepted

## Context
Services must share domain events (customer registered, transfer completed) without calling each other directly. Separately, the Notification Service must send emails reliably: every message delivered, retried on its own schedule, and set aside when it keeps failing.

## Decision
- **Kafka** carries all inter-service events and saga commands. It is a durable, replayable log: several consumer groups read the same events independently, and keying by `accountId` / `transferId` preserves ordering where it matters.
- **RabbitMQ** is used only inside the Notification Service. Its Kafka consumer turns events into email jobs on a durable **quorum queue**, and a separate sender works that queue with per-message acks, a delivery limit and a dead-letter queue.

## Why not one broker?
- Kafka alone: a failing email would block every later message on that partition, or force us to build retry topics by hand.
- RabbitMQ alone: we would lose replay, and adding a new consumer of past events would be awkward.

## Consequences
- Two brokers to run. That's acceptable because each does the job it's designed for.
- The Notification Service declares its own exchanges and queues at startup, so the RabbitMQ topology lives next to the code that uses it.
