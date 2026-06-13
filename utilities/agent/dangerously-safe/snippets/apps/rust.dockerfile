# requires: base
# apt: build-essential, pkg-config
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
      | sh -s -- -y --no-modify-path --profile minimal \
    && echo 'source $HOME/.cargo/env' >> /root/.bashrc
ENV PATH=/root/.cargo/bin:$PATH
