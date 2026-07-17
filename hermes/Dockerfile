# TODO: Add the Hermes Agent runtime once its source and launch command are selected.
# The root Compose file expects this Dockerfile at ./hermes/Dockerfile.

FROM alpine:3.20

RUN addgroup -S hermes && adduser -S hermes -G hermes
WORKDIR /app
USER hermes

CMD ["sh", "-c", "echo 'Hermes Agent image placeholder: add application source before deployment.'; sleep infinity"]
