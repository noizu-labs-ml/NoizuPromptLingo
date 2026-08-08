# syntax=docker/dockerfile:1.7
FROM eclipse-temurin:21-jre-alpine

ARG LIQUIBASE_VERSION=4.29.2

RUN --mount=type=cache,target=/var/cache/apk \
    --mount=type=cache,target=/var/cache/liquibase-dl \
    apk add --no-cache bash curl envsubst \
    && mkdir -p /opt/liquibase \
    && LB_TGZ="/var/cache/liquibase-dl/liquibase-${LIQUIBASE_VERSION}.tar.gz" \
    && PG_JAR="/var/cache/liquibase-dl/postgresql-42.7.4.jar" \
    && if [ ! -s "$LB_TGZ" ]; then \
         curl -fsSL -o "$LB_TGZ" \
           "https://github.com/liquibase/liquibase/releases/download/v${LIQUIBASE_VERSION}/liquibase-${LIQUIBASE_VERSION}.tar.gz"; \
       fi \
    && if [ ! -s "$PG_JAR" ]; then \
         curl -fsSL -o "$PG_JAR" \
           "https://jdbc.postgresql.org/download/postgresql-42.7.4.jar"; \
       fi \
    && tar -xz -C /opt/liquibase -f "$LB_TGZ" \
    && ln -s /opt/liquibase/liquibase /usr/local/bin/liquibase \
    && cp "$PG_JAR" /opt/liquibase/lib/postgresql.jar

WORKDIR /db
COPY changelog/ changelog/
COPY liquibase.properties liquibase.properties.template

CMD ["bash", "-c", "envsubst < liquibase.properties.template > liquibase.properties && liquibase update"]
