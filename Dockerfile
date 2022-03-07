FROM integritee/integritee-dev:0.1.9
WORKDIR /workspace
COPY . .
WORKDIR /workspace/worker
RUN git config --global credential.helper store
# WARNING, this token should be managed as a secret
RUN echo "https://andy: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@github.com" > ~/.git-credentials
RUN rustup show
RUN CARGO_NET_GIT_FETCH_WITH_CLI=true SGX_MODE=SW make
WORKDIR /workspace/ajuna-node
RUN cargo build --release
#ENTRYPOINT ["./bin/integritee-service", "-r", "3485", "run", "--dev", "--skip-ra"]
