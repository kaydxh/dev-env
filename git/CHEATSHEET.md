# Git 常用命令速查

## 目录

- [基础配置](#基础配置)
- [仓库操作](#仓库操作)
- [暂存与提交](#暂存与提交)
- [分支管理](#分支管理)
- [远程操作](#远程操作)
- [查看历史](#查看历史)
- [差异对比](#差异对比)
- [撤销与回退](#撤销与回退)
- [暂存工作区](#暂存工作区)
- [标签管理](#标签管理)
- [合并与变基](#合并与变基)
- [Cherry-pick](#cherry-pick)
- [子模块](#子模块)
- [Git LFS](#git-lfs)
- [搜索与调试](#搜索与调试)
- [清理与维护](#清理与维护)
- [高级技巧](#高级技巧)
- [常用别名推荐](#常用别名推荐)

---

## 基础配置

### 用户信息

| 命令 | 功能 |
|------|------|
| `git config --global user.name "name"` | 设置全局用户名 |
| `git config --global user.email "email"` | 设置全局邮箱 |
| `git config --local user.name "name"` | 设置当前仓库用户名 |
| `git config --list` | 查看所有配置 |
| `git config --global --list` | 查看全局配置 |
| `git config user.name` | 查看当前用户名 |

### 常用配置

| 命令 | 功能 |
|------|------|
| `git config --global core.editor vim` | 设置默认编辑器 |
| `git config --global core.autocrlf input` | 换行符处理（macOS/Linux） |
| `git config --global core.quotepath false` | 正确显示中文文件名 |
| `git config --global pull.rebase true` | pull 时默认 rebase |
| `git config --global push.default current` | push 默认推送当前分支 |
| `git config --global init.defaultBranch main` | 默认分支名为 main |
| `git config --global credential.helper store` | 记住密码 |

### 条件配置（includeIf）

```bash
# 针对不同目录使用不同配置（如公司和个人项目）
[includeIf "gitdir:~/workspace/company-git/"]
    path = ~/.gitconfig-company
```

---

## 仓库操作

| 命令 | 功能 |
|------|------|
| `git init` | 初始化新仓库 |
| `git init --bare` | 初始化裸仓库（服务器用） |
| `git clone <url>` | 克隆远程仓库 |
| `git clone <url> <dir>` | 克隆到指定目录 |
| `git clone --depth 1 <url>` | 浅克隆（只取最新提交） |
| `git clone --branch <branch> <url>` | 克隆指定分支 |
| `git clone --recurse-submodules <url>` | 克隆含子模块的仓库 |

### 实际示例

```bash
# 克隆项目到指定目录
git clone https://github.com/kaydxh/golang.git ~/workspace/github.com/kaydxh/golang

# 只克隆最新代码（节省时间和空间，适合 CI）
git clone --depth 1 https://github.com/kubernetes/kubernetes.git

# 克隆指定分支
git clone --branch release-1.28 https://github.com/kubernetes/kubernetes.git
```

---

## 暂存与提交

### 暂存（Stage）

| 命令 | 功能 |
|------|------|
| `git add <file>` | 暂存指定文件 |
| `git add .` | 暂存所有变更 |
| `git add -A` | 暂存所有变更（含删除） |
| `git add -p` | 交互式暂存（逐块选择） |
| `git add -u` | 暂存已跟踪文件的修改和删除 |
| `git rm <file>` | 删除文件并暂存 |
| `git rm --cached <file>` | 从暂存区移除（保留本地文件） |
| `git mv <old> <new>` | 重命名文件 |

### 提交（Commit）

| 命令 | 功能 |
|------|------|
| `git commit -m "msg"` | 提交并附带消息 |
| `git commit -am "msg"` | 暂存已跟踪文件并提交 |
| `git commit --amend` | 修改最近一次提交 |
| `git commit --amend --no-edit` | 修改提交内容但不改消息 |
| `git commit --amend --author="name <email>"` | 修改提交作者 |
| `git commit --allow-empty -m "msg"` | 创建空提交（触发 CI） |
| `git commit -v` | 提交时显示 diff |

### 查看状态

| 命令 | 功能 |
|------|------|
| `git status` | 查看工作区状态 |
| `git status -s` | 简短格式显示状态 |
| `git status -sb` | 简短格式 + 分支信息 |

### 实际示例

```bash
# 交互式暂存：只提交文件中的部分修改（比如一个文件改了两处，只想提交其中一处）
git add -p main.go
# 会逐块显示 diff，输入 y 暂存、n 跳过、s 拆分更小的块

# 误 add 了不想提交的文件，从暂存区移除但保留本地文件
git rm --cached config/local.yaml

# 修改上次提交（忘了加文件或写错了 commit message）
git add forgotten_file.go
git commit --amend

# 修改上次提交但不改消息（只是补充文件）
git commit --amend --no-edit

# 创建空提交触发 CI 重新构建
git commit --allow-empty -m "ci: trigger rebuild"
```

---

## 分支管理

### 查看分支

| 命令 | 功能 |
|------|------|
| `git branch` | 列出本地分支 |
| `git branch -r` | 列出远程分支 |
| `git branch -a` | 列出所有分支 |
| `git branch -v` | 列出分支及最新提交 |
| `git branch -vv` | 列出分支及跟踪关系 |
| `git branch --merged` | 列出已合并到当前分支的分支 |
| `git branch --no-merged` | 列出未合并的分支 |

### 创建与切换

| 命令 | 功能 |
|------|------|
| `git branch <name>` | 创建分支 |
| `git checkout <branch>` | 切换分支 |
| `git checkout -b <branch>` | 创建并切换分支 |
| `git switch <branch>` | 切换分支（新语法） |
| `git switch -c <branch>` | 创建并切换（新语法） |
| `git checkout -b <branch> origin/<branch>` | 基于远程分支创建本地分支 |
| `git branch -m <old> <new>` | 重命名分支 |

### 删除分支

| 命令 | 功能 |
|------|------|
| `git branch -d <branch>` | 删除已合并的分支 |
| `git branch -D <branch>` | 强制删除分支 |
| `git push origin --delete <branch>` | 删除远程分支 |
| `git remote prune origin` | 清理已删除的远程分支引用 |
| `git fetch -p` | 拉取并清理无效远程分支 |

### 实际示例

```bash
# 从 main 创建功能分支并切换
git checkout main && git pull
git checkout -b feature/add-user-auth

# 查看哪些分支已经合并到 main（可以安全删除）
git branch --merged main

# 批量删除已合并的本地分支（排除 main 和当前分支）
git branch --merged main | grep -v "main\|\*" | xargs git branch -d

# 清理远程已删除但本地还有引用的分支
git fetch -p

# 查看所有分支的最新提交和跟踪关系
git branch -vv
```

---

## 远程操作

### 远程仓库管理

| 命令 | 功能 |
|------|------|
| `git remote -v` | 查看远程仓库地址 |
| `git remote add <name> <url>` | 添加远程仓库 |
| `git remote remove <name>` | 移除远程仓库 |
| `git remote rename <old> <new>` | 重命名远程仓库 |
| `git remote set-url origin <url>` | 修改远程仓库地址 |
| `git remote show origin` | 查看远程仓库详情 |

### 拉取与推送

| 命令 | 功能 |
|------|------|
| `git fetch` | 拉取远程更新（不合并） |
| `git fetch --all` | 拉取所有远程仓库更新 |
| `git pull` | 拉取并合并 |
| `git pull --rebase` | 拉取并变基 |
| `git pull origin <branch>` | 拉取指定远程分支 |
| `git push` | 推送到远程 |
| `git push -u origin <branch>` | 推送并设置上游分支 |
| `git push --force` | 强制推送（⚠️ 慎用） |
| `git push --force-with-lease` | 安全强制推送（推荐） |
| `git push origin --tags` | 推送所有标签 |
| `git push origin <tag>` | 推送指定标签 |

### 实际示例

```bash
# 第一次推送新分支到远程
git push -u origin feature/add-user-auth

# 本地 rebase 后需要强制推送（安全方式，防止覆盖他人提交）
git push --force-with-lease

# 同时管理多个远程仓库（如 GitHub 和公司内部 Git）
git remote add upstream https://github.com/original/repo.git
git fetch upstream
git merge upstream/main

# 修改远程仓库地址（如从 HTTPS 切换到 SSH）
git remote set-url origin git@github.com:kaydxh/dev-env.git
```

---

## 查看历史

### 日志查看

| 命令 | 功能 |
|------|------|
| `git log` | 查看提交历史 |
| `git log --oneline` | 单行显示 |
| `git log --oneline -n 10` | 显示最近 10 条 |
| `git log --graph` | 图形化显示分支 |
| `git log --graph --oneline --all` | 图形化显示所有分支 |
| `git log --stat` | 显示文件变更统计 |
| `git log -p` | 显示详细 diff |
| `git log -p <file>` | 查看文件修改历史 |
| `git log --author="name"` | 按作者过滤 |
| `git log --since="2024-01-01"` | 按日期过滤 |
| `git log --grep="keyword"` | 按提交消息搜索 |
| `git log --follow <file>` | 跟踪文件重命名历史 |
| `git log branch1..branch2` | 查看 branch2 有而 branch1 没有的提交 |

### 其他查看命令

| 命令 | 功能 |
|------|------|
| `git show <commit>` | 查看某次提交详情 |
| `git show <commit>:<file>` | 查看某次提交时的文件内容 |
| `git shortlog -sn` | 按作者统计提交数 |
| `git blame <file>` | 查看文件每行的最后修改者 |
| `git blame -L 10,20 <file>` | 查看指定行范围的 blame |
| `git reflog` | 查看所有操作记录（含已删除的提交） |

### 实际示例

```bash
# 查看最近一周自己的提交
git log --author="kayxhding" --since="1 week ago" --oneline

# 图形化查看所有分支的合并历史
git log --graph --oneline --all --decorate

# 查看某个文件的修改历史（含重命名追踪）
git log --follow -p -- pkg/auth/handler.go

# 找出谁在什么时候改了某一行代码
git blame -L 42,42 internal/service/user.go

# 查看某次提交时某个文件的完整内容
git show HEAD~3:go.mod

# 搜索包含 "panic" 的提交
git log --grep="panic" --oneline

# 查看两个版本之间的提交差异
git log v1.0.0..v2.0.0 --oneline
```

---

## 差异对比

| 命令 | 功能 |
|------|------|
| `git diff` | 工作区 vs 暂存区 |
| `git diff --staged` | 暂存区 vs 最新提交 |
| `git diff --cached` | 同 `--staged` |
| `git diff HEAD` | 工作区 vs 最新提交 |
| `git diff <commit1> <commit2>` | 两次提交之间的差异 |
| `git diff <branch1>..<branch2>` | 两个分支之间的差异 |
| `git diff --stat` | 只显示变更统计 |
| `git diff --name-only` | 只显示变更文件名 |
| `git diff --name-status` | 显示文件名和变更类型 |
| `git diff -- <file>` | 查看指定文件的差异 |

### 实际示例

```bash
# 提交前检查暂存区的改动（code review 自己的代码）
git diff --staged

# 只看改了哪些文件（不看具体内容）
git diff --name-only HEAD~3

# 对比两个分支的差异，只看文件列表
git diff main..feature/auth --name-status

# 对比某个文件在两个分支中的差异
git diff main..feature/auth -- pkg/auth/handler.go
```

---

## 撤销与回退

### 工作区撤销

| 命令 | 功能 |
|------|------|
| `git checkout -- <file>` | 撤销工作区修改（恢复到暂存区） |
| `git restore <file>` | 撤销工作区修改（新语法） |
| `git checkout .` | 撤销所有工作区修改 |
| `git clean -fd` | 删除未跟踪的文件和目录 |
| `git clean -fdn` | 预览将被删除的文件（dry-run） |

### 暂存区撤销

| 命令 | 功能 |
|------|------|
| `git reset HEAD <file>` | 取消暂存（保留修改） |
| `git restore --staged <file>` | 取消暂存（新语法） |
| `git reset HEAD` | 取消所有暂存 |

### 提交回退

| 命令 | 功能 |
|------|------|
| `git reset --soft HEAD~1` | 回退提交，保留暂存和工作区 |
| `git reset --mixed HEAD~1` | 回退提交和暂存，保留工作区（默认） |
| `git reset --hard HEAD~1` | 回退提交、暂存和工作区（⚠️ 慎用） |
| `git reset --hard <commit>` | 回退到指定提交 |
| `git revert <commit>` | 创建新提交来撤销指定提交（安全） |
| `git revert HEAD` | 撤销最近一次提交 |
| `git revert --no-commit <commit>` | 撤销但不自动提交 |

### 恢复误操作

| 命令 | 功能 |
|------|------|
| `git reflog` | 查看操作历史 |
| `git reset --hard <reflog-hash>` | 恢复到 reflog 中的某个状态 |
| `git cherry-pick <commit>` | 恢复某个被删除的提交 |

### 实际示例

```bash
# 场景1：改了代码但还没 add，想放弃所有修改
git checkout .

# 场景2：已经 add 但还没 commit，想取消暂存
git restore --staged .

# 场景3：已经 commit 但还没 push，想撤回提交但保留代码
git reset --soft HEAD~1

# 场景4：已经 push 了，想安全地撤销某次提交（不影响他人）
git revert abc1234

# 场景5：误操作 reset --hard 丢了代码，用 reflog 找回
git reflog
# 找到丢失前的 hash，比如 abc1234
git reset --hard abc1234

# 场景6：只想撤销某个文件的修改，其他保留
git checkout -- path/to/file.go
```

---

## 暂存工作区

| 命令 | 功能 |
|------|------|
| `git stash` | 暂存当前工作区 |
| `git stash -u` | 暂存含未跟踪文件 |
| `git stash save "msg"` | 暂存并附带描述 |
| `git stash list` | 查看暂存列表 |
| `git stash pop` | 恢复最近的暂存并删除 |
| `git stash apply` | 恢复最近的暂存（不删除） |
| `git stash apply stash@{n}` | 恢复指定暂存 |
| `git stash drop stash@{n}` | 删除指定暂存 |
| `git stash clear` | 清空所有暂存 |
| `git stash show -p` | 查看暂存内容 |
| `git stash branch <branch>` | 基于暂存创建分支 |

### 实际示例

```bash
# 场景：正在开发功能，突然要切分支修 bug
git stash save "feat: 用户认证开发到一半"
git checkout hotfix/urgent-bug
# ... 修完 bug ...
git checkout feature/auth
git stash pop

# 查看 stash 里存了什么
git stash list
# stash@{0}: On feature/auth: feat: 用户认证开发到一半
# stash@{1}: On main: wip: 调试中间状态

# 只恢复某个 stash（不删除）
git stash apply stash@{1}

# stash 含未跟踪的新文件
git stash -u
```

---

## 标签管理

| 命令 | 功能 |
|------|------|
| `git tag` | 列出所有标签 |
| `git tag -l "v1.*"` | 按模式搜索标签 |
| `git tag <name>` | 创建轻量标签 |
| `git tag -a <name> -m "msg"` | 创建附注标签 |
| `git tag -a <name> <commit>` | 给历史提交打标签 |
| `git tag -d <name>` | 删除本地标签 |
| `git push origin --delete <tag>` | 删除远程标签 |
| `git show <tag>` | 查看标签详情 |
| `git checkout <tag>` | 切换到标签（分离 HEAD） |

---

## 合并与变基

### 合并（Merge）

| 命令 | 功能 |
|------|------|
| `git merge <branch>` | 合并分支到当前分支 |
| `git merge --no-ff <branch>` | 非快进合并（保留分支历史） |
| `git merge --squash <branch>` | 压缩合并（合为一个提交） |
| `git merge --abort` | 取消合并 |
| `git merge --continue` | 解决冲突后继续合并 |

### 变基（Rebase）

| 命令 | 功能 |
|------|------|
| `git rebase <branch>` | 将当前分支变基到目标分支 |
| `git rebase -i HEAD~n` | 交互式变基（修改最近 n 个提交） |
| `git rebase --abort` | 取消变基 |
| `git rebase --continue` | 解决冲突后继续变基 |
| `git rebase --skip` | 跳过当前冲突提交 |
| `git rebase --onto <new> <old> <branch>` | 将分支移植到新基点 |

### 交互式变基操作

```bash
# git rebase -i HEAD~3 打开编辑器后可用的操作：
pick   = 保留提交
reword = 修改提交消息
edit   = 暂停以修改提交内容
squash = 合并到上一个提交（保留消息）
fixup  = 合并到上一个提交（丢弃消息）
drop   = 删除提交
```

### 解决冲突

```bash
# 冲突解决流程
git merge <branch>          # 1. 合并产生冲突
# 手动编辑冲突文件           # 2. 解决冲突
git add <file>              # 3. 标记已解决
git merge --continue        # 4. 继续合并
# 或
git commit                  # 4. 提交合并结果
```

### 实际示例

```bash
# 场景1：功能分支合并前先 rebase 主分支（保持线性历史）
git checkout feature/auth
git fetch origin
git rebase origin/main
# 如果有冲突，解决后：
git add .
git rebase --continue

# 场景2：用交互式 rebase 整理提交（合并多个 WIP 提交为一个）
git rebase -i HEAD~4
# 编辑器中将后面的 pick 改为 squash 或 fixup：
# pick abc1234 feat: add user model
# squash def5678 wip: debugging
# squash ghi9012 fix: typo
# squash jkl3456 wip: almost done

# 场景3：squash merge（将功能分支的所有提交压缩为一个提交合入 main）
git checkout main
git merge --squash feature/auth
git commit -m "feat(auth): add user authentication module"

# 场景4：rebase 搞砸了想恢复
git rebase --abort
```

---

## Cherry-pick

| 命令 | 功能 |
|------|------|
| `git cherry-pick <commit>` | 拣选单个提交 |
| `git cherry-pick <c1> <c2>` | 拣选多个提交 |
| `git cherry-pick <c1>..<c2>` | 拣选范围（不含 c1） |
| `git cherry-pick <c1>^..<c2>` | 拣选范围（含 c1） |
| `git cherry-pick --no-commit <commit>` | 拣选但不提交 |
| `git cherry-pick --abort` | 取消拣选 |
| `git cherry-pick --continue` | 解决冲突后继续 |

---

## 子模块

| 命令 | 功能 |
|------|------|
| `git submodule add <url> <path>` | 添加子模块 |
| `git submodule init` | 初始化子模块 |
| `git submodule update` | 更新子模块 |
| `git submodule update --init --recursive` | 递归初始化并更新 |
| `git submodule foreach git pull` | 更新所有子模块 |
| `git submodule status` | 查看子模块状态 |
| `git submodule deinit <path>` | 取消注册子模块 |

---

## Git LFS

| 命令 | 功能 |
|------|------|
| `git lfs install` | 初始化 LFS |
| `git lfs track "*.psd"` | 跟踪大文件类型 |
| `git lfs untrack "*.psd"` | 取消跟踪 |
| `git lfs ls-files` | 列出 LFS 跟踪的文件 |
| `git lfs status` | 查看 LFS 状态 |
| `git lfs pull` | 拉取 LFS 文件 |
| `git lfs push --all origin` | 推送所有 LFS 文件 |
| `git lfs migrate import --include="*.bin"` | 迁移已有文件到 LFS |

### 实际示例

```bash
# 场景：release 分支上的某个 bugfix 需要同步到 main
git checkout main
git cherry-pick a1b2c3d

# 一次拣选多个连续提交
git cherry-pick a1b2c3d^..f4e5d6a

# 拣选但不立即提交（想合并多个 cherry-pick 为一个提交）
git cherry-pick --no-commit a1b2c3d
git cherry-pick --no-commit b2c3d4e
git commit -m "fix: backport security patches from release"
```

---

## 搜索与调试

### 搜索

| 命令 | 功能 |
|------|------|
| `git grep "pattern"` | 在工作区搜索 |
| `git grep -n "pattern"` | 搜索并显示行号 |
| `git grep -c "pattern"` | 统计匹配次数 |
| `git grep "pattern" <branch>` | 在指定分支搜索 |
| `git log -S "code"` | 搜索引入/删除某段代码的提交 |
| `git log -G "regex"` | 用正则搜索代码变更 |
| `git log --all --full-history -- <file>` | 搜索文件的完整历史（含删除） |

### 调试

| 命令 | 功能 |
|------|------|
| `git bisect start` | 开始二分查找 |
| `git bisect bad` | 标记当前为有问题 |
| `git bisect good <commit>` | 标记某提交为正常 |
| `git bisect reset` | 结束二分查找 |
| `git bisect run <script>` | 自动化二分查找 |

### 实际示例

```bash
# 在整个项目中搜索某个函数调用
git grep -n "HandleRequest" -- "*.go"

# 找出是哪个提交引入了某段代码
git log -S "func NewAuthService" --oneline

# 用 bisect 定位引入 bug 的提交
git bisect start
git bisect bad                    # 当前版本有 bug
git bisect good v1.2.0            # v1.2.0 没有 bug
# Git 会自动 checkout 中间的提交，你测试后标记：
git bisect good                   # 或 git bisect bad
# 重复直到找到引入 bug 的提交
git bisect reset                  # 结束，回到原来的分支

# 自动化 bisect（用脚本判断好坏）
git bisect start HEAD v1.2.0
git bisect run go test ./pkg/auth/...
```

---

## 清理与维护

| 命令 | 功能 |
|------|------|
| `git clean -fd` | 删除未跟踪文件和目录 |
| `git clean -fX` | 删除被 .gitignore 忽略的文件 |
| `git clean -fx` | 删除所有未跟踪文件（含忽略的） |
| `git gc` | 垃圾回收，优化仓库 |
| `git gc --aggressive` | 深度优化 |
| `git prune` | 清理不可达对象 |
| `git fsck` | 检查仓库完整性 |
| `git count-objects -vH` | 查看仓库大小 |

---

## 高级技巧

### Worktree（多工作树）

| 命令 | 功能 |
|------|------|
| `git worktree add <path> <branch>` | 创建新工作树 |
| `git worktree list` | 列出所有工作树 |
| `git worktree remove <path>` | 移除工作树 |

> 适用场景：同时在多个分支上工作，无需频繁切换。

### 补丁操作

| 命令 | 功能 |
|------|------|
| `git format-patch -1 <commit>` | 生成单个提交的补丁 |
| `git format-patch <branch>` | 生成当前分支相对于目标分支的补丁 |
| `git am <patch>` | 应用补丁 |
| `git apply <patch>` | 应用补丁（不创建提交） |
| `git diff > changes.patch` | 导出 diff 为补丁文件 |

### 归档

| 命令 | 功能 |
|------|------|
| `git archive --format=tar HEAD > project.tar` | 导出当前 HEAD 为 tar |
| `git archive --format=zip HEAD > project.zip` | 导出为 zip |
| `git archive --format=tar --prefix=proj/ HEAD` | 带前缀目录导出 |

### 其他实用命令

| 命令 | 功能 |
|------|------|
| `git rev-parse HEAD` | 获取当前 commit hash |
| `git rev-parse --short HEAD` | 获取短 hash |
| `git rev-parse --show-toplevel` | 获取仓库根目录 |
| `git ls-files` | 列出所有跟踪的文件 |
| `git ls-files --others --ignored --exclude-standard` | 列出被忽略的文件 |
| `git update-index --assume-unchanged <file>` | 忽略本地修改（不提交） |
| `git update-index --no-assume-unchanged <file>` | 恢复跟踪 |

---

## 常用别名推荐

在 `~/.gitconfig` 中添加：

```ini
[alias]
    st = status -sb
    co = checkout
    br = branch
    ci = commit
    lg = log --graph --oneline --all --decorate
    last = log -1 HEAD --stat
    unstage = reset HEAD --
    amend = commit --amend --no-edit
    undo = reset --soft HEAD~1
    diff-staged = diff --staged
    branches = branch -a -v
    stashes = stash list
    aliases = config --get-regexp alias
    # 显示今天的提交
    today = log --since=midnight --author='你的名字' --oneline
    # 显示文件变更统计
    stat = diff --stat
    # 快速暂存并提交
    save = !git add -A && git commit -m 'chore: save progress'
```

---

## 常用工作流

### Feature Branch 工作流

```bash
# 1. 从主分支创建功能分支
git checkout main
git pull
git checkout -b feature/my-feature

# 2. 开发并提交
git add .
git commit -m "feat: add new feature"

# 3. 同步主分支变更
git fetch origin
git rebase origin/main

# 4. 推送并创建 MR/PR
git push -u origin feature/my-feature
```

### Hotfix 工作流

```bash
# 1. 从主分支创建修复分支
git checkout main
git pull
git checkout -b hotfix/fix-bug

# 2. 修复并提交
git add .
git commit -m "fix: resolve critical bug"

# 3. 推送并合并
git push -u origin hotfix/fix-bug
# 合并后删除分支
git branch -d hotfix/fix-bug
```

### 交互式变基整理提交

```bash
# 整理最近 3 个提交
git rebase -i HEAD~3

# 常见操作：
# - 合并多个小提交为一个
# - 修改提交消息
# - 调整提交顺序
# - 删除不需要的提交
```

---

## .gitignore 常用模式

```gitignore
# 编译输出
*.o
*.exe
/build/
/dist/

# 依赖目录
/node_modules/
/vendor/

# IDE 文件
.idea/
.vscode/
*.swp
*.swo
*~

# 系统文件
.DS_Store
Thumbs.db

# 环境配置
.env
.env.local

# 日志
*.log
/logs/
```

---

## 提交消息规范（Conventional Commits）

```
<type>(<scope>): <subject>

<body>

<footer>
```

### 类型（type）

| 类型 | 说明 |
|------|------|
| `feat` | 新功能 |
| `fix` | 修复 bug |
| `docs` | 文档变更 |
| `style` | 代码格式（不影响逻辑） |
| `refactor` | 重构（非新功能、非修复） |
| `perf` | 性能优化 |
| `test` | 测试相关 |
| `chore` | 构建/工具变更 |
| `ci` | CI 配置变更 |
| `revert` | 回退提交 |

### 示例

```bash
feat(auth): add OAuth2 login support
fix(api): resolve timeout issue in user query
docs(readme): update installation instructions
refactor(core): extract common validation logic
```
