# Docker Parent Image with Node
FROM mhart/alpine-node:16 AS builder
WORKDIR /app
COPY . .
RUN mkdir node_modules
RUN npm ci --omit=dev
RUN npm run build

FROM mhart/alpine-node:16
WORKDIR /app
RUN mkdir config
COPY --from=builder app/lib/ ./lib/
COPY --from=builder app/dist/ ./dist/
COPY --from=builder app/package.json ./package.json
COPY --from=builder app/node_modules/ ./node_modules/
COPY ./prisma ./prisma/
COPY ./start_bot.sh .

# migrate database
RUN apk add sqlite curl

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

ENTRYPOINT ["./start_bot.sh"]
