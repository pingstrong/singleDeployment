ARG ALPINE_VERSION=alpine:latest
FROM ${ALPINE_VERSION} as baseOs

ARG TZ

RUN mkdir /yapi
WORKDIR /yapi
### install dependecy

RUN apk --no-cache add tzdata \
    && cp "/usr/share/zoneinfo/$TZ" /etc/localtime \
    && echo "$TZ" > /etc/timezone

RUN apk add --no-cache \
    curl \
    bash \
    g++ \
    gcc \
    vim \
    git \
    nodejs \
    npm \
    && npm install -g yarn \
    #&& npm install -g yapi-cli --registry https://registry.npm.taobao.org \
    && npm install pm2 -g

### clone yapi code
RUN git clone https://github.com/thinkpanax/yapi.git vendors \
    && cp vendors/config_example.json ./config.json \
    && cd vendors \
    && npm install --production --registry https://registry.npm.taobao.org \
    && npm run install-server \
    && node server/app.js
