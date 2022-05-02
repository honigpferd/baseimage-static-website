# baseimage-static-website
a very small docker image (~200KB) to run any static website, based on the thttpd static file server.

## usage

reuse with `Dockerfile`
```Dockerfile
FROM ghcr.io/honigpferd/baseimage-static-website

COPY . /home/static/
```
exclude files via `.dockerignore`

### build
```Shell
docker build --rm -t mysite:1 .
```

### run
```Shell
docker run --rm -p 8080:80 mysite:1
```
open http://localhost:8080
