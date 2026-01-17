# Stage 1: Build Stage
FROM oven/bun:1-alpine AS builder
WORKDIR /app

# Install all dependencies (including dev)
COPY package.json bun.lockb* ./
RUN bun install --frozen-lockfile

# Build the Nest.js application (outputs to /dist)
COPY . .
RUN bun run build

# Stage 2: Dependency Resolution
# This stage installs ONLY production dependencies
FROM oven/bun:1-alpine AS deps
WORKDIR /app
COPY package.json bun.lockb* ./
RUN bun install --frozen-lockfile --production

# Stage 3: Production Runner
FROM oven/bun:1-alpine AS runner
WORKDIR /app

# Security: Set NODE_ENV to production
ENV NODE_ENV=production

# Copy production dependencies from deps stage
COPY --from=deps --chown=bun:bun /app/node_modules ./node_modules
# Copy built artifacts from builder stage
COPY --from=builder --chown=bun:bun /app/dist ./dist
# Copy package.json for runtime scripts if needed
COPY --from=builder --chown=bun:bun /app/package.json ./

# Security: Drop privileges
USER bun

# Expose API port
EXPOSE 3000

CMD ["bun", "run", "dist/main.js"]
