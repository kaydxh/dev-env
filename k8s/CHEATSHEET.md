# Kubernetes 常用命令速查

## 目录

- [集群信息](#集群信息)
- [上下文与配置](#上下文与配置)
- [命名空间](#命名空间)
- [Pod 管理](#pod-管理)
- [Deployment 管理](#deployment-管理)
- [Service 管理](#service-管理)
- [ConfigMap 与 Secret](#configmap-与-secret)
- [日志与调试](#日志与调试)
- [资源查看与描述](#资源查看与描述)
- [标签与注解](#标签与注解)
- [滚动更新与回滚](#滚动更新与回滚)
- [扩缩容](#扩缩容)
- [Job 与 CronJob](#job-与-cronjob)
- [持久化存储](#持久化存储)
- [网络与 Ingress](#网络与-ingress)
- [节点管理](#节点管理)
- [RBAC 权限](#rbac-权限)
- [资源配额与限制](#资源配额与限制)
- [Helm 包管理](#helm-包管理)
- [常用技巧](#常用技巧)

---

## 集群信息

| 命令 | 功能 |
|------|------|
| `kubectl cluster-info` | 查看集群信息 |
| `kubectl version` | 查看客户端和服务端版本 |
| `kubectl version --short` | 简短版本信息 |
| `kubectl api-resources` | 列出所有 API 资源类型 |
| `kubectl api-versions` | 列出所有 API 版本 |
| `kubectl get componentstatuses` | 查看集群组件状态 |
| `kubectl top nodes` | 查看节点资源使用 |
| `kubectl top pods` | 查看 Pod 资源使用 |

---

## 上下文与配置

| 命令 | 功能 |
|------|------|
| `kubectl config view` | 查看 kubeconfig 配置 |
| `kubectl config current-context` | 查看当前上下文 |
| `kubectl config get-contexts` | 列出所有上下文 |
| `kubectl config use-context <ctx>` | 切换上下文 |
| `kubectl config set-context --current --namespace=<ns>` | 设置当前上下文的默认命名空间 |
| `kubectl config set-cluster <name> --server=<url>` | 设置集群地址 |
| `kubectl config set-credentials <user> --token=<token>` | 设置用户凭证 |
| `kubectl config delete-context <ctx>` | 删除上下文 |

### 实际示例

```bash
# 切换到生产环境集群
kubectl config use-context prod-cluster

# 设置默认命名空间为 my-app，避免每次都加 -n
kubectl config set-context --current --namespace=my-app

# 查看当前使用的集群和用户
kubectl config current-context

# 合并多个 kubeconfig 文件
KUBECONFIG=~/.kube/config:~/.kube/config-prod kubectl config view --merge --flatten > ~/.kube/config-merged
```

---

## 命名空间

| 命令 | 功能 |
|------|------|
| `kubectl get namespaces` | 列出所有命名空间 |
| `kubectl create namespace <name>` | 创建命名空间 |
| `kubectl delete namespace <name>` | 删除命名空间（⚠️ 删除其下所有资源） |
| `kubectl get all -n <namespace>` | 查看命名空间下所有资源 |
| `kubectl get pods --all-namespaces` | 查看所有命名空间的 Pod |
| `kubectl get pods -A` | 同上（简写） |

### 实际示例

```bash
# 创建开发环境命名空间
kubectl create namespace dev

# 查看某个命名空间下的所有资源
kubectl get all -n kube-system

# 查看所有命名空间中的 Pod（排查问题时常用）
kubectl get pods -A --sort-by='.status.startTime'
```

---

## Pod 管理

### 查看 Pod

| 命令 | 功能 |
|------|------|
| `kubectl get pods` | 列出当前命名空间的 Pod |
| `kubectl get pods -o wide` | 显示更多信息（IP、节点等） |
| `kubectl get pods -o yaml` | YAML 格式输出 |
| `kubectl get pods -o json` | JSON 格式输出 |
| `kubectl get pods --show-labels` | 显示标签 |
| `kubectl get pods -l app=nginx` | 按标签过滤 |
| `kubectl get pods --field-selector status.phase=Running` | 按字段过滤 |
| `kubectl get pods --sort-by='.status.containerStatuses[0].restartCount'` | 按重启次数排序 |
| `kubectl get pods -w` | 实时监听 Pod 变化 |

### 创建与删除

| 命令 | 功能 |
|------|------|
| `kubectl run <name> --image=<image>` | 快速创建 Pod |
| `kubectl run <name> --image=<image> --dry-run=client -o yaml` | 生成 YAML（不实际创建） |
| `kubectl apply -f <file.yaml>` | 声明式创建/更新资源 |
| `kubectl create -f <file.yaml>` | 命令式创建资源 |
| `kubectl delete pod <name>` | 删除 Pod |
| `kubectl delete pod <name> --force --grace-period=0` | 强制删除 Pod |
| `kubectl delete pods --all` | 删除当前命名空间所有 Pod |
| `kubectl delete -f <file.yaml>` | 删除 YAML 中定义的资源 |

### 进入 Pod

| 命令 | 功能 |
|------|------|
| `kubectl exec -it <pod> -- /bin/bash` | 进入 Pod 的 bash |
| `kubectl exec -it <pod> -- /bin/sh` | 进入 Pod 的 sh |
| `kubectl exec -it <pod> -c <container> -- /bin/bash` | 进入多容器 Pod 的指定容器 |
| `kubectl exec <pod> -- <command>` | 在 Pod 中执行命令 |

### 文件操作

| 命令 | 功能 |
|------|------|
| `kubectl cp <pod>:<path> <local-path>` | 从 Pod 复制文件到本地 |
| `kubectl cp <local-path> <pod>:<path>` | 从本地复制文件到 Pod |
| `kubectl cp <pod>:<path> <local-path> -c <container>` | 指定容器复制 |

### 实际示例

```bash
# 快速启动一个调试用的 Pod
kubectl run debug --image=busybox --restart=Never -- sleep 3600

# 生成 Deployment YAML 模板（不实际创建）
kubectl create deployment nginx --image=nginx --dry-run=client -o yaml > nginx-deploy.yaml

# 进入 Pod 排查问题
kubectl exec -it my-app-pod-abc123 -- /bin/sh

# 在 Pod 中执行命令查看环境变量
kubectl exec my-app-pod -- env | grep DB

# 从 Pod 中拷贝日志文件到本地
kubectl cp my-app-pod:/var/log/app.log ./app.log

# 强制删除卡在 Terminating 状态的 Pod
kubectl delete pod stuck-pod --force --grace-period=0

# 查看 Pod 中容器的资源使用
kubectl top pod my-app-pod --containers
```

---

## Deployment 管理

| 命令 | 功能 |
|------|------|
| `kubectl get deployments` | 列出 Deployment |
| `kubectl get deploy` | 同上（简写） |
| `kubectl create deployment <name> --image=<image>` | 创建 Deployment |
| `kubectl create deployment <name> --image=<image> --replicas=3` | 创建并指定副本数 |
| `kubectl delete deployment <name>` | 删除 Deployment |
| `kubectl edit deployment <name>` | 编辑 Deployment |
| `kubectl patch deployment <name> -p '<json>'` | 补丁更新 |
| `kubectl set image deployment/<name> <container>=<image>` | 更新镜像 |
| `kubectl rollout status deployment/<name>` | 查看滚动更新状态 |
| `kubectl rollout history deployment/<name>` | 查看更新历史 |
| `kubectl rollout undo deployment/<name>` | 回滚到上一版本 |
| `kubectl rollout undo deployment/<name> --to-revision=<n>` | 回滚到指定版本 |
| `kubectl rollout restart deployment/<name>` | 重启 Deployment（触发滚动更新） |
| `kubectl rollout pause deployment/<name>` | 暂停滚动更新 |
| `kubectl rollout resume deployment/<name>` | 恢复滚动更新 |

### 实际示例

```bash
# 创建一个 3 副本的 nginx Deployment
kubectl create deployment nginx --image=nginx:1.24 --replicas=3

# 更新镜像版本（触发滚动更新）
kubectl set image deployment/nginx nginx=nginx:1.25

# 查看滚动更新进度
kubectl rollout status deployment/nginx

# 发现新版本有问题，立即回滚
kubectl rollout undo deployment/nginx

# 查看历史版本
kubectl rollout history deployment/nginx

# 回滚到第 2 个版本
kubectl rollout undo deployment/nginx --to-revision=2

# 重启所有 Pod（不改配置，常用于刷新配置）
kubectl rollout restart deployment/nginx

# 使用 patch 修改副本数
kubectl patch deployment nginx -p '{"spec":{"replicas":5}}'
```

---

## Service 管理

| 命令 | 功能 |
|------|------|
| `kubectl get services` | 列出 Service |
| `kubectl get svc` | 同上（简写） |
| `kubectl expose deployment <name> --port=80 --target-port=8080` | 创建 ClusterIP Service |
| `kubectl expose deployment <name> --type=NodePort --port=80` | 创建 NodePort Service |
| `kubectl expose deployment <name> --type=LoadBalancer --port=80` | 创建 LoadBalancer Service |
| `kubectl delete svc <name>` | 删除 Service |
| `kubectl get endpoints` | 查看 Service 端点 |
| `kubectl get ep` | 同上（简写） |

### 实际示例

```bash
# 为 Deployment 创建 ClusterIP Service
kubectl expose deployment nginx --port=80 --target-port=80

# 创建 NodePort 类型的 Service（外部可访问）
kubectl expose deployment nginx --type=NodePort --port=80 --name=nginx-nodeport

# 查看 Service 对应的后端 Pod IP
kubectl get endpoints nginx

# 在集群内部测试 Service 连通性
kubectl run curl --image=curlimages/curl --rm -it --restart=Never -- curl http://nginx.default.svc.cluster.local

# 端口转发到本地（调试用）
kubectl port-forward svc/nginx 8080:80
```

---

## ConfigMap 与 Secret

### ConfigMap

| 命令 | 功能 |
|------|------|
| `kubectl get configmaps` | 列出 ConfigMap |
| `kubectl get cm` | 同上（简写） |
| `kubectl create configmap <name> --from-literal=key=value` | 从字面值创建 |
| `kubectl create configmap <name> --from-file=<path>` | 从文件创建 |
| `kubectl create configmap <name> --from-env-file=<path>` | 从 env 文件创建 |
| `kubectl describe configmap <name>` | 查看 ConfigMap 详情 |
| `kubectl delete configmap <name>` | 删除 ConfigMap |
| `kubectl get configmap <name> -o yaml` | 导出 YAML |

### Secret

| 命令 | 功能 |
|------|------|
| `kubectl get secrets` | 列出 Secret |
| `kubectl create secret generic <name> --from-literal=key=value` | 从字面值创建 |
| `kubectl create secret generic <name> --from-file=<path>` | 从文件创建 |
| `kubectl create secret docker-registry <name> --docker-server=<url> --docker-username=<user> --docker-password=<pass>` | 创建镜像拉取凭证 |
| `kubectl create secret tls <name> --cert=<cert> --key=<key>` | 创建 TLS Secret |
| `kubectl get secret <name> -o jsonpath='{.data.key}' \| base64 -d` | 解码 Secret 值 |
| `kubectl delete secret <name>` | 删除 Secret |

### 实际示例

```bash
# 从多个键值对创建 ConfigMap
kubectl create configmap app-config \
  --from-literal=DB_HOST=mysql.default.svc \
  --from-literal=DB_PORT=3306 \
  --from-literal=LOG_LEVEL=info

# 从配置文件创建 ConfigMap
kubectl create configmap nginx-conf --from-file=nginx.conf

# 创建数据库密码 Secret
kubectl create secret generic db-secret \
  --from-literal=username=admin \
  --from-literal=password=s3cr3t

# 查看 Secret 中的密码（base64 解码）
kubectl get secret db-secret -o jsonpath='{.data.password}' | base64 -d

# 创建镜像仓库拉取凭证
kubectl create secret docker-registry registry-cred \
  --docker-server=registry.example.com \
  --docker-username=user \
  --docker-password=pass \
  --docker-email=user@example.com
```

---

## 日志与调试

### 日志

| 命令 | 功能 |
|------|------|
| `kubectl logs <pod>` | 查看 Pod 日志 |
| `kubectl logs <pod> -f` | 实时跟踪日志 |
| `kubectl logs <pod> --tail=100` | 查看最后 100 行 |
| `kubectl logs <pod> --since=1h` | 查看最近 1 小时日志 |
| `kubectl logs <pod> --since=5m` | 查看最近 5 分钟日志 |
| `kubectl logs <pod> -c <container>` | 查看指定容器日志 |
| `kubectl logs <pod> --previous` | 查看上一个容器实例的日志（崩溃排查） |
| `kubectl logs <pod> --all-containers` | 查看所有容器日志 |
| `kubectl logs -l app=nginx` | 按标签查看多个 Pod 日志 |
| `kubectl logs -l app=nginx --max-log-requests=10` | 增加并发日志请求数 |
| `kubectl logs deployment/<name>` | 查看 Deployment 的日志 |

### 调试

| 命令 | 功能 |
|------|------|
| `kubectl describe pod <name>` | 查看 Pod 详情（含事件） |
| `kubectl get events` | 查看集群事件 |
| `kubectl get events --sort-by='.lastTimestamp'` | 按时间排序事件 |
| `kubectl get events --field-selector reason=Failed` | 过滤失败事件 |
| `kubectl debug <pod> -it --image=busybox` | 创建临时调试容器（K8s 1.18+） |
| `kubectl debug <pod> --copy-to=debug-pod -it --image=ubuntu` | 复制 Pod 并附加调试容器 |
| `kubectl port-forward <pod> <local-port>:<pod-port>` | 端口转发 |
| `kubectl port-forward svc/<svc> <local-port>:<svc-port>` | Service 端口转发 |
| `kubectl proxy` | 启动 API 代理 |

### 实际示例

```bash
# 实时查看 Pod 日志（类似 tail -f）
kubectl logs my-app-pod -f --tail=50

# Pod 崩溃了，查看上一次运行的日志
kubectl logs my-app-pod --previous

# 查看 Pod 为什么没启动成功（看 Events 部分）
kubectl describe pod my-app-pod

# 查看最近 5 分钟的集群事件
kubectl get events --sort-by='.lastTimestamp' | tail -20

# 端口转发到本地调试
kubectl port-forward pod/my-app-pod 8080:8080

# 使用临时调试容器排查网络问题
kubectl debug my-app-pod -it --image=nicolaka/netshoot

# 查看多个 Pod 的日志（按标签）
kubectl logs -l app=my-app --tail=50 --all-containers
```

---

## 资源查看与描述

| 命令 | 功能 |
|------|------|
| `kubectl get all` | 查看当前命名空间所有资源 |
| `kubectl get <resource>` | 列出指定类型资源 |
| `kubectl get <resource> <name> -o yaml` | 以 YAML 格式查看 |
| `kubectl get <resource> <name> -o json` | 以 JSON 格式查看 |
| `kubectl get <resource> -o custom-columns=NAME:.metadata.name,STATUS:.status.phase` | 自定义列输出 |
| `kubectl get <resource> -o jsonpath='{.items[*].metadata.name}'` | JSONPath 提取 |
| `kubectl describe <resource> <name>` | 查看资源详情 |
| `kubectl explain <resource>` | 查看资源字段说明 |
| `kubectl explain <resource>.spec` | 查看 spec 字段说明 |
| `kubectl explain <resource> --recursive` | 递归显示所有字段 |

### 实际示例

```bash
# 查看所有资源类型的简写
kubectl api-resources --verbs=list --namespaced -o name

# 用 JSONPath 提取所有 Pod 的 IP
kubectl get pods -o jsonpath='{.items[*].status.podIP}'

# 用自定义列查看 Pod 状态
kubectl get pods -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName,IP:.status.podIP

# 查看某个资源的 YAML 定义（学习资源结构）
kubectl explain deployment.spec.strategy --recursive

# 导出现有资源的 YAML（去掉集群特定信息）
kubectl get deployment nginx -o yaml | kubectl neat
```

---

## 标签与注解

### 标签（Labels）

| 命令 | 功能 |
|------|------|
| `kubectl label pod <name> key=value` | 添加标签 |
| `kubectl label pod <name> key=value --overwrite` | 修改标签 |
| `kubectl label pod <name> key-` | 删除标签 |
| `kubectl get pods -l key=value` | 按标签过滤 |
| `kubectl get pods -l 'key in (v1,v2)'` | 集合选择器 |
| `kubectl get pods -l key!=value` | 不等于选择器 |
| `kubectl get pods --show-labels` | 显示所有标签 |

### 注解（Annotations）

| 命令 | 功能 |
|------|------|
| `kubectl annotate pod <name> key=value` | 添加注解 |
| `kubectl annotate pod <name> key-` | 删除注解 |

### 实际示例

```bash
# 给 Pod 打标签
kubectl label pod my-app-pod env=production tier=frontend

# 按多个标签过滤
kubectl get pods -l 'app=nginx,env=production'

# 批量给所有 Pod 打标签
kubectl label pods --all env=dev

# 查看带特定标签的所有资源
kubectl get all -l app=my-app
```

---

## 滚动更新与回滚

| 命令 | 功能 |
|------|------|
| `kubectl set image deployment/<name> <container>=<image>` | 更新镜像 |
| `kubectl set env deployment/<name> KEY=VALUE` | 设置环境变量 |
| `kubectl set resources deployment/<name> -c <container> --limits=cpu=200m,memory=512Mi` | 设置资源限制 |
| `kubectl rollout status deployment/<name>` | 查看更新状态 |
| `kubectl rollout history deployment/<name>` | 查看更新历史 |
| `kubectl rollout history deployment/<name> --revision=<n>` | 查看某次更新详情 |
| `kubectl rollout undo deployment/<name>` | 回滚到上一版本 |
| `kubectl rollout undo deployment/<name> --to-revision=<n>` | 回滚到指定版本 |
| `kubectl rollout restart deployment/<name>` | 重启（触发滚动更新） |
| `kubectl rollout pause deployment/<name>` | 暂停更新 |
| `kubectl rollout resume deployment/<name>` | 恢复更新 |

### 实际示例

```bash
# 金丝雀发布：先暂停，观察一部分 Pod 更新后的状态
kubectl set image deployment/my-app app=my-app:v2
kubectl rollout pause deployment/my-app
# 观察新版本 Pod 是否正常...
kubectl rollout resume deployment/my-app

# 记录更新原因（方便回滚时查看）
kubectl set image deployment/my-app app=my-app:v2 --record

# 查看第 3 次更新的详情
kubectl rollout history deployment/my-app --revision=3
```

---

## 扩缩容

| 命令 | 功能 |
|------|------|
| `kubectl scale deployment <name> --replicas=<n>` | 手动扩缩容 |
| `kubectl scale statefulset <name> --replicas=<n>` | StatefulSet 扩缩容 |
| `kubectl autoscale deployment <name> --min=2 --max=10 --cpu-percent=80` | 创建 HPA |
| `kubectl get hpa` | 查看 HPA |
| `kubectl delete hpa <name>` | 删除 HPA |

### 实际示例

```bash
# 扩容到 5 个副本
kubectl scale deployment nginx --replicas=5

# 缩容到 1 个副本（节省资源）
kubectl scale deployment nginx --replicas=1

# 设置自动扩缩容（CPU 使用率超过 80% 时扩容）
kubectl autoscale deployment nginx --min=2 --max=10 --cpu-percent=80

# 查看 HPA 状态
kubectl get hpa nginx

# 批量扩容多个 Deployment
kubectl scale deployment nginx redis mysql --replicas=3
```

---

## Job 与 CronJob

### Job

| 命令 | 功能 |
|------|------|
| `kubectl get jobs` | 列出 Job |
| `kubectl create job <name> --image=<image> -- <command>` | 创建 Job |
| `kubectl delete job <name>` | 删除 Job |
| `kubectl logs job/<name>` | 查看 Job 日志 |

### CronJob

| 命令 | 功能 |
|------|------|
| `kubectl get cronjobs` | 列出 CronJob |
| `kubectl get cj` | 同上（简写） |
| `kubectl create cronjob <name> --image=<image> --schedule="*/5 * * * *" -- <command>` | 创建 CronJob |
| `kubectl delete cronjob <name>` | 删除 CronJob |
| `kubectl create job <name> --from=cronjob/<cj-name>` | 手动触发 CronJob |

### 实际示例

```bash
# 创建一次性任务
kubectl create job db-backup --image=mysql:8 -- mysqldump -h mysql -u root mydb

# 创建定时任务（每天凌晨 2 点执行）
kubectl create cronjob daily-backup --image=mysql:8 --schedule="0 2 * * *" -- mysqldump -h mysql -u root mydb

# 手动触发一次 CronJob（不等定时）
kubectl create job manual-backup --from=cronjob/daily-backup

# 查看 Job 执行结果
kubectl logs job/db-backup
```

---

## 持久化存储

### PersistentVolume (PV) 与 PersistentVolumeClaim (PVC)

| 命令 | 功能 |
|------|------|
| `kubectl get pv` | 列出 PV |
| `kubectl get pvc` | 列出 PVC |
| `kubectl describe pv <name>` | 查看 PV 详情 |
| `kubectl describe pvc <name>` | 查看 PVC 详情 |
| `kubectl delete pvc <name>` | 删除 PVC |
| `kubectl get storageclass` | 列出存储类 |
| `kubectl get sc` | 同上（简写） |

### 实际示例

```bash
# 查看 PVC 绑定状态
kubectl get pvc -o wide

# 查看哪些 PV 是 Available 状态
kubectl get pv --field-selector status.phase=Available

# 查看存储类
kubectl get storageclass

# 扩容 PVC（需要存储类支持）
kubectl patch pvc my-pvc -p '{"spec":{"resources":{"requests":{"storage":"20Gi"}}}}'
```

---

## 网络与 Ingress

### Ingress

| 命令 | 功能 |
|------|------|
| `kubectl get ingress` | 列出 Ingress |
| `kubectl get ing` | 同上（简写） |
| `kubectl describe ingress <name>` | 查看 Ingress 详情 |
| `kubectl delete ingress <name>` | 删除 Ingress |

### 网络策略

| 命令 | 功能 |
|------|------|
| `kubectl get networkpolicies` | 列出网络策略 |
| `kubectl get netpol` | 同上（简写） |
| `kubectl describe netpol <name>` | 查看网络策略详情 |

### 网络调试

| 命令 | 功能 |
|------|------|
| `kubectl port-forward <pod> <local>:<remote>` | 端口转发 |
| `kubectl port-forward svc/<svc> <local>:<remote>` | Service 端口转发 |
| `kubectl run curl --image=curlimages/curl --rm -it --restart=Never -- <cmd>` | 临时 Pod 测试网络 |

### 实际示例

```bash
# 查看 Ingress 规则和后端
kubectl describe ingress my-ingress

# 端口转发调试服务
kubectl port-forward svc/my-service 8080:80

# 在集群内部测试 DNS 解析
kubectl run dns-test --image=busybox --rm -it --restart=Never -- nslookup my-service.default.svc.cluster.local

# 在集群内部测试 HTTP 连通性
kubectl run curl-test --image=curlimages/curl --rm -it --restart=Never -- curl -s http://my-service:8080/health
```

---

## 节点管理

| 命令 | 功能 |
|------|------|
| `kubectl get nodes` | 列出所有节点 |
| `kubectl get nodes -o wide` | 显示节点详细信息 |
| `kubectl describe node <name>` | 查看节点详情 |
| `kubectl top node` | 查看节点资源使用 |
| `kubectl cordon <node>` | 标记节点不可调度 |
| `kubectl uncordon <node>` | 恢复节点可调度 |
| `kubectl drain <node>` | 驱逐节点上的 Pod |
| `kubectl drain <node> --ignore-daemonsets --delete-emptydir-data` | 安全驱逐（忽略 DaemonSet） |
| `kubectl taint nodes <node> key=value:NoSchedule` | 添加污点 |
| `kubectl taint nodes <node> key:NoSchedule-` | 移除污点 |

### 实际示例

```bash
# 节点维护前：标记不可调度 + 驱逐 Pod
kubectl cordon node-1
kubectl drain node-1 --ignore-daemonsets --delete-emptydir-data

# 维护完成后恢复
kubectl uncordon node-1

# 给节点添加污点（只允许特定 Pod 调度）
kubectl taint nodes gpu-node gpu=true:NoSchedule

# 查看节点的资源分配情况
kubectl describe node node-1 | grep -A 5 "Allocated resources"

# 查看节点上运行的 Pod
kubectl get pods --all-namespaces --field-selector spec.nodeName=node-1
```

---

## RBAC 权限

| 命令 | 功能 |
|------|------|
| `kubectl get roles` | 列出 Role |
| `kubectl get rolebindings` | 列出 RoleBinding |
| `kubectl get clusterroles` | 列出 ClusterRole |
| `kubectl get clusterrolebindings` | 列出 ClusterRoleBinding |
| `kubectl create role <name> --verb=get,list --resource=pods` | 创建 Role |
| `kubectl create rolebinding <name> --role=<role> --user=<user>` | 创建 RoleBinding |
| `kubectl create clusterrole <name> --verb=get,list --resource=pods` | 创建 ClusterRole |
| `kubectl create clusterrolebinding <name> --clusterrole=<role> --user=<user>` | 创建 ClusterRoleBinding |
| `kubectl auth can-i <verb> <resource>` | 检查当前用户权限 |
| `kubectl auth can-i <verb> <resource> --as=<user>` | 检查指定用户权限 |
| `kubectl create serviceaccount <name>` | 创建 ServiceAccount |

### 实际示例

```bash
# 检查自己是否有权限创建 Deployment
kubectl auth can-i create deployments

# 检查某个 ServiceAccount 的权限
kubectl auth can-i list pods --as=system:serviceaccount:default:my-sa

# 创建只读 Role
kubectl create role pod-reader --verb=get,list,watch --resource=pods

# 绑定 Role 到 ServiceAccount
kubectl create rolebinding pod-reader-binding --role=pod-reader --serviceaccount=default:my-sa
```

---

## 资源配额与限制

| 命令 | 功能 |
|------|------|
| `kubectl get resourcequotas` | 列出资源配额 |
| `kubectl get quota` | 同上（简写） |
| `kubectl describe quota <name>` | 查看配额详情 |
| `kubectl get limitranges` | 列出限制范围 |
| `kubectl describe limitrange <name>` | 查看限制范围详情 |

### 实际示例

```bash
# 查看命名空间的资源配额使用情况
kubectl describe quota -n production

# 查看 Pod 的资源请求和限制
kubectl get pods -o custom-columns=NAME:.metadata.name,REQ_CPU:.spec.containers[0].resources.requests.cpu,REQ_MEM:.spec.containers[0].resources.requests.memory,LIM_CPU:.spec.containers[0].resources.limits.cpu,LIM_MEM:.spec.containers[0].resources.limits.memory
```

---

## Helm 包管理

### 仓库管理

| 命令 | 功能 |
|------|------|
| `helm repo add <name> <url>` | 添加仓库 |
| `helm repo update` | 更新仓库索引 |
| `helm repo list` | 列出仓库 |
| `helm repo remove <name>` | 移除仓库 |
| `helm search repo <keyword>` | 搜索 Chart |
| `helm search hub <keyword>` | 在 Artifact Hub 搜索 |

### 安装与管理

| 命令 | 功能 |
|------|------|
| `helm install <release> <chart>` | 安装 Chart |
| `helm install <release> <chart> -f values.yaml` | 使用自定义 values 安装 |
| `helm install <release> <chart> --set key=value` | 设置参数安装 |
| `helm install <release> <chart> --namespace <ns> --create-namespace` | 指定命名空间安装 |
| `helm upgrade <release> <chart>` | 升级 Release |
| `helm upgrade --install <release> <chart>` | 安装或升级 |
| `helm uninstall <release>` | 卸载 Release |
| `helm list` | 列出已安装的 Release |
| `helm list -A` | 列出所有命名空间的 Release |
| `helm status <release>` | 查看 Release 状态 |
| `helm history <release>` | 查看 Release 历史 |
| `helm rollback <release> <revision>` | 回滚到指定版本 |

### Chart 开发

| 命令 | 功能 |
|------|------|
| `helm create <name>` | 创建 Chart 脚手架 |
| `helm template <release> <chart>` | 本地渲染模板 |
| `helm template <release> <chart> -f values.yaml` | 使用自定义 values 渲染 |
| `helm lint <chart>` | 检查 Chart 语法 |
| `helm package <chart>` | 打包 Chart |
| `helm show values <chart>` | 查看 Chart 默认 values |
| `helm get values <release>` | 查看 Release 的 values |
| `helm get manifest <release>` | 查看 Release 的清单 |
| `helm diff upgrade <release> <chart>` | 对比升级差异（需插件） |

### 实际示例

```bash
# 添加常用仓库
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# 安装 Redis（使用自定义配置）
helm install my-redis bitnami/redis \
  --set auth.password=mypassword \
  --set replica.replicaCount=3 \
  --namespace redis --create-namespace

# 升级 Release
helm upgrade my-redis bitnami/redis --set replica.replicaCount=5

# 查看渲染后的 YAML（调试用）
helm template my-redis bitnami/redis -f values.yaml

# 回滚到上一个版本
helm rollback my-redis 1

# 卸载并清理
helm uninstall my-redis -n redis
```

---

## 常用技巧

### 快速生成 YAML 模板

```bash
# 生成 Pod YAML
kubectl run nginx --image=nginx --dry-run=client -o yaml > pod.yaml

# 生成 Deployment YAML
kubectl create deployment nginx --image=nginx --replicas=3 --dry-run=client -o yaml > deploy.yaml

# 生成 Service YAML
kubectl expose deployment nginx --port=80 --dry-run=client -o yaml > svc.yaml

# 生成 Job YAML
kubectl create job test --image=busybox --dry-run=client -o yaml -- echo hello > job.yaml

# 生成 CronJob YAML
kubectl create cronjob test --image=busybox --schedule="*/5 * * * *" --dry-run=client -o yaml -- echo hello > cj.yaml
```

### 批量操作

```bash
# 删除所有 Evicted 状态的 Pod
kubectl get pods --all-namespaces --field-selector status.phase=Failed -o json | \
  kubectl delete -f -

# 删除所有 Completed 的 Pod
kubectl delete pods --field-selector status.phase=Succeeded

# 重启某个命名空间下所有 Deployment
kubectl rollout restart deployment -n my-namespace

# 查看所有非 Running 状态的 Pod
kubectl get pods -A --field-selector status.phase!=Running
```

### 资源监控

```bash
# 查看 Pod 资源使用排行
kubectl top pods --sort-by=cpu
kubectl top pods --sort-by=memory

# 查看节点资源使用
kubectl top nodes

# 查看特定 Pod 各容器的资源使用
kubectl top pod my-pod --containers
```

### 常用别名推荐

在 `~/.zshrc` 或 `~/.bashrc` 中添加：

```bash
# kubectl 别名
alias k='kubectl'
alias kg='kubectl get'
alias kd='kubectl describe'
alias kl='kubectl logs'
alias klf='kubectl logs -f'
alias ke='kubectl exec -it'
alias ka='kubectl apply -f'
alias kdel='kubectl delete'
alias kgp='kubectl get pods'
alias kgd='kubectl get deployments'
alias kgs='kubectl get services'
alias kgn='kubectl get nodes'
alias kga='kubectl get all'
alias kgpa='kubectl get pods -A'
alias kctx='kubectl config use-context'
alias kns='kubectl config set-context --current --namespace'

# 快速切换命名空间
alias kn='kubectl config set-context --current --namespace'

# 查看 Pod 日志（带时间戳）
alias klt='kubectl logs --timestamps'
```

### kubectl 插件推荐

| 插件 | 功能 |
|------|------|
| `kubectx` | 快速切换集群上下文 |
| `kubens` | 快速切换命名空间 |
| `k9s` | 终端 UI 管理工具 |
| `kubectl-neat` | 清理 YAML 输出中的冗余字段 |
| `kubectl-tree` | 以树形结构显示资源关系 |
| `stern` | 多 Pod 日志聚合查看 |
| `kube-ps1` | 在终端提示符显示当前集群和命名空间 |

---

## 常用工作流

### 应用部署流程

```bash
# 1. 创建命名空间
kubectl create namespace my-app

# 2. 创建配置和密钥
kubectl create configmap app-config --from-file=config.yaml -n my-app
kubectl create secret generic app-secret --from-literal=DB_PASS=xxx -n my-app

# 3. 部署应用
kubectl apply -f deployment.yaml -n my-app

# 4. 暴露服务
kubectl apply -f service.yaml -n my-app

# 5. 配置 Ingress
kubectl apply -f ingress.yaml -n my-app

# 6. 验证部署
kubectl get all -n my-app
kubectl rollout status deployment/my-app -n my-app
```

### 故障排查流程

```bash
# 1. 查看 Pod 状态
kubectl get pods -n my-app

# 2. 查看 Pod 事件（为什么没启动）
kubectl describe pod <pod-name> -n my-app

# 3. 查看日志
kubectl logs <pod-name> -n my-app --previous  # 如果 Pod 崩溃重启

# 4. 进入 Pod 排查
kubectl exec -it <pod-name> -n my-app -- /bin/sh

# 5. 检查 Service 端点
kubectl get endpoints <svc-name> -n my-app

# 6. 测试网络连通性
kubectl run curl --image=curlimages/curl --rm -it --restart=Never -n my-app -- curl http://<svc-name>:8080/health

# 7. 查看集群事件
kubectl get events -n my-app --sort-by='.lastTimestamp'
```

### 版本更新流程

```bash
# 1. 更新镜像
kubectl set image deployment/my-app app=my-app:v2 -n my-app

# 2. 监控更新进度
kubectl rollout status deployment/my-app -n my-app

# 3. 验证新版本
kubectl get pods -n my-app
kubectl logs -l app=my-app -n my-app --tail=10

# 4. 如果有问题，回滚
kubectl rollout undo deployment/my-app -n my-app
```
