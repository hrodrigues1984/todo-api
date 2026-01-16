# Stage 1: Build Stage
FROM node:20-alpine AS builder
WORKDIR /app

# Install all dependencies (including dev)
COPY package*.json ./
RUN npm ci

# Build the Nest.js application (outputs to /dist)
COPY . .
RUN npm run build

# Stage 2: Dependency Resolution
# This stage installs ONLY production dependencies
FROM node:20-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev

# Stage 3: Production Runner
FROM node:20-alpine AS runner
WORKDIR /app

# Security: Set NODE_ENV to production
ENV NODE_ENV=production

# Copy production dependencies from deps stage
COPY --from=deps --chown=node:node /app/node_modules ./node_modules
# Copy built artifacts from builder stage
COPY --from=builder --chown=node:node /app/dist ./dist
# Copy package.json for runtime scripts if needed
COPY --from=builder --chown=node:node /app/package.json ./

# Security: Drop privileges
USER node

# Expose API port
EXPOSE 3000

CMD ["node", "dist/main"]
