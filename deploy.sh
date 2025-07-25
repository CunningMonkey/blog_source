#!/bin/bash

echo "🚀 部署博客到GitHub Pages..."

# 获取仓库信息
REPO_NAME=$(basename -s .git $(git config --get remote.origin.url))
USER_NAME=$(git config --get remote.origin.url | sed -n 's/.*github\.com[:/]\([^/]*\)\/.*/\1/p')

echo "📦 仓库: $USER_NAME/$REPO_NAME"

# 检查是否有未提交的更改
if ! git diff-index --quiet HEAD --; then
    echo "⚠️  发现未提交的更改，正在提交..."
    git add .
    git commit -m "Update blog content"
    git push origin main
fi

# 重新构建博客
echo "🔨 重新构建博客..."
go run main.go

if [ $? -eq 0 ]; then
    echo "✅ 博客构建成功"
    
    # 创建新的gh-pages分支
    echo "🌐 部署到GitHub Pages..."
    
    # 切换到public目录
    cd public
    
    # 初始化新的git仓库
    git init
    git add .
    git commit -m "Deploy blog - $(date '+%Y-%m-%d %H:%M:%S')"
    
    # 添加远程仓库
    git remote add origin git@github.com:$USER_NAME/$REPO_NAME.git
    
    # 强制推送到gh-pages分支
    git push -f origin HEAD:gh-pages
    
    # 返回原目录
    cd ..
    
    # 清理临时git仓库
    rm -rf public/.git
    
    echo "✅ 部署完成"
else
    echo "❌ 博客构建失败"
    exit 1
fi

echo ""
echo "🎉 博客已成功部署！"
echo "🌐 访问地址: https://$USER_NAME.github.io/$REPO_NAME/"
echo "⏳ 可能需要等待5-10分钟才能完全生效..." 