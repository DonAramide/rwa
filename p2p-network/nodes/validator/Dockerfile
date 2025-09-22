FROM node:18-alpine

# Install system dependencies
RUN apk add --no-cache \
    git \
    python3 \
    make \
    g++ \
    openssl \
    curl

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy source code
COPY src/ ./src/
COPY config/ ./config/

# Create data directory
RUN mkdir -p /data/validator

# Expose ports
EXPOSE 4001 5001 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:5001/api/v0/id || exit 1

# Set proper permissions
RUN chown -R node:node /app /data
USER node

# Start the validator node
CMD ["node", "src/validator-node.js"]