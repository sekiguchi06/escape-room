#!/bin/bash
# AI画像生成環境セットアップスクリプト

echo "🚀 Setting up AI Image Generation Environment"
echo "================================================"

# Python依存関係インストール
echo "📦 Installing Python dependencies..."
pip3 install --upgrade pip
pip3 install openai requests pillow

# Adobe Firefly CLI (もし存在すれば)
echo "🔍 Checking for Adobe Firefly CLI..."
if command -v firefly &> /dev/null; then
    echo "✅ Adobe Firefly CLI found"
else
    echo "❌ Adobe Firefly CLI not found"
    echo "   Manual installation required"
fi

# 環境変数設定案内
echo ""
echo "🔑 Required Environment Variables:"
echo "   export OPENAI_API_KEY='your_openai_api_key'"
echo "   export STABILITY_API_KEY='your_stability_api_key' (optional)"
echo ""
echo "💡 Add these to your ~/.zshrc or ~/.bashrc:"
echo "   echo 'export OPENAI_API_KEY=your_key' >> ~/.zshrc"
echo ""

# ディレクトリ作成
echo "📁 Creating directories..."
mkdir -p scripts
mkdir -p generated_assets/screenshots

echo "✅ Setup completed!"
echo ""
echo "🚀 Usage:"
echo "   python3 scripts/ai_asset_generator.py"
echo ""