#!/usr/bin/env bash
#
# Shell 配置一键安装脚本
# 用于在新 Mac 上快速恢复 zsh 环境
#
# 使用方法:
#   chmod +x install.sh
#   ./install.sh
#
# 可选参数:
#   --skip-omz     跳过 oh-my-zsh 安装
#   --help         显示帮助信息
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
SKIP_OMZ=false

for arg in "$@"; do
  case $arg in
    --skip-omz) SKIP_OMZ=true ;;
    --help|-h)
      echo "用法: ./install.sh [选项]"
      echo ""
      echo "选项:"
      echo "  --skip-omz     跳过 oh-my-zsh 安装"
      echo "  --help, -h     显示帮助信息"
      exit 0
      ;;
  esac
done

# ===== 获取脚本所在目录 =====
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info "开始安装 Shell 配置..."
info "脚本目录: $SCRIPT_DIR"

# ===== 1. 安装 oh-my-zsh =====
if [ "$SKIP_OMZ" = false ]; then
  info "检查 oh-my-zsh..."
  if [ -d "$HOME/.oh-my-zsh" ]; then
    success "oh-my-zsh 已安装"
  else
    info "安装 oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    success "oh-my-zsh 安装完成"
  fi
else
  warn "跳过 oh-my-zsh 安装"
fi

# ===== 2. 部署 zshrc =====
info "部署 .zshrc..."
ZSHRC_SRC="$SCRIPT_DIR/zshrc"
ZSHRC_DST="$HOME/.zshrc"

if [ -f "$ZSHRC_DST" ]; then
  BACKUP="$ZSHRC_DST.backup.$(date +%Y%m%d%H%M%S)"
  cp "$ZSHRC_DST" "$BACKUP"
  warn "已备份现有 .zshrc 到 $BACKUP"
fi

cp "$ZSHRC_SRC" "$ZSHRC_DST"
success ".zshrc 部署完成"

# ===== 3. 部署 zprofile =====
info "部署 .zprofile..."
ZPROFILE_SRC="$SCRIPT_DIR/zprofile"
ZPROFILE_DST="$HOME/.zprofile"

if [ -f "$ZPROFILE_DST" ]; then
  BACKUP="$ZPROFILE_DST.backup.$(date +%Y%m%d%H%M%S)"
  cp "$ZPROFILE_DST" "$BACKUP"
  warn "已备份现有 .zprofile 到 $BACKUP"
fi

cp "$ZPROFILE_SRC" "$ZPROFILE_DST"
success ".zprofile 部署完成"

# ===== 4. 确保默认 shell 是 zsh =====
info "检查默认 shell..."
if [ "$SHELL" = "/bin/zsh" ] || [ "$SHELL" = "/usr/local/bin/zsh" ] || [ "$SHELL" = "/opt/homebrew/bin/zsh" ]; then
  success "默认 shell 已是 zsh"
else
  warn "当前默认 shell 不是 zsh: $SHELL"
  info "请手动执行: chsh -s $(which zsh)"
fi

# ===== 安装完成 =====
echo ""
echo "============================================"
success "🎉 Shell 配置安装完成！"
echo "============================================"
echo ""
info "后续步骤："
echo "  1. 重新打开终端或执行 source ~/.zshrc"
echo "  2. 如需安装 Homebrew，请先执行 brew 目录下的安装脚本"
echo "  3. 根据需要修改 ~/.zshrc 中的个人配置（如别名等）"
echo ""
