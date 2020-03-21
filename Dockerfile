FROM golang:1.7
RUN mkdir -p /app
WORKDIR /app
ADD . /app
RUN go build ./sample.go
CMD ["./sample"]