FROM golang AS build-env

ADD . /go/src

WORKDIR /go/src/cloud

RUN GOOS=linux GOARCH=386 go build -v -o cloud-server


FROM alpine

WORKDIR /usr/src/app

RUN mkdir -p /usr/src/app && \
    apk add -U tzdata && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    mkdir /lib64 && \
    ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2

COPY --from=build-env /go/src/cloud/cloud-server /usr/src/app/cloud-server
COPY --from=build-env /go/src/cloud/conf /usr/src/app/conf
COPY --from=build-env /go/src/cloud/views /usr/src/app/views
COPY --from=build-env /go/src/cloud/static /usr/src/app/static

EXPOSE 9090

CMD [ "./cloud-server" ]

