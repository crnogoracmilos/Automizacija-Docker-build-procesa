# --- Faza 1: Build okruženje ---
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# --- Faza 2: Produkciono okruženje ---
FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production

# Kopiramo samo neophodne artifakte iz prethodne faze
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/dist ./dist

# Instalacija samo produkcionih zavisnosti (smanjuje površinu napada)
RUN npm install --omit=dev

# Bezbednosna praksa: Ne pokretati aplikaciju kao root korisnik
USER node

EXPOSE 3000
CMD ["node", "dist/index.js"]
