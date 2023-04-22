FROM alpine:3.16.5 AS builder

ARG THTTPD_VERSION=2.29

# Install all dependencies required for compiling thttpd
RUN apk --no-cache add \
  gcc=11.2.1_git20220219-r2 \
  musl-dev=1.2.3-r2 \
  make=4.3-r0

# Download thttpd sources
RUN wget -q http://www.acme.com/software/thttpd/thttpd-${THTTPD_VERSION}.tar.gz \
  && tar xzf thttpd-${THTTPD_VERSION}.tar.gz \
  && mv /thttpd-${THTTPD_VERSION} /thttpd

# Compile thttpd to a static binary which we can copy around
WORKDIR /thttpd
RUN ./configure \
  && make CCOPT='-O2 -s -static' thttpd

# Create a non-root user to own the files and run our server
RUN adduser -D static

# Switch to the scratch image
FROM scratch

EXPOSE 80

# Copy over the user
COPY --from=builder /etc/passwd /etc/passwd

# Copy the thttpd static binary
COPY --from=builder /thttpd/thttpd /

# Use our non-root user
#USER static
### disabling omits CrashLoopBackOff in k8s
### probably due to SecurityContext settings

WORKDIR /home/static

# Copy the static website
# Use the .dockerignore file to control what ends up inside the image!
COPY . .

# Run thttpd
CMD ["/thttpd", "-D", "-h", "0.0.0.0", "-p", "80", "-d", "/home/static", "-u", "static", "-l", "-", "-M", "60"]
