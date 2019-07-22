# caddy

A [Docker](https://docker.com) image for [Caddy](https://caddyserver.com). This image includes [git](https://caddyserver.com/docs/http.git), [cors](https://caddyserver.com/docs/http.cors), [realip](https://caddyserver.com/docs/http.realip), [expires](https://caddyserver.com/docs/http.expires), [cache](https://caddyserver.com/docs/http.cache), [cloudflare](https://caddyserver.com/docs/tls.dns.cloudflare) and [dnsimple](https://caddyserver.com/docs/tls.dns.dnsimple) plugins.

Plugins can be configured via the [`plugins` build arg](#custom-plugins).

[![](https://images.microbadger.com/badges/image/abiosoft/caddy.svg)](https://microbadger.com/images/abiosoft/caddy "Get your own image badge on microbadger.com")
[![](https://img.shields.io/badge/version-1.0.1-blue.svg)](https://github.com/caddyserver/caddy/tree/v1.0.1)

Check [abiosoft/caddy:builder](https://github.com/abiosoft/caddy-docker/blob/master/BUILDER.md) for generating cross-platform Caddy binaries.

### License

This image is built from [source code](https://github.com/caddyserver/caddy). As such, it is subject to the project's [Apache 2.0 license](https://github.com/caddyserver/caddy/blob/baf6db5b570e36ea2fee30d50f879255a5895370/LICENSE.txt), but it neither contains nor is subject to [the EULA for Caddy's official binary distributions](https://github.com/caddyserver/caddy/blob/545fa844bbd188c1e5bff6926e5c410e695571a0/dist/EULA.txt).

### Let's Encrypt Subscriber Agreement

Caddy may prompt to agree to [Let's Encrypt Subscriber Agreement](https://letsencrypt.org/documents/2017.11.15-LE-SA-v1.2.pdf). This is configurable with `ACME_AGREE` environment variable. Set it to true to agree. `ACME_AGREE=true`.

### Telemetry Stats

Starting from `v0.11.0`, [Telemetry stats](https://caddyserver.com/docs/telemetry) are submitted to Caddy by default. This Docker image opts-out from telemetry automatically.

## Getting Started

```sh
$ docker run -d -p 2015:2015 fat0troll/caddy
```

Point your browser to `http://127.0.0.1:2015`. You will be greeted with Fedora default index.html (distributed with Caddy EPEL packages).

> Be aware! If you don't bind mount the location certificates are saved to, you may hit Let's Encrypt rate [limits](https://letsencrypt.org/docs/rate-limits/) rending further certificate generation or renewal disallowed (for a fixed period)! See "Saving Certificates" below!

### Configuration providing

This image provides easy configuration via supplying directory with Caddy config files. To achieve this, create on your host directory with Caddy configs (named *.conf), and then run:

```sh
$ docker run -d \
    -v $(pwd)/conf:/etc/caddy/conf.d \
    -p 80:80 -p 443:443 \
    fat0troll/caddy
```

Here, `/etc/caddy/conf.d` is the location _inside_ the container where caddy will look for config files.

### Saving Certificates

Save certificates on host machine to prevent regeneration every time container starts.
Let's Encrypt has [rate limit](https://community.letsencrypt.org/t/rate-limits-for-lets-encrypt/6769).

```sh
$ docker run -d \
    -v $(pwd)/conf:/etc/caddy/conf.d \
    -v $HOME/.caddy:/root/.caddy \
    -p 80:80 -p 443:443 \
    fat0troll/caddy
```

Here, `/root/.caddy` is the location _inside_ the container where caddy will save certificates.

Additionally, you can use an _environment variable_ to define the exact location caddy should save generated certificates:

```sh
$ docker run -d \
    -e "CADDYPATH=/etc/caddycerts" \
    -v $HOME/.caddy:/etc/caddycerts \
    -p 80:80 -p 443:443 \
    abiosoft/caddy
```

Above, we utilize the `CADDYPATH` environment variable to define a different location inside the container for
certificates to be stored. This is probably the safest option as it ensures any future docker image changes don't interfere with your ability to save certificates!

### Using git sources

Caddy can serve sites from git repository using [git](https://caddyserver.com/docs/http.git) plugin.

#### Create Caddyfile

Replace `github.com/abiosoft/webtest` with your repository.

```sh
$ printf "0.0.0.0\nroot src\ngit github.com/abiosoft/webtest" > conf/yoursite.conf
```

#### Run the image

```sh
$ docker run -d -v $(pwd)/conf:/etc/caddy/conf.d -p 2015:2015 fat0troll/caddy
```

Point your browser to `http://127.0.0.1:2015`.

## Custom plugins

You can build a docker image with custom plugins by specifying `plugins` build arg as shown in the example below.

```
docker build --build-arg \
    plugins=git,linode \
    github.com/fat0troll/caddy-docker.git
```

## Usage

### Default Caddyfile

The image contains a default Caddyfile.

```
0.0.0.0
browse
```

### Paths in container

Caddyfile: `/etc/caddy.conf`

Caddy configs folder: `/etc/caddy/conf.d`

Sites root: `/srv`

Certificates root: `/root/.caddy`

### Using local sites root

Replace `/path/to/Caddyfile` and `/path/to/sites/root` accordingly.

```sh
$ docker run -d \
    -v /path/to/sites/root:/srv \
    -v path/to/caddy/conf:/etc/caddy/conf.d \
    -p 2015:2015 \
    fat0troll/caddy
```

### Let's Encrypt Auto SSL

**Note** that this does not work on local environments.

Use a valid domain and add email to your Caddyfile to avoid prompt at runtime.
Replace `mydomain.com` with your domain and `user@host.com` with your email.

```
mydomain.com
tls user@host.com
```

#### Let's Encrypt with DNS providers

You can use Cloudflare or DNSimple for obtaining SSL certificates via `dns-01` challenge. This may be more convenient, especially when you trying to obtain certificate on a machine, different from one where you domain resolves.

To use it, you must provide API keys for your DNS provider as environment variables. Without `docker-compose` you can use `--env-file` option to store them in file and not expose them in your shell history.

```sh
$ docker run -d \
    -v $(pwd)/conf:/etc/caddy/conf.d \
    -v $HOME/.caddy:/root/.caddy \
    -p 80:80 -p 443:443 \
    ---env-file=/path/to/envfile \
    fat0troll/caddy
```

Variable names are `CLOUDFLARE_EMAIL`/`CLOUDFLARE_API_KEY` for Cloudflare and `DNSIMPLE_EMAIL`/`DNSIMPLE_OAUTH_TOKEN` for DNSimple.

### Run the image with different ports

You can change the the ports if ports 80 and 443 are not available on host. e.g. 81:80, 444:443

```sh
$ docker run -d \
    -v $(pwd)/conf:/etc/caddy/conf.d \
    -v $HOME/.caddy:/root/.caddy \
    -p 80:80 -p 443:443 \
    fat0troll/caddy
```
