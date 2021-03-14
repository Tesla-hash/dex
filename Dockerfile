FROM rust as builder

# solc v 0.38
ARG solcCommit=4031ef4b35be778b0b98628060cecc7208144123

# tvm some commit (no fresh releases on this repo)
ARG TVMCommit=14be1dd874c01b823937cceb64b5b5b84653d526

RUN apt-get update && apt-get install -y git sudo

WORKDIR /ton
RUN  git clone https://github.com/tonlabs/TON-Solidity-Compiler.git && \
  cd TON-Solidity-Compiler && \
  git checkout $solcCommit && \
  sh ./compiler/scripts/install_deps.sh && \
  mkdir build && \
  cd build && \
  cmake ../compiler/ -DCMAKE_BUILD_TYPE=Release -DSOLC_LINK_STATIC=1 && \
  cmake --build . -- -j8

RUN  git clone https://github.com/tonlabs/TVM-linker.git && \
  cd TVM-linker && \
  git checkout $TVMCommit && \
  cd tvm_linker && \
  cargo build --release

FROM node:14-buster


COPY --from=builder /ton/TON-Solidity-Compiler/build/solc/solc /usr/bin/solc
COPY --from=builder /ton/TON-Solidity-Compiler/lib/stdlib_sol.tvm /usr/lib/stdlib_sol.tvm
COPY --from=builder /ton/TVM-linker/tvm_linker/target/release/tvm_linker /usr/bin/tvm_linker


RUN wget http://sdkbinaries.tonlabs.io/tonos-cli-0_6_0-linux.zip && \
  unzip tonos-cli-0_6_0-linux.zip && mv tonos-cli /usr/local/bin && rm tonos-cli-0_6_0-linux.zip
