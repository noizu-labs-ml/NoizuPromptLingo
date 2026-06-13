FROM eclipse-temurin:21-jre-alpine

ARG LIQUIBASE_VERSION=4.29.2

RUN apk add --no-cache bash curl envsubst \
    && mkdir -p /opt/liquibase \
    && curl -L "https://github.com/liquibase/liquibase/releases/download/v${LIQUIBASE_VERSION}/liquibase-${LIQUIBASE_VERSION}.tar.gz" \
    | tar -xz -C /opt/liquibase \
    && ln -s /opt/liquibase/liquibase /usr/local/bin/liquibase \
    && curl -L "https://jdbc.postgresql.org/download/postgresql-42.7.4.jar" \
    -o /opt/liquibase/lib/postgresql.jar

WORKDIR /db
COPY changelog/ changelog/
COPY liquibase.properties liquibase.properties.template

CMD ["bash", "-c", "envsubst < liquibase.properties.template > liquibase.properties && liquibase update"]
