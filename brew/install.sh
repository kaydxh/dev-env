#!/usr/bin/env bash
#
# Homebrew 一键安装脚本
# 用于在新 Mac 上快速恢复 Homebrew 及其软件包
#
# 使用方法:
#   chmod +x install.sh
#   ./install.sh
#
# 可选参数:
#   --skip-cask    跳过 GUI 应用安装
#   --skip-go      跳过 Go 工具安装
#   --skip-npm     跳过 npm 全局包安装
#   --minimal      只安装核心开发工具
#

set -e

# ===== 颜色输出 =====
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# ===== 参数解析 =====
SKIP_CASK=false
SKIP_GO=false
SKIP_NPM=false
MINIMAL=false

for arg in "$@"; do
  case $arg in
    --skip-cask) SKIP_CASK=true ;;
    --skip-go)   SKIP_GO=true ;;
    --skip-npm)  SKIP_NPM=true ;;
    --minimal)   MINIMAL=true ;;
    --help|-h)
      echo "用法: ./install.sh [选项]"
      echo ""
      echo "选项:"
      echo "  --skip-cask    跳过 GUI 应用（Cask）安装"
      echo "  --skip-go      跳过 Go 工具安装"
      echo "  --skip-npm     跳过 npm 全局包安装"
      echo "  --minimal      只安装核心开发工具（vim、git、fzf、ripgrep 等）"
      echo "  --help, -h     显示帮助信息"
      exit 0
      ;;
  esac
done

# ===== 获取脚本所在目录 =====
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info "开始安装 Homebrew 及软件包..."
info "脚本目录: $SCRIPT_DIR"

# ===== 1. 安装 Homebrew =====
info "检查 Homebrew..."
if ! command -v brew &>/dev/null; then
  info "安装 Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Apple Silicon Mac 需要添加 PATH
  if [ -f /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  success "Homebrew 安装完成"
else
  success "Homebrew 已安装: $(brew --version | head -1)"
fi

# ===== 2. 配置 Homebrew 镜像（可选）=====
info "配置 Homebrew 镜像..."
if [ -z "$HOMEBREW_API_DOMAIN" ]; then
  warn "未检测到镜像配置，建议在 .zprofile 中添加以下配置加速下载："
  echo "  export HOMEBREW_API_DOMAIN=https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
  echo "  export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
else
  success "Homebrew 镜像已配置"
fi

# ===== 3. 使用 Brewfile 安装软件包 =====
BREWFILE="$SCRIPT_DIR/Brewfile"

if [ "$MINIMAL" = true ]; then
  info "最小化安装模式：只安装核心开发工具..."
  MINIMAL_PACKAGES=(
    vim
    git
    git-lfs
    universal-ctags
    curl
    wget
    coreutils
    findutils
    gnu-sed
    pyenv
    node
    cmake
  )
  for pkg in "${MINIMAL_PACKAGES[@]}"; do
    if brew list "$pkg" &>/dev/null; then
      success "$pkg 已安装"
    else
      info "安装 $pkg..."
      brew install "$pkg" && success "$pkg 安装完成" || warn "$pkg 安装失败"
    fi
  done
else
  if [ -f "$BREWFILE" ]; then
    info "使用 Brewfile 安装软件包..."
    if [ "$SKIP_CASK" = true ]; then
      info "跳过 Cask 应用，只安装 CLI 工具..."
      grep -v "^cask " "$BREWFILE" | brew bundle --file=- 2>/dev/null || true
    else
      brew bundle --file="$BREWFILE" 2>/dev/null || true
    fi
    success "Brewfile 中的软件包安装完成"
  else
    error "未找到 Brewfile: $BREWFILE"
  fi
fi

# ===== 4. 安装 Go 工具（可选）=====
if [ "$SKIP_GO" = false ]; then
  if command -v go &>/dev/null; then
    info "安装 Go 开发工具..."
    GO_TOOLS=(
      "golang.org/x/tools/gopls@latest"
      "github.com/go-delve/delve/cmd/dlv@latest"
      "github.com/golangci/golangci-lint/cmd/golangci-lint@latest"
      "google.golang.org/protobuf/cmd/protoc-gen-go@latest"
      "google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest"
      "github.com/fatih/gomodifytags@latest"
      "github.com/josharian/impl@latest"
      "github.com/segmentio/golines@latest"
      "honnef.co/go/tools/cmd/staticcheck@latest"
    )
    for tool in "${GO_TOOLS[@]}"; do
      tool_name=$(basename "${tool%@*}")
      info "安装 $tool_name..."
      go install "$tool" 2>/dev/null && success "$tool_name 安装完成" || warn "$tool_name 安装失败"
    done
  else
    warn "未检测到 Go 环境，跳过 Go 工具安装"
    warn "请先安装 Go: https://go.dev/dl/"
  fi
else
  warn "跳过 Go 工具安装"
fi

# ===== 5. 安装 npm 全局包（可选）=====
if [ "$SKIP_NPM" = false ]; then
  if command -v npm &>/dev/null; then
    info "安装 npm 全局包..."
    NPM_PACKAGES=(
      "commitizen"
      "cz-conventional-changelog"
    )
    for pkg in "${NPM_PACKAGES[@]}"; do
      if npm list -g "$pkg" &>/dev/null 2>&1; then
        success "$pkg 已安装"
      else
        info "安装 $pkg..."
        npm install -g "$pkg" 2>/dev/null && success "$pkg 安装完成" || warn "$pkg 安装失败"
      fi
    done
  else
    warn "未检测到 npm，跳过 npm 全局包安装"
  fi
else
  warn "跳过 npm 全局包安装"
fi

# ===== 安装完成 =====
echo ""
echo "============================================"
success "🎉 Homebrew 软件包安装完成！"
echo "============================================"
echo ""
info "已安装的软件包："
echo "  brew 包: $(brew list --formula | wc -l | tr -d ' ') 个"
echo "  cask 包: $(brew list --cask | wc -l | tr -d ' ') 个"
echo ""
info "后续建议："
echo "  1. 定期更新 Brewfile: brew bundle dump --file=$BREWFILE --force"
echo "  2. 更新所有软件包: brew upgrade"
echo "  3. 清理旧版本: brew cleanup"
echo ""
