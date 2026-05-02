FROM node:lts-bookworm-slim

# Match the default WSL2 Ubuntu user to reduce permission friction for npm/Vite outputs.
ARG UID=1000
ARG GID=1000

WORKDIR /var/www/html

# The official Node image already has a node user; adjust it only when needed.
RUN set -eux; \
    current_gid="$(getent group node | cut -d: -f3)"; \
    if [ "${current_gid}" != "${GID}" ]; then \
        groupmod --gid "${GID}" node; \
    fi; \
    current_uid="$(id -u node)"; \
    if [ "${current_uid}" != "${UID}" ]; then \
        usermod --uid "${UID}" --gid "${GID}" node; \
    fi; \
    mkdir -p /var/www/html; \
    chown -R node:node /var/www/html /home/node

USER node

# Vite's default development port.
EXPOSE 5173

CMD ["npm", "--version"]
