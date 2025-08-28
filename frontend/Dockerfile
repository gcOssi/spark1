# Example React build (adjust to your app)
FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:18-alpine AS serve
# Your app serves on 3000
WORKDIR /app
COPY --from=build /app .
EXPOSE 3000
CMD ["npm", "start"]
