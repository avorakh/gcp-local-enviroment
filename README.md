# Google Cloud Local Development Environment

This project provides a Docker Compose-based local development environment for Google Cloud Pub/Sub using the official Pub/Sub emulator. The setup automatically initializes a sample topic and subscription, enabling developers to test Pub/Sub integrations without requiring access to a GCP project or incurring cloud costs.

## Overview

The Docker Compose configuration deploys two services:

1. **pubsub-emulator**: Runs the Google Cloud Pub/Sub emulator on port 8085
2. **pubsub-init**: Automatically creates and verifies the required Pub/Sub resources (topic and subscription) upon startup

The emulator provides a local implementation of the Pub/Sub API, allowing applications to interact with Pub/Sub using the same client libraries and APIs as production environments.

## Prerequisites

- **Docker**: Version 20.10 or later
- **Docker Compose**: Version 1.29.0 or later (v1) OR Docker Compose V2 plugin

### Verifying Installation

Check your Docker Compose version:

**Docker Compose V1:**
```bash
docker-compose --version
```

**Docker Compose V2:**
```bash
docker compose version
```

## Quick Start

### Starting the Environment

**Docker Compose V1:**
```bash
docker-compose up -d
```

**Docker Compose V2:**
```bash
docker compose up -d
```

This command:
- Starts the Pub/Sub emulator service in detached mode
- Waits for the emulator to become healthy
- Automatically creates the `sample-topic` topic
- Automatically creates the `sample-subscription` subscription linked to the topic
- Verifies that both resources were created successfully

### Verifying the Setup

Check that services are running:

**Docker Compose V1:**
```bash
docker-compose ps
```

**Docker Compose V2:**
```bash
docker compose ps
```

## Docker Compose Management Commands

### Starting Services

**Start services in detached mode (background):**

**Docker Compose V1:**
```bash
docker-compose up -d
```

**Docker Compose V2:**
```bash
docker compose up -d
```

**Start services in foreground (view logs):**

**Docker Compose V1:**
```bash
docker-compose up
```

**Docker Compose V2:**
```bash
docker compose up
```

**Start specific service:**

**Docker Compose V1:**
```bash
docker-compose up -d pubsub-emulator
```

**Docker Compose V2:**
```bash
docker compose up -d pubsub-emulator
```

### Stopping Services

**Stop and remove containers:**

**Docker Compose V1:**
```bash
docker-compose down
```

**Docker Compose V2:**
```bash
docker compose down
```

**Stop services without removing containers:**

**Docker Compose V1:**
```bash
docker-compose stop
```

**Docker Compose V2:**
```bash
docker compose stop
```

**Stop and remove containers, networks, and volumes:**

**Docker Compose V1:**
```bash
docker-compose down -v
```

**Docker Compose V2:**
```bash
docker compose down -v
```

### Viewing Logs

**View logs from all services:**

**Docker Compose V1:**
```bash
docker-compose logs
```

**Docker Compose V2:**
```bash
docker compose logs
```

**Follow logs in real-time:**

**Docker Compose V1:**
```bash
docker-compose logs -f
```

**Docker Compose V2:**
```bash
docker compose logs -f
```

**View logs from specific service:**

**Docker Compose V1:**
```bash
docker-compose logs pubsub-emulator
docker-compose logs pubsub-init
```

**Docker Compose V2:**
```bash
docker compose logs pubsub-emulator
docker compose logs pubsub-init
```

**View last N lines of logs:**

**Docker Compose V1:**
```bash
docker-compose logs --tail=100
```

**Docker Compose V2:**
```bash
docker compose logs --tail=100
```

### Service Status

**List running services:**

**Docker Compose V1:**
```bash
docker-compose ps
```

**Docker Compose V2:**
```bash
docker compose ps
```

**Show service status with resource usage:**

**Docker Compose V1:**
```bash
docker-compose top
```

**Docker Compose V2:**
```bash
docker compose top
```

### Restarting Services

**Restart all services:**

**Docker Compose V1:**
```bash
docker-compose restart
```

**Docker Compose V2:**
```bash
docker compose restart
```

**Restart specific service:**

**Docker Compose V1:**
```bash
docker-compose restart pubsub-emulator
```

**Docker Compose V2:**
```bash
docker compose restart pubsub-emulator
```

### Rebuilding Services

**Rebuild and restart services:**

**Docker Compose V1:**
```bash
docker-compose up -d --build
```

**Docker Compose V2:**
```bash
docker compose up -d --build
```

## Configuration

### Environment Variables

The following configuration is set in `docker-compose.yml`:

| Parameter | Value | Description |
|-----------|-------|-------------|
| **Emulator Port** | `8085` | Port on which the Pub/Sub emulator listens |
| **Project ID** | `sample-project` | GCP project identifier for the emulator |
| **Topic** | `sample-topic` | Pre-configured topic name |
| **Subscription** | `sample-subscription` | Pre-configured subscription name |

### Network Configuration

- **Network Type**: Bridge network
- **Network Name**: `default` (auto-generated)
- **Container Communication**: Services communicate using service names as hostnames

## Integration with Applications

### Spring Boot Applications

For Spring Boot applications using Spring Cloud GCP Pub/Sub starter, configure the emulator host:

```yaml
spring:
  cloud:
    gcp:
      project-id: sample-project
      pubsub:
        emulator-host: localhost:8085
        topic: sample-topic
        subscription: sample-subscription
```

**Maven Dependency:**
```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-gcp-starter-pubsub</artifactId>
</dependency>
```

**Gradle Dependency:**
```gradle
implementation 'org.springframework.cloud:spring-cloud-gcp-starter-pubsub'
```

## Troubleshooting

### Services Not Starting

**Check service status:**
```bash
# Docker Compose V1
docker-compose ps

# Docker Compose V2
docker compose ps
```

**View error logs:**
```bash
# Docker Compose V1
docker-compose logs pubsub-emulator
docker-compose logs pubsub-init

# Docker Compose V2
docker compose logs pubsub-emulator
docker compose logs pubsub-init
```

### Port Already in Use

If port 8085 is already in use, modify the port mapping in `docker-compose.yml`:

```yaml
ports:
  - "8086:8085"  # Change host port to 8086
```

Update your application configuration to use the new port.

### Resources Not Created

If the topic or subscription creation fails:

1. Check the `pubsub-init` container logs for error messages
2. Verify the emulator is healthy: `docker compose ps`
3. Restart the services: `docker compose restart`

### Clean Restart

To completely reset the environment:

**Docker Compose V1:**
```bash
docker-compose down -v
docker-compose up -d
```

**Docker Compose V2:**
```bash
docker compose down -v
docker compose up -d
```

## Architecture

The Docker Compose setup consists of:

1. **pubsub-emulator**:
    - Image: `gcr.io/google.com/cloudsdktool/cloud-sdk:latest`
    - Exposes port 8085
    - Includes health check to ensure readiness

2. **pubsub-init**:
    - Image: `alpine:latest`
    - Depends on `pubsub-emulator` being healthy
    - Creates topic and subscription via REST API
    - Verifies resource creation before exiting

## Limitations

- The emulator does not persist data between container restarts
- Some advanced Pub/Sub features may not be fully supported
- Performance characteristics differ from production Pub/Sub
- Not suitable for load testing or production workloads

## Additional Resources

- [Google Cloud Pub/Sub Emulator Documentation](https://cloud.google.com/pubsub/docs/emulator)
- [Spring Cloud GCP Pub/Sub Documentation](https://spring.io/projects/spring-cloud-gcp)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

## License

This project is provided as-is for local development purposes.
