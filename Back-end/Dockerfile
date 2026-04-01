# Stage 1: Build
FROM maven:3.9.6-eclipse-temurin-17-alpine AS build
WORKDIR /app

# Copy pom.xml and download dependencies to take advantage of Docker caching
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy the rest of the code and build the JAR
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Runtime
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Copy only the compiled JAR from the build stage
COPY --from=build /app/target/*.jar app.jar

# Expose the API port
EXPOSE 8080

# Environment variables with defaults (can be overridden on Render)
ENV SPRING_PROFILES_ACTIVE=prod
ENV SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/logitrack_db
ENV SPRING_DATASOURCE_USERNAME=logi_user
ENV SPRING_DATASOURCE_PASSWORD=logi_password

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar", "--server.port=${PORT:-8080}"]
