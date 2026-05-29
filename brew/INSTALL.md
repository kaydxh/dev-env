# Homebrew 软件包管理

## 环境要求

- macOS（支持 Intel 和 Apple Silicon）
- 网络连接

## 快速安装

```bash
git clone https://github.com/kaydxh/dev-env.git
cd dev-env/brew
chmod +x install.sh
./install.sh
```

## 安装选项

| 参数 | 说明 |
|------|------|
| `--skip-cask` | 跳过 GUI 应用（Cask）安装 |
| `--skip-go` | 跳过 Go 工具安装 |
| `--skip-npm` | 跳过 npm 全局包安装 |
| `--minimal` | 只安装核心开发工具 |
| `--help` | 显示帮助信息 |

### 示例

```bash
# 完整安装（所有 brew + cask + go + npm）
./install.sh

# 只安装 CLI 工具，跳过 GUI 应用
./install.sh --skip-cask

# 最小化安装（vim、git、ctags 等核心工具）
./install.sh --minimal

# 跳过 Go 和 npm 工具
./install.sh --skip-go --skip-npm
```

## 安装内容

### CLI 工具（brew）

| 包名 | 用途 |
|------|------|
| ack | 代码搜索 |
| asitop | Apple Silicon 性能监控 |
| clang-format | C/C++ 代码格式化 |
| cmake | 构建工具 |
| cocoapods | iOS 依赖管理 |
| colima | macOS 容器运行时 |
| coreutils | GNU 核心工具 |
| curl | HTTP 客户端 |
| docker | 容器引擎 |
| docker-compose | 容器编排 |
| ffmpeg | 音视频处理 |
| findutils | GNU 查找工具 |
| fswatch | 文件变更监控 |
| git | 版本控制 |
| git-lfs | Git 大文件存储 |
| gnu-sed | GNU sed |
| graphviz | 图形可视化 |
| grpcurl | gRPC 调试工具 |
| node | Node.js |
| openjdk@17 | Java 17 |
| portaudio | 音频 I/O 库 |
| protobuf | Protocol Buffers |
| pyenv | Python 版本管理 |
| python@3.13 | Python 3.13 |
| rename | 批量重命名 |
| telnet | 网络调试 |
| universal-ctags | 代码标签生成 |
| vim | 编辑器 |
| wget | 下载工具 |

### GUI 应用（Cask）

| 包名 | 用途 |
|------|------|
| anaconda | Python 数据科学环境 |
| android-platform-tools | Android 调试工具 |
| chromedriver | Chrome 自动化驱动 |
| flutter | Flutter SDK |
| rar | 解压工具 |

### Go 工具

| 工具 | 用途 |
|------|------|
| gopls | Go 语言服务器 |
| dlv | Go 调试器 |
| golangci-lint | Go 代码检查 |
| protoc-gen-go | protobuf Go 代码生成 |
| protoc-gen-go-grpc | gRPC Go 代码生成 |
| gomodifytags | struct tag 管理 |
| impl | 接口实现生成 |
| golines | 代码自动换行 |
| staticcheck | 静态分析 |

### npm 全局包

| 包名 | 用途 |
|------|------|
| commitizen | 规范化 git commit |
| cz-conventional-changelog | Conventional Commits 适配器 |

## 日常维护

### 更新 Brewfile

当安装了新软件后，更新 Brewfile：

```bash
brew bundle dump --file=Brewfile --force
```

### 更新所有软件包

```bash
brew upgrade
```

### 清理旧版本

```bash
brew cleanup
```

### 检查软件包健康状态

```bash
brew doctor
```

## 目录结构

```
brew/
├── Brewfile       # 软件包清单
├── install.sh     # 一键安装脚本
└── INSTALL.md     # 本文档
```

## 注意事项

1. **Brewfile 中不包含 Go 和 npm 包**：这些由安装脚本单独管理，因为它们依赖各自的包管理器
2. **Cask 应用可能需要密码**：部分 GUI 应用安装时需要输入系统密码
3. **镜像加速**：国内网络建议配置 Homebrew 镜像源（脚本会提示）
4. **定期更新 Brewfile**：安装新软件后记得重新 dump
