FROM ghcr.io/cirruslabs/flutter:stable AS build-env

WORKDIR /app

COPY . .

ARG BACKEND_URL

RUN flutter pub get
RUN flutter build web --dart-define=BACKEND_URL=$BACKEND_URL

FROM nginx:alpine

COPY --from=build-env /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
