FROM golang:1.16.4-alpine3.13 AS build

WORKDIR /src/
COPY /src/main.go /src/
COPY /go.* /src/
RUN CGO_ENABLED=0 go build -o /bin/server

FROM scratch
COPY --from=build /bin/server /bin/server
ENTRYPOINT ["/bin/server"]
