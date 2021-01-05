# syntax=docker/dockerfile:experimental
FROM openjdk:8-jdk as build
WORKDIR /workspace/app

COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
COPY src src

RUN --mount=type=cache,target=/root/.m2 ./mvnw install -DskipTests
RUN mkdir -p target/dependency && (cd target/dependency; jar -xf ../*.jar)

FROM openjdk:8-jre
ARG DEPENDENCY=/workspace/app/target/dependency
EXPOSE 8080
RUN apt-get update && apt-get install -y \
    sqlite3 \
 && rm -rf /var/lib/apt/lists/*
COPY --from=build ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY --from=build ${DEPENDENCY}/META-INF /app/META-INF
COPY --from=build ${DEPENDENCY}/BOOT-INF/classes /app
ENTRYPOINT ["java","-cp","app:app/lib/*","io.snyk.examples.snykest.SnykestApplication"]
