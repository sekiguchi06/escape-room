#!/usr/bin/env python3
"""
App Assets Auto-Generation Script
AIによるアプリ素材自動生成・配置システム
"""

import os
import sys
import json
import requests
import subprocess
from pathlib import Path
from PIL import Image
import openai

# 設定
CONFIG = {
    "project_root": "/Users/sekiguchi/git/proto/casual_game_template",
    "output_dir": "generated_assets",
    "prompts": {
        "app_icon": """
        Create a cute and friendly mobile app icon for an escape room puzzle game. 
        Flat design style, anime-inspired illustration, no gradients or shadows. 
        Features: adorable cartoon key in the center, simple rounded door, sparkles and stars around. 
        Pastel color palette: soft blue (#7EC8E3), pastel yellow (#FFE066), soft pink (#FFB3E6), 
        cream background (#FFF8DC). Clean vector art style, minimalist, child-friendly, 
        accessible design, no text, no existing characters, 1024x1024 resolution.
        """,
        "screenshot_menu": """
        Game menu screen for cute escape room puzzle game. Flat design, pastel colors, 
        anime style. Show game title "Escape Master" in cute font, play button, 
        settings button. Kawaii style interface, soft blue background with sparkles.
        """,
        "screenshot_gameplay": """
        Gameplay screen for cute escape room puzzle game. Show cartoon room with 
        adorable furniture, cute key items, inventory UI at bottom, pastel colors, 
        flat design, anime style, child-friendly aesthetic.
        """,
        "screenshot_success": """
        Victory screen for cute escape room puzzle game. Show congratulations message, 
        sparkles, stars, cute key character celebrating, pastel colors, anime style, 
        kawaii aesthetic, flat design.
        """
    },
    "icon_sizes": [
        {"name": "Icon-App-20x20@1x.png", "size": (20, 20)},
        {"name": "Icon-App-20x20@2x.png", "size": (40, 40)},
        {"name": "Icon-App-20x20@3x.png", "size": (60, 60)},
        {"name": "Icon-App-29x29@1x.png", "size": (29, 29)},
        {"name": "Icon-App-29x29@2x.png", "size": (58, 58)},
        {"name": "Icon-App-29x29@3x.png", "size": (87, 87)},
        {"name": "Icon-App-40x40@1x.png", "size": (40, 40)},
        {"name": "Icon-App-40x40@2x.png", "size": (80, 80)},
        {"name": "Icon-App-40x40@3x.png", "size": (120, 120)},
        {"name": "Icon-App-60x60@2x.png", "size": (120, 120)},
        {"name": "Icon-App-60x60@3x.png", "size": (180, 180)},
        {"name": "Icon-App-76x76@1x.png", "size": (76, 76)},
        {"name": "Icon-App-76x76@2x.png", "size": (152, 152)},
        {"name": "Icon-App-83.5x83.5@2x.png", "size": (167, 167)},
        {"name": "Icon-App-1024x1024@1x.png", "size": (1024, 1024)}
    ]
}

class AIImageGenerator:
    def __init__(self, api_key=None):
        self.api_key = api_key or os.getenv('OPENAI_API_KEY')
        if self.api_key:
            openai.api_key = self.api_key
        
        self.project_root = Path(CONFIG["project_root"])
        self.output_dir = self.project_root / CONFIG["output_dir"]
        self.output_dir.mkdir(exist_ok=True)
        
    def generate_image_dalle(self, prompt, filename, size="1024x1024"):
        """DALL-E 3で画像生成"""
        try:
            print(f"🎨 Generating image: {filename}")
            print(f"📝 Prompt: {prompt[:100]}...")
            
            response = openai.Image.create(
                model="dall-e-3",
                prompt=prompt,
                size=size,
                quality="hd",
                n=1
            )
            
            image_url = response.data[0].url
            return self.download_image(image_url, filename)
            
        except Exception as e:
            print(f"❌ DALL-E generation failed: {e}")
            return None
    
    def download_image(self, url, filename):
        """画像URLからダウンロード"""
        try:
            response = requests.get(url, timeout=30)
            response.raise_for_status()
            
            img_path = self.output_dir / filename
            with open(img_path, 'wb') as f:
                f.write(response.content)
            
            print(f"✅ Downloaded: {img_path}")
            return str(img_path)
            
        except Exception as e:
            print(f"❌ Download failed: {e}")
            return None
    
    def resize_image(self, source_path, target_path, size):
        """画像リサイズ"""
        try:
            with Image.open(source_path) as img:
                img = img.convert('RGBA')
                img = img.resize(size, Image.Resampling.LANCZOS)
                
                # 透明度を削除（App Store要件）
                if size == (1024, 1024):
                    background = Image.new('RGB', size, (255, 255, 255))
                    background.paste(img, mask=img.split()[-1] if img.mode == 'RGBA' else None)
                    img = background
                
                img.save(target_path, 'PNG', quality=95)
                print(f"✅ Resized: {target_path} ({size[0]}x{size[1]})")
                return True
                
        except Exception as e:
            print(f"❌ Resize failed: {e}")
            return False
    
    def generate_app_icon(self, method="dalle"):
        """アプリアイコン生成"""
        print("🔑 Generating App Icon...")
        
        prompt = CONFIG["prompts"]["app_icon"]
        master_filename = "app_icon_master.png"
        
        # マスター画像生成
        master_path = self.generate_image_dalle(prompt, master_filename)
        
        if not master_path:
            return False
        
        # 全サイズ生成
        icon_dir = self.project_root / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
        success_count = 0
        
        for icon_config in CONFIG["icon_sizes"]:
            target_path = icon_dir / icon_config["name"]
            if self.resize_image(master_path, target_path, icon_config["size"]):
                success_count += 1
        
        print(f"✅ App Icon: {success_count}/{len(CONFIG['icon_sizes'])} sizes generated")
        return success_count == len(CONFIG["icon_sizes"])

def main():
    """メイン実行関数"""
    print("🚀 AI Image Generation System")
    print("=" * 50)
    
    # 環境確認
    if not os.getenv('OPENAI_API_KEY'):
        print("❌ Missing OPENAI_API_KEY")
        print("   export OPENAI_API_KEY=your_api_key_here")
        return False
    
    # ジェネレータ初期化
    generator = AIImageGenerator()
    
    # アイコン生成実行
    success = generator.generate_app_icon()
    
    if success:
        print("\n🎉 Generation completed successfully!")
    else:
        print("\n⚠️ Generation failed. Check errors above.")
    
    return success

if __name__ == "__main__":
    main()