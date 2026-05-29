# Git 配置环境安装说明

## 环境要求

- macOS（支持 Intel 和 Apple Silicon）
- Git
- 网络连接（用于安装 Git LFS）

## 快速安装

```bash
git clone https://github.com/kaydxh/dev-env.git
cd dev-env/git
chmod +x install.sh
./install.sh
```

## 安装选项

| 参数 | 说明 |
|------|------|
| `--skip-lfs` | 跳过 Git LFS 安装 |
| `--skip-hooks` | 跳过全局 hooks 部署 |
| `--help` | 显示帮助信息 |

### 示例

```bash
# 完整安装
./install.sh

# 跳过 Git LFS
./install.sh --skip-lfs

# 仅部署配置文件，不部署 hooks
./install.sh --skip-hooks
```

## 安装内容

### 安装步骤概览

| 步骤 | 内容 |
|------|------|
| 1 | 检查并安装 Git |
| 2 | 安装 Git LFS |
| 3 | 部署 `~/.gitconfig`（自动备份已有配置） |
| 4 | 部署 `~/.gitconfig-company` |
| 5 | 部署全局 Git hooks 到 `~/.git-hooks/` |
| 6 | 创建工作目录 |

### 配置文件说明

| 文件 | 部署位置 | 说明 |
|------|----------|------|
| `gitconfig` | `~/.gitconfig` | Git 主配置文件 |
| `gitconfig-company` | `~/.gitconfig-company` | 公司内部 Git 平台专用配置 |

### gitconfig 主要配置项

| 配置项 | 说明 |
|--------|------|
| `core.quotepath = false` | 正确显示中文文件名 |
| `core.hooksPath = ~/.git-hooks` | 全局 hooks 路径 |
| `i18n.commit.encoding = utf-8` | 提交信息使用 UTF-8 编码 |
| `i18n.logoutputencoding = utf-8` | 日志输出使用 UTF-8 编码 |
| `includeIf` | 根据仓库目录自动切换用户配置 |
| `filter.lfs` | Git LFS 配置 |
| `safe.directory` | 安全目录白名单 |

### includeIf 条件配置

通过 `includeIf` 实现不同目录使用不同的 Git 用户身份：

```ini
# 当仓库位于 ~/workspace/company-git/ 下时，自动加载公司配置
[includeIf "gitdir:~/workspace/company-git/"]
    path = ~/.gitconfig-company
```

这样在公司仓库中提交代码时会自动使用公司邮箱，个人仓库则使用个人邮箱。

### 全局 Hooks

| Hook 文件 | 功能 |
|-----------|------|
| `commit-msg` | 提交信息校验，支持项目级 hook 透传 |
| `pre-commit` | 提交前检查，支持项目级 hook 透传 |
| `prepare-commit-msg` | 提交信息准备，支持项目级 hook 透传 |
| `post-checkout` | Git LFS 检出后处理 |
| `post-commit` | Git LFS 提交后处理 |
| `post-merge` | Git LFS 合并后处理 |
| `pre-push` | Git LFS 推送前处理 |

> **Hook 透传机制**：`commit-msg`、`pre-commit`、`prepare-commit-msg` 三个 hook 支持项目级透传。
> 如果项目仓库内有自己的 `.git/hooks/` 脚本，全局 hook 会自动调用项目级 hook，不会覆盖。

## 安装后配置

### 1. 修改个人信息

```bash
# 设置全局用户名和邮箱
git config --global user.name "你的名字"
git config --global user.email "你的邮箱"
```

### 2. 修改公司配置

编辑 `~/.gitconfig-company`，填入公司用户名和邮箱：

```ini
[user]
    name = your-company-username
    email = your-company-username@company.com
```

### 3. 修改 includeIf 路径

将 `~/.gitconfig` 中的 `~/workspace/company-git/` 改为你的公司仓库实际存放目录：

```bash
# 编辑 ~/.gitconfig，修改 includeIf 中的路径
vim ~/.gitconfig
```

### 4. 验证配置

```bash
# 查看所有配置及来源
git config --list --show-origin

# 在个人仓库中验证
cd ~/workspace/github.com/your-repo
git config user.email
# 应显示个人邮箱

# 在公司仓库中验证
cd ~/workspace/company-git/your-repo
git config user.email
# 应显示公司邮箱
```

## 目录结构

安装完成后的文件布局：

```
~/.gitconfig              # Git 主配置文件
~/.gitconfig-company      # 公司专用配置（通过 includeIf 加载）
~/.git-hooks/             # 全局 hooks 目录
├── commit-msg            # 提交信息校验
├── pre-commit            # 提交前检查
├── prepare-commit-msg    # 提交信息准备
├── post-checkout         # LFS 检出处理
├── post-commit           # LFS 提交处理
├── post-merge            # LFS 合并处理
└── pre-push              # LFS 推送处理
~/workspace/company-git/  # 公司仓库目录（自动创建）
```

## 故障排查

### 中文文件名显示为转义字符

确认 `core.quotepath` 设置为 `false`：

```bash
git config --global core.quotepath false
```

### hooks 不生效

确认 `core.hooksPath` 指向正确路径：

```bash
git config --global core.hooksPath
# 应显示 ~/.git-hooks
```

确认 hook 文件有执行权限：

```bash
ls -la ~/.git-hooks/
# 所有文件应有 x 权限
chmod +x ~/.git-hooks/*
```

### Git LFS 报错

确认 Git LFS 已安装并初始化：

```bash
git lfs install
git lfs version
```

### includeIf 不生效

注意 `includeIf` 的路径必须以 `/` 结尾，且使用 `gitdir:` 前缀：

```ini
# 正确（路径以 / 结尾）
[includeIf "gitdir:~/workspace/company-git/"]

# 错误（缺少结尾 /）
[includeIf "gitdir:~/workspace/company-git"]
```

验证方法：

```bash
cd ~/workspace/company-git/some-repo
git config user.email
# 应显示公司邮箱
```
