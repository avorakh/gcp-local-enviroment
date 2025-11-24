#!/bin/sh

set -e

PUBSUB_EMULATOR_HOST="${PUBSUB_EMULATOR_HOST:-pubsub-emulator:8085}"
PUBSUB_PROJECT_ID="${PUBSUB_PROJECT_ID:-sample-project}"
TOPIC_NAME="${TOPIC_NAME:-sample-topic}"
SUBSCRIPTION_NAME="${SUBSCRIPTION_NAME:-sample-subscription}"

echo "Waiting for Pub/Sub emulator to be ready..."
sleep 10

# Create topic
echo "Creating topic: ${TOPIC_NAME}"
TOPIC_HTTP_CODE=$(curl -s -X PUT "http://${PUBSUB_EMULATOR_HOST}/v1/projects/${PUBSUB_PROJECT_ID}/topics/${TOPIC_NAME}" -o /tmp/topic_body.txt -w '%{http_code}')
TOPIC_BODY=$(cat /tmp/topic_body.txt)

echo "Topic creation HTTP code: ${TOPIC_HTTP_CODE}"
echo "Topic creation response: ${TOPIC_BODY}"

if [ "${TOPIC_HTTP_CODE}" = "200" ] || [ "${TOPIC_HTTP_CODE}" = "409" ]; then
  echo "Topic created or already exists (HTTP ${TOPIC_HTTP_CODE})"
  echo "Verifying topic exists..."
  VERIFY_HTTP_CODE=$(curl -s "http://${PUBSUB_EMULATOR_HOST}/v1/projects/${PUBSUB_PROJECT_ID}/topics/${TOPIC_NAME}" -o /tmp/verify_topic_body.txt -w '%{http_code}')
  VERIFY_BODY=$(cat /tmp/verify_topic_body.txt)
  
  if [ "${VERIFY_HTTP_CODE}" = "200" ]; then
    echo "✓ Topic verified successfully"
  else
    echo "✗ Topic verification failed (HTTP ${VERIFY_HTTP_CODE})"
    echo "Verification response: ${VERIFY_BODY}"
    exit 1
  fi
else
  echo "✗ Topic creation failed (HTTP ${TOPIC_HTTP_CODE})"
  echo "Error response: ${TOPIC_BODY}"
  exit 1
fi

# Create subscription
echo "Creating subscription: ${SUBSCRIPTION_NAME}"
SUB_HTTP_CODE=$(curl -s -X PUT "http://${PUBSUB_EMULATOR_HOST}/v1/projects/${PUBSUB_PROJECT_ID}/subscriptions/${SUBSCRIPTION_NAME}" \
  -H 'Content-Type: application/json' \
  -d "{\"topic\": \"projects/${PUBSUB_PROJECT_ID}/topics/${TOPIC_NAME}\"}" \
  -o /tmp/sub_body.txt -w '%{http_code}')
SUB_BODY=$(cat /tmp/sub_body.txt)

echo "Subscription creation HTTP code: ${SUB_HTTP_CODE}"
echo "Subscription creation response: ${SUB_BODY}"

if [ "${SUB_HTTP_CODE}" = "200" ] || [ "${SUB_HTTP_CODE}" = "409" ]; then
  echo "Subscription created or already exists (HTTP ${SUB_HTTP_CODE})"
  echo "Verifying subscription exists..."
  VERIFY_SUB_HTTP_CODE=$(curl -s "http://${PUBSUB_EMULATOR_HOST}/v1/projects/${PUBSUB_PROJECT_ID}/subscriptions/${SUBSCRIPTION_NAME}" -o /tmp/verify_sub_body.txt -w '%{http_code}')
  VERIFY_SUB_BODY=$(cat /tmp/verify_sub_body.txt)
  
  if [ "${VERIFY_SUB_HTTP_CODE}" = "200" ]; then
    echo "✓ Subscription verified successfully"
    echo "✓ Topic and subscription created and verified successfully!"
  else
    echo "✗ Subscription verification failed (HTTP ${VERIFY_SUB_HTTP_CODE})"
    echo "Verification response: ${VERIFY_SUB_BODY}"
    exit 1
  fi
else
  echo "✗ Subscription creation failed (HTTP ${SUB_HTTP_CODE})"
  echo "Error response: ${SUB_BODY}"
  exit 1
fi

