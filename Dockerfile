FROM golang:alpine AS builder

# 为我们的镜像设置必要的环境变量
ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64\
    GOPROXY="https://goproxy.cn,direct"

# 移动到工作目录：/build
WORKDIR /build

# 复制项目中的 go.mod 和 go.sum文件并下载依赖信息
COPY go.mod .
COPY go.sum .
RUN go mod download

# 将代码复制到容器中
COPY . .

# 将我们的代码编译成二进制可执行文件 tracer
RUN go build -o tracer .

# 创建一个小镜像
FROM debian:stretch-slim

# 静态文件
# COPY ./log /log
# COPY ./config /config
COPY config.toml config.toml
# wait-for-it通用文件很重要，
COPY ./wait-for-it.sh /
# 当出现static文件或者template文件的时候需要配置
COPY ./static /static
# COPY ./template /template

# 从builder镜像中把/dist/tracer 拷贝到当前目录
COPY --from=builder /build/tracer /

RUN chmod 755 wait-for-it.sh

EXPOSE 8000

# 需要运行的命令,使用docker-compose.yaml注释ENTRYPOINT ["/tracer", "config.toml"]
# ENTRYPOINT ["/tracer", "config.toml"]

# docker run -d --name mysql -p 3306:3306 -v /usr/local/docker/mysql/config/mysqld.cnf:/etc/mysql/mysql.conf.d/mysqld.cnf -v /usr/local/docker/mysql/data/mysql:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=ljf3692553690. mysql:8.0.32

# docker run -p 6379:6379 --name redis -v /usr/local/docker/redis/redis.conf:/etc/redis/redis.conf -v /usr/local/docker/redis/data:/data -d redis:alpine redis-server /etc/redis/redis.conf --appendonly yes
# addr ="192.168.0.106:8081"
