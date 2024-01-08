FROM golang:1.21-alpine as builder

WORKDIR /usr/src/app

RUN apk --no-cache add make pkgconfig cairo-dev gcc g++

COPY go.mod go.sum form.go handler.go prom.go prom_test.go .
COPY cmd cmd
RUN go build cmd/prometheus-png/prometheus-png.go


FROM ubuntu:18.04 as fonts
RUN apt-get update && apt-get install -yy fonts-roboto


FROM alpine:latest

COPY --from=fonts /usr/share/fonts/truetype/roboto/hinted /usr/share/fonts/ttf-roboto-hinted

RUN apk --no-cache add ca-certificates cairo fontconfig ttf-dejavu ttf-freefont && \
    fc-cache -f

WORKDIR /

EXPOSE 8080/tcp

COPY --from=builder /usr/src/app/prometheus-png /usr/bin/prometheus-png

ENTRYPOINT ["prometheus-png"]
