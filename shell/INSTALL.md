# Shell 配置安装说明

## 环境要求

- macOS（支持 Intel 和 Apple Silicon）
- 网络连接（用于下载 oh-my-zsh）

## 快速安装

```bash
git clone https://github.com/kaydxh/dev-env.git
cd dev-env/shell
chmod +x install.sh
./install.sh
```

## 安装选项

| 参数 | 说明 |
|------|------|
| `--skip-omz` | 跳过 oh-my-zsh 安装 |
| `--help` | 显示帮助信息 |

## 安装内容

### 配置文件

| 文件 | 部署位置 | 说明 |
|------|----------|------|
| `zshrc` | `~/.zshrc` | zsh 主配置文件 |
| `zprofile` | `~/.zprofile` | zsh 登录配置（Homebrew 镜像等） |

### zshrc 包含的配置

| 配置项 | 说明 |
|--------|------|
| oh-my-zsh | 主题 robbyrussell，插件 git/z/golang/docker |
| EDITOR/VISUAL | 默认编辑器 vim |
| Go 环境 | GOROOT、GOPATH、GOBIN、GOMODCACHE |
| 语言编码 | LANG、LC_ALL = en_US.UTF-8 |
| bun | Node.js 运行时 |
| CodeBuddy | AI 编程助手 |

### zprofile 包含的配置

| 配置项 | 说明 |
|--------|------|
| Homebrew 镜像 | 清华/中科大国内镜像加速 |
| Homebrew shellenv | 初始化 Homebrew 环境变量 |
| JetBrains Toolbox | IDE 命令行工具路径 |

### oh-my-zsh 插件

| 插件 | 功能 |
|------|------|
| git | Git 命令别名和补全 |
| z | 快速跳转常用目录 |
| golang | Go 命令补全 |
| docker | Docker 命令补全 |

## 安装后配置

### 1. 修改个人信息

根据需要修改 `~/.zshrc` 中的：
- 别名（如 `alias claude="claude-internal"`）
- JAVA_HOME 路径（如果需要 Android 开发）

### 2. 确认默认 shell

```bash
# 查看当前默认 shell
echo $SHELL

# 如果不是 zsh，切换为 zsh
chsh -s $(which zsh)
```

## 目录结构

```
shell/
├── install.sh    # 一键安装脚本
├── INSTALL.md    # 本文档
├── zshrc         # zsh 主配置
└── zprofile      # zsh 登录配置
```

## 故障排查

### oh-my-zsh 安装失败

手动安装：

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### 插件不生效

确认 oh-my-zsh 已安装且插件目录存在：

```bash
ls ~/.oh-my-zsh/plugins/git
ls ~/.oh-my-zsh/plugins/z
```

### Homebrew 命令找不到

确认 `.zprofile` 中的 brew shellenv 已正确加载：

```bash
# Apple Silicon Mac
eval $(/opt/homebrew/bin/brew shellenv)

# Intel Mac
eval $(/usr/local/bin/brew shellenv)
```
