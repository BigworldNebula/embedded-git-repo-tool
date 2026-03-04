#!/bin/bash

# 初始化计数器（使用文件临时存储计数，避免管道子进程隔离问题）
count_file=$(mktemp)
echo "0 0 0" > "$count_file"  # 格式：count_total count_success count_skip

echo "🔍 开始查找需要恢复的.git.bak目录..."

# 改用进程替换方式遍历，避免管道子进程隔离
while read -r bak_dir; do
    # 读取当前计数
    read count_total count_success count_skip < "$count_file"
    
    # 每找到一个目录就打印路径，总数+1
    echo "📌 找到.git.bak目录：$bak_dir"
    ((count_total++))
    
    # 拼接恢复后的.git路径
    git_dir="${bak_dir%.bak}"
    # 检查目标路径是否已存在，避免冲突
    if [ -d "$git_dir" ]; then
        echo "⚠️  警告：$git_dir 已存在，跳过恢复 $bak_dir"
        ((count_skip++))
        # 写入更新后的计数
        echo "$count_total $count_success $count_skip" > "$count_file"
        continue
    fi
    # 恢复.git.bak为.git
    mv "$bak_dir" "$git_dir"
    echo "✅ 已恢复：$bak_dir -> $git_dir"
    ((count_success++))
    
    # 写入更新后的计数
    echo "$count_total $count_success $count_skip" > "$count_file"
done < <(find . -type d -name ".git.bak")

# 读取最终计数
read count_total count_success count_skip < "$count_file"
# 删除临时文件
rm -f "$count_file"

# 打印清晰的统计结果
echo -e "\n📊 【恢复.git.bak目录统计结果】"
echo "   🔍 找到.git.bak目录总数：$count_total 个"
echo "   ✅ 成功恢复数量：$count_success 个"
echo "   ⚠️  跳过数量（冲突/其他）：$count_skip 个"

# 补充无匹配目录的友好提示
if [ $count_total -eq 0 ]; then
    echo -e "\nℹ️  未找到任何需要恢复的.git.bak目录"
fi