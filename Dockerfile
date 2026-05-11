# ─────────────────────────────────────────────────────────
# Stage 1: builder — compile and package with Maven + JDK 17
# ─────────────────────────────────────────────────────────
FROM maven:3.9-eclipse-temurin-17 AS builder

WORKDIR /app

# Copy the dependency manifest first so Docker can cache this layer
# and skip re-downloading dependencies when only source changes.
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source and produce the executable fat JAR
COPY src ./src
RUN mvn clean package -DskipTests -B

# ─────────────────────────────────────────────────────────
# Stage 2: runtime — minimal JRE only (~85 MB final image)
# ─────────────────────────────────────────────────────────
FROM eclipse-temurin:17-jre-alpine

# Create a non-root user/group for security (requirement 3.3)
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy only the packaged JAR from the builder stage (requirement 3.6)
COPY --from=builder /app/target/*.jar app.jar

# Drop privileges
USER appuser

# Expose the application port (requirement 3.5)
EXPOSE 8080

# Health check — polls the root endpoint every 30s (requirement 3.4)
# wget is available in the alpine image; falls back to exit 1 on failure
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD wget -qO- http://localhost:8080/ || exit 1

# Start the Spring Boot application
ENTRYPOINT ["java", "-jar", "app.jar"]
