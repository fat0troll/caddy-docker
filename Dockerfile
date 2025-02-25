#
# Builder
#
FROM golang:1.13-alpine AS builder

RUN apk add --no-cache git gcc musl-dev

COPY builder.sh /usr/bin/builder.sh

ARG version="1.0.3"
ARG plugins="git,cors,realip,ipfilter,expires,cache,cloudflare,dnsimple"
ARG enable_telemetry="false"

# process wrapper
RUN go get -v github.com/abiosoft/parent

RUN VERSION=${version} PLUGINS=${plugins} ENABLE_TELEMETRY=${enable_telemetry} /bin/sh /usr/bin/builder.sh

#
# Final stage
#
FROM alpine:3.10
LABEL maintainer "Vladimir Hodakov <vladimir@hodakov.me>"

ARG version="1.0.3"
LABEL caddy_version="$version"

# Let's Encrypt Agreement
ENV ACME_AGREE="false"

# Telemetry Stats
ENV ENABLE_TELEMETRY="$enable_telemetry"

RUN apk add --no-cache \
    ca-certificates \
    git \
    mailcap \
    openssh-client \
    tzdata

# install caddy
COPY --from=builder /install/caddy /usr/bin/caddy

# validate install
RUN /usr/bin/caddy -version
RUN /usr/bin/caddy -plugins

EXPOSE 80 443 2015
VOLUME /etc/caddy/conf.d /srv /root/.caddy
WORKDIR /srv

COPY Caddyfile /etc/caddy/caddy.conf
COPY index.html /srv/default/index.html

# install process wrapper
COPY --from=builder /go/bin/parent /bin/parent

ENTRYPOINT ["/bin/parent", "caddy"]
CMD ["--conf", "/etc/caddy/caddy.conf", "--log", "stdout", "--agree=$ACME_AGREE"]
