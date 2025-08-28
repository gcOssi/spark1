# Example Node API (adjust to your app)
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN if [ -f package-lock.json ]; then npm ci; else npm install; fi
COPY . .
EXPOSE 4000
CMD ["npm", "run", "start"]
