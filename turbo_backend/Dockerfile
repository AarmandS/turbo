FROM rust:latest

WORKDIR /app

COPY ./src/ ./src/
COPY ./Cargo.toml ./Cargo.toml

RUN apt-get update && apt-get install -y ffmpeg
RUN cargo build --release

EXPOSE 8080

CMD ["target/release/turbo"]
