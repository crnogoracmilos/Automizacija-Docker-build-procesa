# --- Faza 1: Instalacija zavisnosti (Build faza) ---
FROM node:20-slim AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install

# --- Faza 2: Produkciono okruženje (Runner faza) ---
FROM node:20-slim AS runner
WORKDIR /app
ENV NODE_ENV=production
RUN apt-get update \
    && apt-get install -y --no-install-recommends --only-upgrade libcap2 libgnutls30 \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /usr/local/lib/node_modules/npm \
    && rm -f /usr/local/bin/npm /usr/local/bin/npx /usr/local/bin/corepack

# Kopiramo biblioteke iz prve faze (Multi-stage optimizacija)
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY . .

EXPOSE 3000
CMD ["node", "index.js"]
