# Git Nested Repo Helper

这是一个用于解决 Git 仓库嵌套（Sub-repository）上传问题的工具集。

## ⚠️ 问题背景

在 Git 项目中，如果一个子目录下包含 `.git` 文件夹（即它本身也是一个 Git 仓库），父级仓库默认会将其视为 Submodule（子模块）或者直接忽略，导致子仓库的文件内容无法被直接提交到父级仓库中。

为了能够将子仓库的代码作为普通文件上传到父级仓库，同时保留子仓库的 Git 版本控制能力（以便在本地继续作为独立仓库管理），我们需要一种机制来临时隐藏子仓库的 `.git` 目录。

## 🛠️ 功能介绍

本项目包含两个核心脚本，通过重命名 `.git` 目录的方式来实现嵌套仓库的上传与恢复：

1.  **`git_dirs_rename.sh`**：将子仓库的 `.git` 目录重命名为 `.git.bak`。
    *   **作用**：让 Git 认为子仓库只是普通目录，从而允许将其包含的文件（以及 `.git.bak` 备份）提交到父级仓库。
2.  **`git_dirs_restore.sh`**：将子仓库的 `.git.bak` 目录恢复为 `.git`。
    *   **作用**：在 clone 下来后（或上传完成后），恢复子仓库的 Git 功能。

## 🚀 使用指南

### 1. 上传前（隐藏子仓库 Git 信息）

在执行 `git add` / `git commit` / `git push` 之前，运行重命名脚本：

```bash
chmod +x git_dirs_rename.sh
./git_dirs_rename.sh
```

此时，所有嵌套子仓库的 `.git` 目录都会被重命名为 `.git.bak`。你可以正常提交代码：

```bash
git add .
git commit -m "feat: upload nested repositories"
git push
```

> **注意**：这会将 `.git.bak` 目录及其内容也一并上传到远程仓库。如果你只希望上传代码文件而不上传子仓库的 Git 历史（`.git` 目录），请在 `.gitignore` 中忽略 `.git.bak`，或者在运行脚本后手动删除 `.git.bak`（警告：这会丢失子仓库的版本历史）。根据本工具的设计思路，建议保留 `.git.bak` 以便后续恢复。

### 2. Clone 后 / 恢复后（恢复子仓库 Git 功能）

当你 clone 了包含 `.git.bak` 的父级仓库，或者在本地完成上传操作想要继续开发子仓库时，运行恢复脚本：

```bash
chmod +x git_dirs_restore.sh
./git_dirs_restore.sh
```

此时，所有的 `.git.bak` 目录会变回 `.git`，子仓库恢复为独立的 Git 仓库状态。

## 📂 文件说明

*   `git_dirs_rename.sh`: 查找当前目录下（排除根目录 `.git`）所有的 `.git` 目录并重命名。
*   `git_dirs_restore.sh`: 查找当前目录下所有的 `.git.bak` 目录并恢复命名。

## 📝 最佳实践

*   建议将这两个脚本放在父级仓库的根目录下。
*   在使用前请确保脚本具有执行权限：
    ```bash
    chmod +x git_dirs_rename.sh git_dirs_restore.sh
    ```
