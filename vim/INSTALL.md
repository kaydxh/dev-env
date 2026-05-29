# Vim 开发环境安装说明

## 环境要求

- macOS（支持 Intel 和 Apple Silicon）
- Git
- 网络连接（用于下载依赖和插件）

## 快速安装

```bash
git clone https://github.com/kaydxh/dev-env.git
cd dev-env/vim
chmod +x install.sh
./install.sh
```

## 安装选项

| 参数 | 说明 |
|------|------|
| `--skip-brew` | 跳过 Homebrew 及其依赖安装 |
| `--skip-ycm` | 跳过 YouCompleteMe 编译（耗时较长，约 5-10 分钟） |
| `--skip-go` | 跳过 Go 开发工具安装 |
| `--help` | 显示帮助信息 |

### 示例

```bash
# 完整安装
./install.sh

# 跳过 YCM（后续可手动安装）
./install.sh --skip-ycm

# 仅部署配置和插件（已有 brew 依赖）
./install.sh --skip-brew
```

## 安装内容

### Homebrew 依赖

| 包名 | 用途 |
|------|------|
| vim | Vim 编辑器（带 +python3 支持） |
| universal-ctags | 代码标签生成（gutentags 插件依赖） |
| ripgrep | 快速代码搜索（fzf-ripgrep 依赖） |
| fd | 快速文件搜索（fzf 依赖） |
| fzf | 模糊搜索 |
| ack | 代码搜索（ack.vim 插件依赖） |
| clang-format | C/C++ 代码格式化 |
| cmake | 编译 YCM 需要 |
| python3 | Python3 支持 |
| node | Node.js（markdown-preview、YCM 前端补全依赖） |
| shellcheck | Shell 脚本静态分析 |

### Vim 插件列表

通过 [minpac](https://github.com/k-takata/minpac) 管理：

| 插件 | 功能 |
|------|------|
| vim-gitgutter | Git 变更标记 |
| fzf / fzf.vim | 模糊搜索文件、内容 |
| fzf-ripgrep.vim | ripgrep 集成 |
| tagbar | 代码结构大纲 |
| undotree | 撤销历史树 |
| vim-visual-multi | 多光标编辑 |
| nerdcommenter | 快速注释 |
| nerdtree | 文件树浏览 |
| asyncrun.vim | 异步执行命令 |
| vim-fugitive | Git 集成 |
| vim-surround | 快速包围编辑 |
| vim-airline | 状态栏美化 |
| vim-clang-format | C/C++ 格式化 |
| ack.vim | 代码搜索 |
| markdown-preview.nvim | Markdown 实时预览 |
| ale | 异步语法检查 |
| vim-gutentags | 自动管理 ctags |
| pipe-mysql.vim | MySQL 客户端 |

独立安装：

| 插件 | 功能 |
|------|------|
| vim-go | Go 开发全套支持 |
| YouCompleteMe | 智能代码补全 |

### YouCompleteMe 支持的语言

YCM 编译时启用了以下语言引擎：

| 语言 | 引擎 | 说明 |
|------|------|------|
| C/C++ | clangd | `--clangd-completer`，语义补全、跳转定义 |
| Go | gopls | `--go-completer`，语义补全、跳转定义 |
| TypeScript/JavaScript | tsserver | `--ts-completer`，前端开发补全 |
| Python | Jedi | 内置支持，无需额外参数 |
| Shell (Bash/Zsh) | 通过 ALE + shellcheck | 语法检查和补全 |

> **注意**：YCM 的 `--ts-completer` 需要系统已安装 Node.js（脚本会自动通过 brew 安装）。
> Shell 脚本的补全和检查通过 ALE 插件 + shellcheck 实现，不依赖 YCM。

### Go 开发工具

| 工具 | 用途 |
|------|------|
| gopls | Go 语言服务器（补全、跳转、重构） |
| golines | Go 代码自动换行格式化 |

## 安装后配置

### 1. 更新插件

首次打开 vim 后执行：

```vim
:PackUpdate
```

### 2. 安装 vim-go 依赖

```vim
:GoInstallBinaries
```

### 3. MySQL 配置（可选）

编辑 `~/.vim/credentials/mysql.vim`：

```vim
let g:pipe_mysql_host = 'localhost'
let g:pipe_mysql_port = '3306'
let g:pipe_mysql_user = 'root'
let g:pipe_mysql_password = 'your_password'
let g:pipe_mysql_database = 'your_db'
```

## 常用快捷键

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+]` | 跳转到定义（YCM） |
| `F4` | 切换 NERDTree 文件树 |
| `F5` | 异步构建 |
| `F6` | 切换撤销树 |
| `F9` | 切换 Tagbar |
| `\fi` | YCM FixIt |
| `\gt` | YCM GoTo |
| `\gh` | YCM GoToDeclaration |
| `\gr` | YCM GoToReferences |

## 常用 Vim 命令

| 命令 | 功能 |
|------|------|
| `:PackUpdate` | 更新所有插件 |
| `:PackClean` | 清理未使用的插件 |
| `:PackStatus` | 查看插件状态 |
| `:GoInstallBinaries` | 安装/更新 Go 工具 |
| `:Gdiff` | Git diff 对比 |
| `:GFiles` | 搜索 Git 文件 |
| `:Rg <pattern>` | ripgrep 搜索 |

## 目录结构

安装完成后的 vim 目录结构：

```
~/.vim/
├── pack/
│   ├── minpac/opt/minpac/     # minpac 插件管理器
│   ├── minpac/start/          # minpac 管理的插件
│   └── plugins/start/vim-go/  # vim-go 插件
├── my/start/YouCompleteMe/    # YCM 补全引擎
├── credentials/mysql.vim      # MySQL 凭据（不入 git）
├── undodir/                   # 持久化撤销历史
└── ...
~/.cache/tags/                 # gutentags 缓存目录
~/.vimrc                       # 主配置文件
```

## 故障排查

### YCM 报错 "No module named 'ycmd'"

重新编译 YCM：

```bash
cd ~/.vim/my/start/YouCompleteMe
git submodule update --init --recursive
python3 install.py --clangd-completer --go-completer --ts-completer
```

### 插件未加载

确认 minpac 已安装：

```bash
ls ~/.vim/pack/minpac/opt/minpac
```

在 vim 中执行 `:PackUpdate`。

### ctags 报错

确认使用的是 universal-ctags 而非 macOS 自带的 BSD ctags：

```bash
/opt/homebrew/bin/ctags --version
# 应显示 Universal Ctags
```

### 前端补全不工作

确认 Node.js 已安装且 tsserver 可用：

```bash
node --version
# 应显示 v16+ 版本
```

如果 YCM 编译时未加 `--ts-completer`，需重新编译：

```bash
cd ~/.vim/my/start/YouCompleteMe
python3 install.py --clangd-completer --go-completer --ts-completer
```
