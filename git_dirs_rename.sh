#!/bin/bash

# 定义要排除的外层仓库.git目录（避免修改主仓库的.git）
MAIN_GIT_DIR="./.git"
# 初始化计数器（使用文件临时存储计数，避免管道子进程隔离问题）
count_file=$(mktemp)
echo "0 0 0" > "$count_file"  # 格式：count_total count_success count_skip

echo "🔍 开始查找嵌套的.git目录（排除主仓库.git）..."

# 改用进程替换方式遍历，避免管道子进程隔离
while read -r git_dir; do
    # 读取当前计数
    read count_total count_success count_skip < "$count_file"
    
    # 每找到一个目录就打印路径，总数+1
    echo "📌 找到嵌套.git目录：$git_dir"
    ((count_total++))
    
    # 拼接备份后的路径
    bak_dir="${git_dir}.bak"
    # 检查目标路径是否已存在，避免覆盖
    if [ -d "$bak_dir" ]; then
        echo "⚠️  警告：$bak_dir 已存在，跳过重命名 $git_dir"
        ((count_skip++))
        # 写入更新后的计数
        echo "$count_total $count_success $count_skip" > "$count_file"
        continue
    fi
    # 重命名.git为.git.bak
    mv "$git_dir" "$bak_dir"
    echo "✅ 已重命名：$git_dir -> $bak_dir"
    ((count_success++))
    
    # 写入更新后的计数
    echo "$count_total $count_success $count_skip" > "$count_file"
done < <(find . -type d -name ".git" -not -path "$MAIN_GIT_DIR")

# 读取最终计数
read count_total count_success count_skip < "$count_file"
# 删除临时文件
rm -f "$count_file"

# 打印清晰的统计结果
echo -e "\n📊 【重命名.git目录统计结果】"
echo "   🔍 找到嵌套.git目录总数：$count_total 个"
echo "   ✅ 成功重命名数量：$count_success 个"
echo "   ⚠️  跳过数量（冲突/其他）：$count_skip 个"

# 补充无匹配目录的友好提示
if [ $count_total -eq 0 ]; then
    echo -e "\nℹ️  未找到任何需要重命名的嵌套.git目录（已排除主仓库.git）"
fi