#!/usr/bin/env bash
#
# vim 一键安装脚本
# 用于在新 Mac 上快速恢复 vim 开发环境
#
# 使用方法:
#   chmod +x install.sh
#   ./install.sh
#
# 可选参数:
#   --skip-brew    跳过 Homebrew 依赖安装
#   --skip-ycm     跳过 YouCompleteMe 编译（耗时较长）
#   --skip-go      跳过 Go 工具安装
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
SKIP_BREW=false
SKIP_YCM=false
SKIP_GO=false

for arg in "$@"; do
  case $arg in
    --skip-brew) SKIP_BREW=true ;;
    --skip-ycm)  SKIP_YCM=true ;;
    --skip-go)   SKIP_GO=true ;;
    --help|-h)
      echo "用法: ./install.sh [选项]"
      echo ""
      echo "选项:"
      echo "  --skip-brew    跳过 Homebrew 依赖安装"
      echo "  --skip-ycm     跳过 YouCompleteMe 编译"
      echo "  --skip-go      跳过 Go 工具安装"
      echo "  --help, -h     显示帮助信息"
      exit 0
      ;;
  esac
done

# ===== 获取脚本所在目录 =====
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info "开始安装 vim 开发环境..."
info "脚本目录: $SCRIPT_DIR"

# ===== 1. 安装 Homebrew（如果未安装）=====
if [ "$SKIP_BREW" = false ]; then
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
    success "Homebrew 已安装"
  fi

  # ===== 2. 安装 Homebrew 依赖 =====
  info "安装 Homebrew 依赖..."

  BREW_PACKAGES=(
    vim                # Vim 编辑器（带 +python3 支持）
    universal-ctags    # ctags（用于 gutentags 插件）
    ripgrep            # rg 命令（用于 fzf-ripgrep）
    fd                 # fd 命令（用于 fzf 文件搜索）
    fzf                # 模糊搜索
    ack                # 代码搜索（用于 ack.vim）
    clang-format       # C/C++ 代码格式化
    cmake              # 编译 YCM 需要
    python3            # Python3 支持
    node               # Node.js（markdown-preview 需要）
  )

  for pkg in "${BREW_PACKAGES[@]}"; do
    # 去掉注释部分，只取包名
    pkg_name=$(echo "$pkg" | awk '{print $1}')
    if brew list "$pkg_name" &>/dev/null; then
      success "$pkg_name 已安装"
    else
      info "安装 $pkg_name..."
      brew install "$pkg_name"
      success "$pkg_name 安装完成"
    fi
  done
else
  warn "跳过 Homebrew 依赖安装"
fi

# ===== 3. 创建必要目录 =====
info "创建必要目录..."
mkdir -p ~/.vim/undodir
mkdir -p ~/.vim/pack/minpac/opt
mkdir -p ~/.vim/pack/minpac/start
mkdir -p ~/.vim/my/start
mkdir -p ~/.vim/credentials
mkdir -p ~/.cache/tags
success "目录创建完成"

# ===== 4. 安装 minpac 插件管理器 =====
info "安装 minpac 插件管理器..."
MINPAC_DIR=~/.vim/pack/minpac/opt/minpac
if [ -d "$MINPAC_DIR" ]; then
  info "更新 minpac..."
  git -C "$MINPAC_DIR" pull --quiet
  success "minpac 更新完成"
else
  git clone https://github.com/k-takata/minpac.git "$MINPAC_DIR"
  success "minpac 安装完成"
fi

# ===== 5. 部署 vimrc =====
info "部署 vimrc..."
VIMRC_SRC="$SCRIPT_DIR/vimrc"
VIMRC_DST=~/.vimrc

if [ -f "$VIMRC_DST" ]; then
  # 备份已有的 vimrc
  BACKUP="$VIMRC_DST.backup.$(date +%Y%m%d%H%M%S)"
  cp "$VIMRC_DST" "$BACKUP"
  warn "已备份现有 .vimrc 到 $BACKUP"
fi

cp "$VIMRC_SRC" "$VIMRC_DST"
success "vimrc 部署完成"

# ===== 6. 安装 vim 插件（通过 minpac）=====
info "安装 vim 插件（通过 minpac）..."
vim -es -u "$VIMRC_DST" -i NONE \
  -c "packadd minpac" \
  -c "source $VIMRC_DST" \
  -c "call minpac#update('', {'do': 'quit'})" \
  2>/dev/null || true
success "vim 插件安装完成（部分插件可能需要打开 vim 后执行 :PackUpdate）"

# ===== 7. 安装 vim-go =====
info "安装 vim-go..."
VIMGO_DIR=~/.vim/pack/plugins/start/vim-go
if [ -d "$VIMGO_DIR" ]; then
  info "更新 vim-go..."
  git -C "$VIMGO_DIR" pull --quiet
  success "vim-go 更新完成"
else
  mkdir -p ~/.vim/pack/plugins/start
  git clone https://github.com/fatih/vim-go.git "$VIMGO_DIR"
  success "vim-go 安装完成"
fi

# ===== 8. 安装 YouCompleteMe =====
if [ "$SKIP_YCM" = false ]; then
  info "安装 YouCompleteMe（耗时较长）..."
  YCM_DIR=~/.vim/my/start/YouCompleteMe
  if [ -d "$YCM_DIR" ]; then
    info "更新 YouCompleteMe..."
    git -C "$YCM_DIR" pull --quiet
    git -C "$YCM_DIR" submodule update --init --recursive
  else
    mkdir -p ~/.vim/my/start
    git clone --recurse-submodules https://github.com/ycm-core/YouCompleteMe.git "$YCM_DIR"
  fi

  info "编译 YouCompleteMe（支持 C/C++、Go、Python）..."
  cd "$YCM_DIR"
  python3 install.py --clangd-completer --go-completer
  cd -
  success "YouCompleteMe 安装完成"
else
  warn "跳过 YouCompleteMe 安装"
fi

# ===== 9. 安装 Go 工具 =====
if [ "$SKIP_GO" = false ]; then
  if command -v go &>/dev/null; then
    info "安装 Go 开发工具..."

    GO_TOOLS=(
      "golang.org/x/tools/gopls@latest"
      "github.com/segmentio/golines@latest"
    )

    for tool in "${GO_TOOLS[@]}"; do
      info "安装 $tool..."
      go install "$tool" 2>/dev/null && success "$tool 安装完成" || warn "$tool 安装失败，请手动安装"
    done
  else
    warn "未检测到 Go 环境，跳过 Go 工具安装"
    warn "请先安装 Go: https://go.dev/dl/"
  fi
else
  warn "跳过 Go 工具安装"
fi

# ===== 10. 创建 MySQL 凭据模板 =====
MYSQL_CRED=~/.vim/credentials/mysql.vim
if [ ! -f "$MYSQL_CRED" ]; then
  info "创建 MySQL 凭据模板..."
  cat > "$MYSQL_CRED" << 'EOF'
" MySQL 连接配置（请填入你的实际信息）
" let g:pipe_mysql_host = 'localhost'
" let g:pipe_mysql_port = '3306'
" let g:pipe_mysql_user = 'root'
" let g:pipe_mysql_password = ''
" let g:pipe_mysql_database = ''
EOF
  success "MySQL 凭据模板已创建: $MYSQL_CRED"
fi

# ===== 11. 配置 vim 的 pack 路径（确保 YCM 能被加载）=====
info "配置 vim pack 路径..."
# 确保 ~/.vim/my/start 在 packpath 中
if ! grep -q "set packpath+=~/.vim/my" ~/.vimrc 2>/dev/null; then
  # YCM 放在 ~/.vim/my/start/ 下，需要确保 packpath 包含它
  # 检查是否已经有 packpath 设置
  if [ -d ~/.vim/my/start/YouCompleteMe ]; then
    info "YCM 路径已就绪: ~/.vim/my/start/YouCompleteMe"
  fi
fi
success "pack 路径配置完成"

# ===== 安装完成 =====
echo ""
echo "============================================"
success "🎉 vim 开发环境安装完成！"
echo "============================================"
echo ""
info "后续步骤："
echo "  1. 打开 vim 执行 :PackUpdate 确保所有插件已安装"
echo "  2. 在 vim 中执行 :GoInstallBinaries 安装 vim-go 依赖"
echo "  3. 如需 MySQL 插件，编辑 ~/.vim/credentials/mysql.vim"
echo ""
info "常用命令："
echo "  :PackUpdate   - 更新所有插件"
echo "  :PackClean    - 清理未使用的插件"
echo "  :PackStatus   - 查看插件状态"
echo ""
