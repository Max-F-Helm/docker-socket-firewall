FROM golang:1.23-bookworm AS build

RUN mkdir /build
WORKDIR /build

COPY . /build/

RUN go build -v

FROM busybox:stable

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

RUN mkdir /mnt && mkdir '/mnt/in' && mkdir '/mnt/out' && mkdir '/mnt/conf'
VOLUME /mnt/in
VOLUME /mnt/out
VOLUME /mnt/conf

COPY --from=build /build/docker-socket-firewall /bin/

ENTRYPOINT [ "/entrypoint.sh" ]

