FROM node:24-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

FROM base AS build
WORKDIR /app
COPY . /app

RUN corepack enable
RUN apk add --no-cache python3 alpine-sdk

RUN --mount=type=cache,id=pnpm,target=/pnpm/store \
    pnpm install --prod --frozen-lockfile

RUN pnpm deploy --filter=@imput/cobalt-api --prod /prod/api

FROM base AS api
WORKDIR /app

COPY --from=build --chown=node:node /prod/api /app
#COPY --from=build --chown=node:node /app/.git /app/.git
RUN mkdir -p /app/.git/refs/heads /app/.git/logs && echo 'ref: refs/heads/main' > /app/.git/HEAD && echo 'a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2' > /app/.git/refs/heads/main && echo '0000000000000000000000000000000000000000 a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2 User <u@example.com> 1234567890 +0000 mock' > /app/.git/logs/HEAD && echo '[core]' > /app/.git/config && echo 'repositoryformatversion = 0' >> /app/.git/config && echo '[remote "origin"]' >> /app/.git/config && echo 'url = https://github.com/imputnet/cobalt.git' >> /app/.git/config && chown -R node:node /app/.git
USER node

EXPOSE 9000
CMD [ "node", "src/cobalt" ]
