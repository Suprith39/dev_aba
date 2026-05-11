# Automated Java Delivery Pipeline

A fully automated, end-to-end CI/CD pipeline for a Java web application. Every push to `main` triggers the complete flow — build, test, containerize, push, and deploy — with zero manual steps.

```
git push → GitHub Actions → Maven build → Docker image → Docker Hub → Ansible → Ubuntu server
```

---

## Tools and Their Roles

| Tool | Role |
|---|---|
| Java 17 + Spring Boot | The web application runtime and framework |
| Maven | Compiles source, runs tests, packages the executable JAR |
| Docker | Packages the app into a portable, reproducible container image |
| Docker Hub | Hosts the container image registry |
| Ansible | Connects to the target server and manages the running container |
| GitHub Actions | Orchestrates the entire pipeline on every push to `main` |

---

## Prerequisites

Before you begin, make sure you have the following installed locally:

- Java 17 (for local development/testing)
- Docker Desktop (for local image builds)
- Ansible (for running the playbook manually if needed): `pip install ansible`
- A GitHub account with this project pushed to a repository
- A Docker Hub account
- An Ubuntu 22.04 server with Docker installed and SSH access

---

## Project Structure

```
.
├── .github/workflows/pipeline.yml   # GitHub Actions CI/CD workflow
├── .mvn/wrapper/                    # Maven wrapper config
├── ansible/
│   ├── deploy.yml                   # Ansible deployment playbook
│   └── inventory/hosts.ini          # Target server inventory
├── src/
│   ├── main/java/com/example/pipeline/
│   │   ├── PipelineApplication.java
│   │   └── HelloController.java
│   ├── main/resources/application.properties
│   └── test/java/com/example/pipeline/
│       └── HelloControllerTest.java
├── Dockerfile
├── mvnw / mvnw.cmd                  # Maven wrapper scripts
├── pom.xml
└── README.md
```

---

## Running Locally

### Option 1 — Spring Boot dev server

```bash
./mvnw spring-boot:run
```

Visit http://localhost:8080 — you should see `Hello, Pipeline!`

### Option 2 — Docker

```bash
# Build the image
docker build -t java-pipeline-app .

# Run the container
docker run -p 8080:8080 java-pipeline-app
```

Visit http://localhost:8080

### Run tests only

```bash
./mvnw test
```

---

## Configuring GitHub Secrets

Go to your GitHub repository → Settings → Secrets and variables → Actions → New repository secret.

Add the following four secrets:

| Secret name | What to put here |
|---|---|
| `DOCKERHUB_USERNAME` | Your Docker Hub username (e.g. `johndoe`) |
| `DOCKERHUB_TOKEN` | A Docker Hub access token (create one at hub.docker.com → Account Settings → Security) |
| `SSH_PRIVATE_KEY` | The full contents of your SSH private key file (e.g. `~/.ssh/id_rsa`) — include the `-----BEGIN...` and `-----END...` lines |
| `TARGET_SERVER_IP` | The public IP address of your Ubuntu 22.04 deployment server |

---

## How the Pipeline Works

The workflow in `.github/workflows/pipeline.yml` triggers on every push to `main` and runs four steps in sequence. If any step fails, the pipeline stops immediately.

1. Checkout — fetches the latest code from the repository
2. Maven build — runs `./mvnw clean package`, compiling all sources and executing unit tests; a test failure blocks the rest of the pipeline
3. Docker build & push — builds a multi-stage image tagged with both `latest` and the commit SHA, then pushes both tags to Docker Hub
4. Ansible deploy — installs Ansible on the runner, writes the SSH key from secrets, then runs `ansible/deploy.yml` which pulls the new image, replaces the running container, and verifies it is healthy

---

## Placeholder Reference

Every placeholder in the config files is listed below. Swap these out before running the pipeline.

| Placeholder | File | Replace with |
|---|---|---|
| `YOUR_DOCKERHUB_USERNAME` | `ansible/deploy.yml` | Your Docker Hub username |
| `YOUR_SERVER_IP` | `ansible/inventory/hosts.ini` | Your server's public IP address |
| `/path/to/your/private/key` | `ansible/inventory/hosts.ini` | Absolute path to your SSH private key (for local Ansible runs; the pipeline uses the secret) |

When running through GitHub Actions, `YOUR_SERVER_IP` is overridden at runtime via the `TARGET_SERVER_IP` secret, so you don't need to commit the real IP to the repository.

---

## Deploying Manually (without GitHub Actions)

If you want to run the Ansible playbook directly from your machine:

```bash
# 1. Update ansible/inventory/hosts.ini with your real server IP and key path
# 2. Run the playbook
ansible-playbook ansible/deploy.yml -i ansible/inventory/hosts.ini
```

Make sure the `community.docker` collection is installed first:

```bash
ansible-galaxy collection install community.docker
```
