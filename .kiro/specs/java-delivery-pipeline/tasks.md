# Implementation Plan

- [x] 1. Set up Maven project structure and Spring Boot application


  - Create the standard Maven directory tree: `src/main/java/com/example/pipeline/`, `src/main/resources/`, `src/test/java/com/example/pipeline/`
  - Write `PipelineApplication.java` with `@SpringBootApplication` and `main` method
  - Write `HelloController.java` with a `@RestController` mapping `GET /` to return `"Hello, Pipeline!"`
  - Add `application.properties` with `server.port=8080`
  - _Requirements: 1.1, 1.2, 1.3, 1.4_






- [ ] 2. Write unit tests for the controller
  - Create `HelloControllerTest.java` using `@WebMvcTest(HelloController.class)`

  - Assert `GET /` returns HTTP 200 and body equals `"Hello, Pipeline!"`




  - _Requirements: 1.1, 2.5_






- [x] 3. Configure `pom.xml` and Maven wrapper




  - [x] 3.1 Write `pom.xml` with Java 17, `spring-boot-starter-web`, `spring-boot-starter-test`, and `spring-boot-maven-plugin`


    - Set `<java.version>17</java.version>` and compiler source/target
    - Include `maven-surefire-plugin` so tests run during `package`


    - _Requirements: 2.1, 2.2, 2.3_
  - [ ] 3.2 Add Maven wrapper files
    - Create `.mvn/wrapper/maven-wrapper.properties` pointing to Maven 3.9.x
    - Create `mvnw` (Unix shell script) and `mvnw.cmd` (Windows batch script)
    - _Requirements: 2.4_

- [x] 4. Write the multi-stage Dockerfile



  - Stage 1: `FROM maven:3.9-eclipse-temurin-17 AS builder`, copy `pom.xml` and `src/`, run `mvn clean package -DskipTests`
  - Stage 2: `FROM eclipse-temurin:17-jre-alpine`, create non-root user `appuser`, copy JAR from builder, set `USER appuser`, `EXPOSE 8080`, add `HEALTHCHECK`, set `ENTRYPOINT`
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6_

- [ ] 5. Write Ansible inventory and deployment playbook
  - [ ] 5.1 Create `ansible/inventory/hosts.ini` with a `[webservers]` group, placeholder `YOUR_SERVER_IP`, and `ansible_ssh_private_key_file` variable
    - _Requirements: 4.1, 4.6_
  - [ ] 5.2 Write `ansible/deploy.yml` playbook
    - Task 1: Pull latest Docker image from Docker Hub (`docker pull`)
    - Task 2: Stop and remove existing container (idempotent — no error if absent)
    - Task 3: Run new container with port mapping `8080:8080`
    - Task 4: Gather container info and assert `State.Running == true`
    - Use Ansible variables for image name, container name, and ports
    - _Requirements: 4.2, 4.3, 4.4, 4.5, 4.7_

- [ ] 6. Write the GitHub Actions CI/CD workflow
  - Create `.github/workflows/pipeline.yml` triggered on `push` to `main`
  - Step 1: `actions/checkout@v4`
  - Step 2: `actions/setup-java@v4` (Java 17, temurin) + `./mvnw clean package -B`
  - Step 3: `docker/login-action@v3` using `DOCKERHUB_USERNAME` / `DOCKERHUB_TOKEN` secrets, then `docker build` and `docker push` with tags `latest` and `${{ github.sha }}`
  - Step 4: `pip install ansible`, write `SSH_PRIVATE_KEY` secret to `~/.ssh/id_rsa`, run `ansible-playbook` passing `TARGET_SERVER_IP` as an extra var
  - Add `if: failure()` guards so each step only runs if the previous succeeded
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 5.8, 5.9_

- [ ] 7. Write README.md
  - Project title, description, and pipeline diagram (ASCII or text)
  - Tools table: Java, Maven, Docker, Ansible, GitHub Actions — role of each
  - Prerequisites section listing required installs and versions
  - Local development instructions: `./mvnw spring-boot:run` and Docker run command
  - GitHub Secrets configuration section listing all 4 secrets with descriptions
  - Pipeline trigger and stage-by-stage explanation
  - Placeholder reference table listing every `YOUR_*` value and what to substitute
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6_
