FROM maven:3.9.6-eclipse-temurin-17-alpine

WORKDIR /app

COPY pom.xml .
RUN mvn dependency:resolve -q

COPY . .

EXPOSE 8080

CMD ["mvn", "-DskipTests", "spring-boot:run"]
