# Build image
FROM swift:4.2 as builder
RUN apt-get -qq update && apt-get -q -y install \
  libssl1.0.0 libssl-dev
WORKDIR /app
COPY . .
RUN mkdir -p /build/lib && cp -R /usr/lib/swift/linux/*.so /build/lib
RUN swift build -c release && mv `swift build -c release --show-bin-path` /build/bin

# Production image
FROM ubuntu:16.04
RUN apt-get -qq update && apt-get install -y \
  libicu55 libxml2 libbsd0 libcurl3 libatomic1 tzdata \
  && rm -r /var/lib/apt/lists/*
WORKDIR /app
COPY Resources/ ./Resources/
COPY --from=builder /build/bin/Run .
COPY --from=builder /build/lib/* /usr/lib/
EXPOSE 80
CMD ["./Run", "serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "80"]
