# build stage
FROM golang:1.11 as build-stage
ADD . /go/src/github.com/cloudacademy/oauth2_proxy/
WORKDIR /go/src/github.com/cloudacademy/oauth2_proxy/

RUN go get -u github.com/golang/dep/cmd/dep
RUN dep ensure
RUN bash test.sh
RUN CGO_ENABLED=0 GOOS=linux go build -v -o application

# run stage
FROM alpine:latest  
RUN apk --no-cache add ca-certificates

WORKDIR /root/

COPY --from=build-stage /go/src/github.com/cloudacademy/oauth2_proxy/application application
COPY templates templates

ENV OAUTH2_PROXY_COOKIE_NAME "ca_oauth2_proxy"
ENV OAUTH2_PROXY_COOKIE_EXPIRE "86400"
ENV OAUTH2_PROXY_COOKIE_REFRESH "3600"

EXPOSE 5000

ENTRYPOINT ./application 
