#!/usr/bin/env bash
#
# Git 配置一键安装脚本
# 用于在新 Mac 上快速恢复 git 配置和全局 hooks
#
# 使用方法:
#   chmod +x install.sh
#   ./install.sh
#
# 可选参数:
#   --skip-lfs     跳过 Git LFS 安装
#   --skip-hooks   跳过全局 hooks 部署
#

set -e

# ===== 颜色输出 =====
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# ===== 参数解析 =====
SKIP_LFS=false
SKIP_HOOKS=false

for arg in "$@"; do
  case $arg in
    --skip-lfs)   SKIP_LFS=true ;;
    --skip-hooks) SKIP_HOOKS=true ;;
    --help|-h)
      echo "用法: ./install.sh [选项]"
      echo ""
      echo "选项:"
      echo "  --skip-lfs     跳过 Git LFS 安装"
      echo "  --skip-hooks   跳过全局 hooks 部署"
      echo "  --help, -h     显示帮助信息"
      exit 0
      ;;
  esac
done

# ===== 获取脚本所在目录 =====
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info "开始安装 Git 配置..."
info "脚本目录: $SCRIPT_DIR"

# ===== 1. 检查 Git 是否已安装 =====
info "检查 Git..."
if ! command -v git &>/dev/null; then
  info "安装 Git..."
  if command -v brew &>/dev/null; then
    brew install git
    success "Git 安装完成"
  else
    error "未找到 Git 且 Homebrew 未安装，请先安装 Git 或 Homebrew"
  fi
else
  success "Git 已安装: $(git --version)"
fi

# ===== 2. 安装 Git LFS =====
if [ "$SKIP_LFS" = false ]; then
  info "检查 Git LFS..."
  if ! command -v git-lfs &>/dev/null; then
    info "安装 Git LFS..."
    if command -v brew &>/dev/null; then
      brew install git-lfs
      git lfs install
      success "Git LFS 安装完成"
    else
      warn "Homebrew 未安装，请手动安装 Git LFS: https://git-lfs.github.com"
    fi
  else
    success "Git LFS 已安装: $(git-lfs --version)"
  fi
else
  warn "跳过 Git LFS 安装"
fi

# ===== 3. 部署 gitconfig =====
info "部署 gitconfig..."
GITCONFIG_SRC="$SCRIPT_DIR/gitconfig"
GITCONFIG_DST=~/.gitconfig

if [ ! -f "$GITCONFIG_SRC" ]; then
  error "未找到 gitconfig 源文件: $GITCONFIG_SRC"
fi

if [ -f "$GITCONFIG_DST" ]; then
  BACKUP="$GITCONFIG_DST.backup.$(date +%Y%m%d%H%M%S)"
  cp "$GITCONFIG_DST" "$BACKUP"
  warn "已备份现有 .gitconfig 到 $BACKUP"
fi

cp "$GITCONFIG_SRC" "$GITCONFIG_DST"
success "gitconfig 部署完成"

# ===== 4. 部署 gitconfig-company =====
info "部署 gitconfig-company..."
GITCONFIG_COMPANY_SRC="$SCRIPT_DIR/gitconfig-company"
GITCONFIG_COMPANY_DST=~/.gitconfig-company

if [ -f "$GITCONFIG_COMPANY_SRC" ]; then
  if [ -f "$GITCONFIG_COMPANY_DST" ]; then
    BACKUP="$GITCONFIG_COMPANY_DST.backup.$(date +%Y%m%d%H%M%S)"
    cp "$GITCONFIG_COMPANY_DST" "$BACKUP"
    warn "已备份现有 .gitconfig-company 到 $BACKUP"
  fi
  cp "$GITCONFIG_COMPANY_SRC" "$GITCONFIG_COMPANY_DST"
  success "gitconfig-company 部署完成"
else
  warn "未找到 gitconfig-company 源文件，跳过"
fi

# ===== 5. 部署全局 hooks =====
if [ "$SKIP_HOOKS" = false ]; then
  info "部署全局 Git hooks..."
  HOOKS_SRC="$SCRIPT_DIR/hooks"
  HOOKS_DST=~/.git-hooks

  if [ ! -d "$HOOKS_SRC" ]; then
    warn "未找到 hooks 源目录: $HOOKS_SRC，跳过"
  else
    # 创建目标目录
    mkdir -p "$HOOKS_DST"

    # 复制所有 hook 脚本
    for hook in "$HOOKS_SRC"/*; do
      if [ -f "$hook" ]; then
        hook_name=$(basename "$hook")
        cp "$hook" "$HOOKS_DST/$hook_name"
        chmod +x "$HOOKS_DST/$hook_name"
        success "  部署 hook: $hook_name"
      fi
    done

    success "全局 hooks 部署完成"
  fi
else
  warn "跳过全局 hooks 部署"
fi

# ===== 6. 创建工作目录 =====
info "创建工作目录..."

# gitconfig 中 includeIf 引用的目录
COMPANY_DIR=~/workspace/company-git
if [ ! -d "$COMPANY_DIR" ]; then
  mkdir -p "$COMPANY_DIR"
  success "创建公司仓库目录: $COMPANY_DIR"
else
  success "公司仓库目录已存在: $COMPANY_DIR"
fi

# ===== 7. 提示修改个人信息 =====
echo ""
echo "============================================"
success "🎉 Git 配置安装完成！"
echo "============================================"
echo ""
info "请根据实际情况修改以下配置："
echo ""
echo "  1. 修改 ~/.gitconfig 中的用户信息："
echo "     git config --global user.name \"你的名字\""
echo "     git config --global user.email \"你的邮箱\""
echo ""
echo "  2. 修改 ~/.gitconfig-company 中的公司信息："
echo "     编辑 ~/.gitconfig-company，填入公司用户名和邮箱"
echo ""
echo "  3. 修改 ~/.gitconfig 中的 includeIf 路径："
echo "     将 ~/workspace/company-git/ 改为你的公司仓库实际目录"
echo ""
info "验证配置："
echo "  git config --list --show-origin"
echo ""
