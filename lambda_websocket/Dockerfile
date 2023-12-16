FROM --platform=arm64 public.ecr.aws/lambda/provided:al2 as chef

RUN yum update -y && yum install -y gcc openssl-devel

ARG RUST_VERSION=1.71.1
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain $RUST_VERSION
ENV PATH $PATH:/root/.cargo/bin
RUN cargo install cargo-chef
WORKDIR /app

FROM chef as planner
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

FROM chef AS builder
COPY --from=planner /app/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json
COPY . .
ENV SQLX_OFFLINE true
RUN cargo build --release

FROM --platform=arm64 public.ecr.aws/lambda/provided:al2 as runtime
COPY --from=builder /app/target/release/rust-lambda-stream /var/runtime/bootstrap

CMD ["/var/runtime/bootstrap"]
