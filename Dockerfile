# Clone repo
FROM alpine/git as cloner

WORKDIR /usr/src/rolex

RUN git clone https://github.com/tribeiro/rs_lsst_efd_client.git 
RUN git clone https://github.com/tribeiro/rolex-data.git
RUN git clone https://github.com/tribeiro/rolex-frontend.git

# Build 
FROM rust:1.82.0 as builder

WORKDIR /usr/src/rolex

COPY --from=cloner /usr/src/rolex/rs_lsst_efd_client /usr/src/rolex/lsst_efd_client
COPY --from=cloner /usr/src/rolex/rolex-data /usr/src/rolex/rolex
COPY --from=cloner /usr/src/rolex/rolex-frontend /usr/src/rolex/rolex-frontend

COPY Cargo.toml .

RUN ls -la && cargo build -r --bin rolex-frontend

# Deployment image
FROM debian:bookworm-slim

RUN apt-get update
RUN apt-get install -y ca-certificates

COPY --from=builder /usr/src/rolex/target/release/rolex-frontend /usr/local/bin/rolex-frontend
COPY assets/ assets/

EXPOSE 3000

CMD ["rolex-frontend"]

