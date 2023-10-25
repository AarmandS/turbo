# Use an official Flutter image for building the app
FROM ghcr.io/cirruslabs/flutter:stable AS build-env

# Set the working directory
WORKDIR /app

# Copy the Flutter web app's source code to the container
COPY . .

ARG BACKEND_URL
RUN flutter pub get
RUN flutter build web --dart-define=BACKEND_URL=$BACKEND_URL

FROM nginx:alpine

# Copy the built Flutter web app from the previous stage
COPY --from=build-env /app/build/web /usr/share/nginx/html

EXPOSE 80

# Start the Nginx web server
CMD ["nginx", "-g", "daemon off;"]