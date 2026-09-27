#!/usr/bin/env bash
# One-shot job: creates every topic the platform uses. Safe to re-run (--if-not-exists).
# Auto-creation is disabled on the broker, so a typo in a topic name fails loudly instead of
# silently creating a new topic.
set -euo pipefail

BOOTSTRAP="${KAFKA_BOOTSTRAP:-kafka:29092}"
PARTITIONS="${TOPIC_PARTITIONS:-3}"

# topic name | purpose
TOPICS=(
  "customer.events"    # CustomerRegistered, CustomerLocked, CustomerUnlocked, CustomerErased
  "account.events"     # AccountOpened, AccountFrozen
  "transfer.commands"  # DebitAccount, CreditAccount, RefundAccount   (key = accountId)
  "transfer.replies"   # AccountDebited, DebitRejected, AccountCredited, CreditRejected
  "transfer.events"    # TransferCompleted, TransferFailed           (key = transferId)
)

for topic in "${TOPICS[@]}"; do
  /opt/kafka/bin/kafka-topics.sh --bootstrap-server "$BOOTSTRAP" \
    --create --if-not-exists --topic "$topic" \
    --partitions "$PARTITIONS" --replication-factor 1
done

echo "Topics now on the broker:"
/opt/kafka/bin/kafka-topics.sh --bootstrap-server "$BOOTSTRAP" --list
