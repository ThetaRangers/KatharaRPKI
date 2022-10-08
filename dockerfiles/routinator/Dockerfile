FROM ferrarally/frr
RUN apt update
RUN apt upgrade -y
RUN apt install -y rsync curl build-essential libssl-dev openssl pkg-config
RUN curl -fsSL https://packages.nlnetlabs.nl/aptkey.asc | gpg --dearmor -o /usr/share/keyrings/nlnetlabs-archive-keyring.gpg
RUN echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/nlnetlabs-archive-keyring.gpg] https://packages.nlnetlabs.nl/linux/debian \
$(lsb_release -cs) main" | tee /etc/apt/sources.list.d/nlnetlabs.list > /dev/null
RUN apt update
RUN apt install -y routinator
