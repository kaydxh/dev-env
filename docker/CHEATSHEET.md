# Docker 常用命令速查

## 目录

- [镜像管理](#镜像管理)
- [容器生命周期](#容器生命周期)
- [容器信息与监控](#容器信息与监控)
- [容器交互](#容器交互)
- [网络管理](#网络管理)
- [存储卷管理](#存储卷管理)
- [Docker Compose](#docker-compose)
- [镜像构建](#镜像构建)
- [镜像仓库](#镜像仓库)
- [日志与调试](#日志与调试)
- [系统与清理](#系统与清理)
- [常用技巧](#常用技巧)

---

## 镜像管理

### 查看镜像

| 命令 | 功能 |
|------|------|
| `docker images` | 列出本地镜像 |
| `docker images -a` | 列出所有镜像（含中间层） |
| `docker images --filter dangling=true` | 列出悬空镜像 |
| `docker images --format "{{.Repository}}:{{.Tag}}"` | 自定义格式输出 |
| `docker image inspect <image>` | 查看镜像详情 |
| `docker image history <image>` | 查看镜像构建历史 |

### 拉取与推送

| 命令 | 功能 |
|------|------|
| `docker pull <image>` | 拉取镜像 |
| `docker pull <image>:<tag>` | 拉取指定标签镜像 |
| `docker push <image>:<tag>` | 推送镜像到仓库 |
| `docker tag <source> <target>` | 给镜像打标签 |

### 删除镜像

| 命令 | 功能 |
|------|------|
| `docker rmi <image>` | 删除镜像 |
| `docker rmi -f <image>` | 强制删除镜像 |
| `docker image prune` | 删除悬空镜像 |
| `docker image prune -a` | 删除所有未使用镜像 |

### 导入导出

| 命令 | 功能 |
|------|------|
| `docker save -o file.tar <image>` | 导出镜像为 tar 文件 |
| `docker load -i file.tar` | 从 tar 文件加载镜像 |
| `docker export <container> > file.tar` | 导出容器文件系统 |
| `docker import file.tar <image>:<tag>` | 从 tar 导入为镜像 |

### 实际示例

```bash
# 拉取指定版本的 Go 镜像
docker pull golang:1.21-alpine

# 给镜像打标签准备推送到私有仓库
docker tag myapp:latest registry.example.com/myapp:v1.0.0
docker push registry.example.com/myapp:v1.0.0

# 导出镜像给离线环境使用
docker save -o myapp-v1.0.0.tar myapp:v1.0.0
# 在离线机器上加载
docker load -i myapp-v1.0.0.tar

# 查看镜像的构建层（排查镜像体积问题）
docker image history --no-trunc myapp:latest
```

---

## 容器生命周期

### 创建与运行

| 命令 | 功能 |
|------|------|
| `docker run <image>` | 创建并运行容器 |
| `docker run -d <image>` | 后台运行容器 |
| `docker run -it <image> /bin/sh` | 交互式运行 |
| `docker run --name <name> <image>` | 指定容器名称 |
| `docker run -p 8080:80 <image>` | 端口映射（宿主:容器） |
| `docker run -v /host:/container <image>` | 挂载目录 |
| `docker run --rm <image>` | 退出后自动删除容器 |
| `docker run -e KEY=VALUE <image>` | 设置环境变量 |
| `docker run --env-file .env <image>` | 从文件加载环境变量 |
| `docker run --network <net> <image>` | 指定网络 |
| `docker run --restart=always <image>` | 设置重启策略 |
| `docker run -m 512m --cpus=1 <image>` | 限制内存和 CPU |
| `docker create <image>` | 只创建不启动 |

### 启停与删除

| 命令 | 功能 |
|------|------|
| `docker start <container>` | 启动容器 |
| `docker stop <container>` | 停止容器（优雅） |
| `docker restart <container>` | 重启容器 |
| `docker kill <container>` | 强制停止容器 |
| `docker pause <container>` | 暂停容器 |
| `docker unpause <container>` | 恢复容器 |
| `docker rm <container>` | 删除容器 |
| `docker rm -f <container>` | 强制删除运行中容器 |
| `docker container prune` | 删除所有停止的容器 |

### 实际示例

```bash
# 运行 Redis 并持久化数据
docker run -d --name redis \
  -p 6379:6379 \
  -v redis-data:/data \
  --restart=always \
  redis:7-alpine redis-server --appendonly yes

# 运行 MySQL 并设置密码
docker run -d --name mysql \
  -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=secret \
  -v mysql-data:/var/lib/mysql \
  mysql:8.0

# 临时运行一个工具容器（退出即删除）
docker run --rm -it alpine sh

# 运行容器并限制资源
docker run -d --name app \
  -m 256m --cpus=0.5 \
  --restart=unless-stopped \
  myapp:latest

# 批量停止所有运行中的容器
docker stop $(docker ps -q)

# 批量删除所有停止的容器
docker rm $(docker ps -aq -f status=exited)
```

---

## 容器信息与监控

| 命令 | 功能 |
|------|------|
| `docker ps` | 列出运行中的容器 |
| `docker ps -a` | 列出所有容器 |
| `docker ps -q` | 只显示容器 ID |
| `docker ps --format "table {{.Names}}\t{{.Status}}"` | 自定义格式 |
| `docker inspect <container>` | 查看容器详情 |
| `docker stats` | 实时资源使用统计 |
| `docker stats --no-stream` | 单次输出统计 |
| `docker top <container>` | 查看容器内进程 |
| `docker port <container>` | 查看端口映射 |
| `docker diff <container>` | 查看文件系统变更 |

### 实际示例

```bash
# 查看容器的 IP 地址
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mycontainer

# 查看容器的资源限制
docker inspect -f '{{.HostConfig.Memory}}' mycontainer

# 监控所有容器的资源使用（单次快照）
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"

# 查看容器的重启次数
docker inspect -f '{{.RestartCount}}' mycontainer
```

---

## 容器交互

| 命令 | 功能 |
|------|------|
| `docker exec -it <container> /bin/sh` | 进入容器 shell |
| `docker exec -it <container> bash` | 进入容器 bash |
| `docker exec <container> <cmd>` | 在容器中执行命令 |
| `docker exec -u root <container> <cmd>` | 以 root 执行 |
| `docker attach <container>` | 附加到容器主进程 |
| `docker cp <container>:/path /local` | 从容器复制文件 |
| `docker cp /local <container>:/path` | 复制文件到容器 |
| `docker logs <container>` | 查看容器日志 |
| `docker logs -f <container>` | 实时跟踪日志 |
| `docker logs --tail 100 <container>` | 查看最后 100 行 |
| `docker logs --since 1h <container>` | 查看最近 1 小时日志 |

### 实际示例

```bash
# 进入运行中的容器排查问题
docker exec -it myapp /bin/sh

# 在容器中执行命令查看配置
docker exec myapp cat /etc/nginx/nginx.conf

# 从容器中复制日志文件到本地分析
docker cp myapp:/var/log/app.log ./app.log

# 实时查看容器日志并过滤错误
docker logs -f myapp 2>&1 | grep -i error

# 查看容器最近 30 分钟的日志
docker logs --since 30m myapp
```

---

## 网络管理

| 命令 | 功能 |
|------|------|
| `docker network ls` | 列出所有网络 |
| `docker network create <name>` | 创建网络 |
| `docker network create --driver bridge <name>` | 创建 bridge 网络 |
| `docker network create --subnet=172.20.0.0/16 <name>` | 指定子网 |
| `docker network inspect <name>` | 查看网络详情 |
| `docker network connect <net> <container>` | 将容器连接到网络 |
| `docker network disconnect <net> <container>` | 断开容器网络 |
| `docker network rm <name>` | 删除网络 |
| `docker network prune` | 删除未使用的网络 |

### 实际示例

```bash
# 创建自定义网络让容器间通过名称通信
docker network create app-net
docker run -d --name db --network app-net mysql:8.0
docker run -d --name app --network app-net myapp:latest
# app 容器中可以通过 "db" 作为主机名访问 MySQL

# 查看网络中有哪些容器
docker network inspect app-net --format '{{range .Containers}}{{.Name}} {{end}}'

# 将已运行的容器加入新网络
docker network connect app-net existing-container
```

---

## 存储卷管理

| 命令 | 功能 |
|------|------|
| `docker volume ls` | 列出所有卷 |
| `docker volume create <name>` | 创建卷 |
| `docker volume inspect <name>` | 查看卷详情 |
| `docker volume rm <name>` | 删除卷 |
| `docker volume prune` | 删除未使用的卷 |

### 挂载方式对比

```bash
# 命名卷（推荐用于持久化数据）
docker run -v mydata:/data <image>

# 绑定挂载（开发时挂载代码目录）
docker run -v $(pwd):/app <image>

# 只读挂载
docker run -v $(pwd)/config:/etc/app/config:ro <image>

# tmpfs 挂载（内存文件系统，适合敏感数据）
docker run --tmpfs /tmp <image>
```

### 实际示例

```bash
# 备份卷数据
docker run --rm -v mydata:/data -v $(pwd):/backup alpine \
  tar czf /backup/mydata-backup.tar.gz -C /data .

# 恢复卷数据
docker run --rm -v mydata:/data -v $(pwd):/backup alpine \
  tar xzf /backup/mydata-backup.tar.gz -C /data

# 查看卷在宿主机上的实际路径
docker volume inspect mydata --format '{{.Mountpoint}}'
```

---

## Docker Compose

### 基本命令

| 命令 | 功能 |
|------|------|
| `docker compose up` | 启动所有服务 |
| `docker compose up -d` | 后台启动 |
| `docker compose up --build` | 重新构建并启动 |
| `docker compose down` | 停止并删除容器 |
| `docker compose down -v` | 停止并删除容器和卷 |
| `docker compose stop` | 停止服务 |
| `docker compose start` | 启动已停止的服务 |
| `docker compose restart` | 重启服务 |
| `docker compose ps` | 查看服务状态 |
| `docker compose logs` | 查看所有服务日志 |
| `docker compose logs -f <service>` | 跟踪指定服务日志 |
| `docker compose exec <service> <cmd>` | 在服务中执行命令 |
| `docker compose run <service> <cmd>` | 运行一次性命令 |
| `docker compose pull` | 拉取所有服务镜像 |
| `docker compose build` | 构建所有服务 |
| `docker compose config` | 验证并查看配置 |
| `docker compose top` | 查看各服务进程 |

### 扩展命令

| 命令 | 功能 |
|------|------|
| `docker compose up -d --scale web=3` | 扩展服务实例数 |
| `docker compose -f custom.yml up` | 指定配置文件 |
| `docker compose -f a.yml -f b.yml up` | 多配置文件合并 |
| `docker compose --profile debug up` | 启动指定 profile |
| `docker compose cp <service>:/path ./local` | 从服务复制文件 |

### 实际示例

```bash
# 开发环境启动（带实时日志）
docker compose up --build

# 生产环境后台启动
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# 只重启某个服务
docker compose restart api

# 查看某个服务的日志
docker compose logs -f --tail 50 api

# 进入服务容器排查
docker compose exec api sh

# 完全清理（含卷和镜像）
docker compose down -v --rmi all
```

---

## 镜像构建

### 构建命令

| 命令 | 功能 |
|------|------|
| `docker build -t <name>:<tag> .` | 构建镜像 |
| `docker build -f Dockerfile.dev .` | 指定 Dockerfile |
| `docker build --no-cache .` | 不使用缓存构建 |
| `docker build --target <stage> .` | 多阶段构建指定目标 |
| `docker build --build-arg KEY=VAL .` | 传递构建参数 |
| `docker build --platform linux/amd64 .` | 指定目标平台 |
| `docker buildx build --platform linux/amd64,linux/arm64 .` | 多平台构建 |

### Dockerfile 最佳实践

```dockerfile
# 多阶段构建示例（Go 项目）
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -o /app/server ./cmd/server

FROM alpine:3.18
RUN apk --no-cache add ca-certificates tzdata
COPY --from=builder /app/server /usr/local/bin/server
EXPOSE 8080
ENTRYPOINT ["server"]
```

### 实际示例

```bash
# 构建并指定标签
docker build -t myapp:v1.0.0 .

# 多阶段构建只构建到测试阶段
docker build --target test -t myapp:test .

# 跨平台构建（需要 buildx）
docker buildx create --use
docker buildx build --platform linux/amd64,linux/arm64 \
  -t registry.example.com/myapp:latest --push .

# 利用缓存加速构建（先复制依赖文件）
# Dockerfile 中先 COPY go.mod go.sum，再 RUN go mod download
# 最后 COPY . . 这样代码变更不会导致依赖重新下载
```

---

## 镜像仓库

| 命令 | 功能 |
|------|------|
| `docker login` | 登录 Docker Hub |
| `docker login <registry>` | 登录私有仓库 |
| `docker logout` | 退出登录 |
| `docker search <term>` | 搜索镜像 |
| `docker pull <registry>/<image>:<tag>` | 从私有仓库拉取 |
| `docker push <registry>/<image>:<tag>` | 推送到私有仓库 |

### 实际示例

```bash
# 登录私有仓库
docker login registry.example.com -u username

# 推送到私有仓库的完整流程
docker build -t myapp:v1.0.0 .
docker tag myapp:v1.0.0 registry.example.com/team/myapp:v1.0.0
docker push registry.example.com/team/myapp:v1.0.0
```

---

## 日志与调试

| 命令 | 功能 |
|------|------|
| `docker logs <container>` | 查看日志 |
| `docker logs -f <container>` | 实时跟踪日志 |
| `docker logs --tail 100 <container>` | 最后 100 行 |
| `docker logs --since 2h <container>` | 最近 2 小时 |
| `docker logs -t <container>` | 显示时间戳 |
| `docker events` | 实时监听 Docker 事件 |
| `docker events --filter type=container` | 过滤容器事件 |
| `docker inspect <container>` | 查看容器完整配置 |
| `docker system df` | 查看磁盘使用 |
| `docker system info` | 查看 Docker 系统信息 |

### 实际示例

```bash
# 查看容器退出原因
docker inspect <container> --format '{{.State.ExitCode}} {{.State.Error}}'

# 查看容器的 OOM 状态
docker inspect <container> --format '{{.State.OOMKilled}}'

# 实时监控 Docker 事件（排查容器频繁重启）
docker events --filter event=die --filter event=start

# 查看容器的健康检查状态
docker inspect --format '{{json .State.Health}}' <container> | jq
```

---

## 系统与清理

| 命令 | 功能 |
|------|------|
| `docker system df` | 查看磁盘使用情况 |
| `docker system df -v` | 详细磁盘使用 |
| `docker system prune` | 清理未使用资源 |
| `docker system prune -a` | 清理所有未使用资源（含镜像） |
| `docker system prune --volumes` | 清理含未使用卷 |
| `docker image prune` | 清理悬空镜像 |
| `docker container prune` | 清理停止的容器 |
| `docker volume prune` | 清理未使用卷 |
| `docker network prune` | 清理未使用网络 |
| `docker builder prune` | 清理构建缓存 |

### 实际示例

```bash
# 查看 Docker 占用了多少磁盘空间
docker system df

# 一键清理所有未使用资源（⚠️ 慎用，会删除未使用的镜像）
docker system prune -a --volumes

# 只清理 7 天前的悬空镜像
docker image prune -a --filter "until=168h"

# 清理构建缓存（构建缓存可能占用大量空间）
docker builder prune --all
```

---

## 常用技巧

### 容器健康检查

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1
```

### 多阶段构建减小镜像体积

```dockerfile
# 构建阶段
FROM node:18 AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

# 运行阶段
FROM node:18-alpine
WORKDIR /app
COPY --from=build /app/dist ./dist
COPY --from=build /app/node_modules ./node_modules
CMD ["node", "dist/main.js"]
```

### 常用 docker run 模板

```bash
# Web 服务模板
docker run -d \
  --name myservice \
  --restart=unless-stopped \
  -p 8080:8080 \
  -v $(pwd)/config:/etc/app:ro \
  -v app-data:/data \
  -e TZ=Asia/Shanghai \
  --health-cmd="curl -f http://localhost:8080/health || exit 1" \
  --health-interval=30s \
  myapp:latest

# 开发调试模板
docker run --rm -it \
  -v $(pwd):/app \
  -w /app \
  -p 8080:8080 \
  golang:1.21 \
  go run main.go
```

### 实用 Shell 别名

```bash
# ~/.zshrc 或 ~/.bashrc
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dlog='docker logs -f --tail 100'
alias dexec='docker exec -it'
alias dclean='docker system prune -f'
alias dstop='docker stop $(docker ps -q)'
```
