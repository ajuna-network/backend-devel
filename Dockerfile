# Create a docker image which bundles in the same container the ajuna node and worker
# build on the integritee setup
FROM integritee/integritee-dev:0.1.9 as build
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

# produce a 'production' image
FROM integritee/integritee-dev:0.1.9
WORKDIR /demo
COPY ./spid.txt /demo
COPY ./key.txt /demo
COPY ./launch.sh /demo
RUN chmod +x /demo/launch.sh
COPY --from=build /workspace/worker/bin/integritee-service /demo/integritee-service
COPY --from=build /workspace/worker/bin/enclave.signed.so /demo/enclave.signed.so
COPY --from=build /workspace/ajuna-node/target/release/ajuna /demo/ajuna
ENTRYPOINT ["/bin/bash", "-c", "./launch.sh"]
