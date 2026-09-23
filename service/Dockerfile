FROM node:22-alpine AS runtime
WORKDIR /app
COPY package.json ./
RUN npm install --omit=dev --ignore-scripts --no-audit --no-fund
COPY src ./src
COPY migrations ./migrations
ENV NODE_ENV=production
EXPOSE 8787
CMD ["node", "src/server.js"]
