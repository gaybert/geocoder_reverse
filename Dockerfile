FROM node:18-slim

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
COPY package*.json ./
# Use npm install --omit=dev so a package-lock.json is not required in the repo
# and production dependencies are installed. This avoids the `npm ci` failure
# when no lockfile is present (common when repo doesn't include package-lock.json).
RUN npm install --omit=dev --no-audit --no-fund

# Bundle app source
COPY . .

EXPOSE 3000

CMD [ "node", "server.js" ]
