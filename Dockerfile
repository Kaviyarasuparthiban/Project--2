# stage 1: build
FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci --legacy-peer-deps
COPY . .
RUN npm run build

# stage 2: serve static files
FROM nginx:stable-alpine
COPY --from=build /app/build /usr/share/nginx/html
# Ensure nginx listens on 3000 by changing default port (optional)
RUN sed -i 's/listen       80;/listen       3000;/' /etc/nginx/conf.d/default.conf
EXPOSE 3000
CMD ["nginx", "-g", "daemon off;"]
