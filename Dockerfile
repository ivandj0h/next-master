# Menggunakan image dasar node:20-alpine sebagai base
FROM node:20-alpine AS base

# Stage untuk dependencies
FROM base AS deps

# Menambahkan library yang diperlukan
RUN apk add --no-cache libc6-compat

# Menetapkan direktori kerja
WORKDIR /app

# Menyalin file package.json dan bun.lockb (atau package-lock.json) ke dalam container
COPY package.json bun.lockb ./

# Menginstal dependencies
RUN npm install

# Stage untuk build
FROM base AS builder

# Menetapkan direktori kerja
WORKDIR /app

# Menyalin node_modules dari stage deps
COPY --from=deps /app/node_modules ./node_modules

# Menyalin semua file dari host ke dalam container
COPY . .

# Build aplikasi
RUN npm run build

# Stage untuk menjalankan aplikasi
FROM base AS runner

# Menetapkan direktori kerja
WORKDIR /app

# Mengatur environment untuk production
ENV NODE_ENV=production

# Menambahkan group dan user dengan UID dan GID 1001
RUN addgroup --system -g 1001 nodejs
RUN adduser --system -u 1001 -G nodejs nextjs

# Menyalin direktori public dari stage builder
COPY --from=builder /app/public ./public

# Membuat direktori .next dan mengubah kepemilikan ke user nextjs
RUN mkdir .next
RUN chown -R nextjs:nodejs .next

# Menyalin hasil build dari stage builder dengan kepemilikan nextjs
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

# Menjalankan sebagai user nextjs
USER nextjs

# Membuka port 3000 untuk aplikasi
EXPOSE 3000
ENV PORT 3000

# Perintah untuk menjalankan aplikasi
CMD ["node", "server.js"]
