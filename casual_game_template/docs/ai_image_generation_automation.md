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
    
    def generate_image_stability(self, prompt, filename):
        """Stability AI で画像生成"""
        try:
            import stability_sdk.interfaces.gooseai.generation.generation_pb2 as generation
            from stability_sdk import client
            
            api_key = os.getenv('STABILITY_API_KEY')
            if not api_key:
                print("❌ STABILITY_API_KEY not found")
                return None
                
            stability_api = client.StabilityInference(
                key=api_key,
                verbose=True,
            )
            
            print(f"🎨 Generating with Stability AI: {filename}")
            
            answers = stability_api.generate(
                prompt=prompt,
                seed=992446758,
                steps=30,
                cfg_scale=8.0,
                width=1024,
                height=1024,
                samples=1,
            )
            
            for resp in answers:
                for artifact in resp.artifacts:
                    if artifact.finish_reason == generation.FILTER:
                        print("❌ Content filtered by safety system")
                        return None
                    if artifact.type == generation.ARTIFACT_IMAGE:
                        img_path = self.output_dir / filename
                        with open(img_path, "wb") as f:
                            f.write(artifact.binary)
                        print(f"✅ Generated: {img_path}")
                        return str(img_path)
                        
        except ImportError:
            print("❌ stability-sdk not installed. Install with: pip install stability-sdk")
            return None
        except Exception as e:
            print(f"❌ Stability AI generation failed: {e}")
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
                # アスペクト比を保持してリサイズ
                img = img.convert('RGBA')
                img = img.resize(size, Image.Resampling.LANCZOS)
                
                # 透明度を削除（App Store要件）
                if size == (1024, 1024):  # マスターアイコンのみ
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
        if method == "dalle":
            master_path = self.generate_image_dalle(prompt, master_filename)
        elif method == "stability":
            master_path = self.generate_image_stability(prompt, master_filename)
        else:
            print(f"❌ Unknown method: {method}")
            return False
        
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
    
    def generate_screenshots(self, method="dalle"):
        """スクリーンショット生成"""
        print("📸 Generating Screenshots...")
        
        screenshots = {
            "menu": CONFIG["prompts"]["screenshot_menu"],
            "gameplay": CONFIG["prompts"]["screenshot_gameplay"], 
            "success": CONFIG["prompts"]["screenshot_success"]
        }
        
        screenshot_dir = self.output_dir / "screenshots"
        screenshot_dir.mkdir(exist_ok=True)
        
        results = {}
        
        for name, prompt in screenshots.items():
            filename = f"screenshot_{name}.png"
            
            if method == "dalle":
                path = self.generate_image_dalle(prompt, filename, size="1792x1024")
            elif method == "stability":
                path = self.generate_image_stability(prompt, filename)
            else:
                continue
                
            if path:
                results[name] = path
                # iPhone用にリサイズ
                self.create_device_screenshots(path, name)
        
        print(f"✅ Screenshots: {len(results)}/3 generated")
        return results
    
    def create_device_screenshots(self, source_path, name):
        """デバイス別スクリーンショット作成"""
        device_sizes = {
            "iphone_6_5": (1284, 2778),  # iPhone 12 Pro Max
            "iphone_5_5": (1242, 2208),  # iPhone 6s Plus
            "ipad_12_9": (2048, 2732)    # iPad Pro 12.9"
        }
        
        for device, size in device_sizes.items():
            target_path = self.output_dir / "screenshots" / f"{name}_{device}.png"
            self.resize_image(source_path, target_path, size)
    
    def run_quality_check(self):
        """品質確認"""
        print("🔍 Running quality check...")
        
        checks = []
        
        # アイコンチェック
        icon_dir = self.project_root / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
        for icon_config in CONFIG["icon_sizes"]:
            icon_path = icon_dir / icon_config["name"]
            if icon_path.exists():
                with Image.open(icon_path) as img:
                    if img.size == icon_config["size"]:
                        checks.append(f"✅ {icon_config['name']}: OK")
                    else:
                        checks.append(f"❌ {icon_config['name']}: Size mismatch")
            else:
                checks.append(f"❌ {icon_config['name']}: Missing")
        
        # スクリーンショットチェック
        screenshot_dir = self.output_dir / "screenshots"
        if screenshot_dir.exists():
            screenshots = list(screenshot_dir.glob("*.png"))
            checks.append(f"✅ Screenshots: {len(screenshots)} files")
        
        for check in checks:
            print(check)
        
        return checks

def main():
    """メイン実行関数"""
    print("🚀 AI Image Generation System")
    print("=" * 50)
    
    # 環境確認
    required_keys = ['OPENAI_API_KEY']  # または 'STABILITY_API_KEY'
    missing_keys = [key for key in required_keys if not os.getenv(key)]
    
    if missing_keys:
        print("❌ Missing API keys:")
        for key in missing_keys:
            print(f"   export {key}=your_api_key_here")
        print("\n📋 Supported services:")
        print("   - OpenAI DALL-E 3: OPENAI_API_KEY")
        print("   - Stability AI: STABILITY_API_KEY")
        return False
    
    # ジェネレータ初期化
    generator = AIImageGenerator()
    
    # メニュー
    if len(sys.argv) > 1:
        mode = sys.argv[1]
    else:
        print("🎯 Select generation mode:")
        print("1. App Icon only")
        print("2. Screenshots only") 
        print("3. All assets")
        choice = input("Enter choice (1-3): ").strip()
        
        mode_map = {"1": "icon", "2": "screenshots", "3": "all"}
        mode = mode_map.get(choice, "all")
    
    # 生成方法選択
    method = "dalle"  # デフォルト
    if os.getenv('STABILITY_API_KEY') and not os.getenv('OPENAI_API_KEY'):
        method = "stability"
    
    print(f"🔧 Using method: {method}")
    
    # 実行
    success = True
    
    if mode in ["icon", "all"]:
        success &= generator.generate_app_icon(method)
    
    if mode in ["screenshots", "all"]:
        generator.generate_screenshots(method)
    
    # 品質確認
    generator.run_quality_check()
    
    if success:
        print("\n🎉 Generation completed successfully!")
        print("📁 Check generated files:")
        print(f"   - Icons: ios/Runner/Assets.xcassets/AppIcon.appiconset/")
        print(f"   - Screenshots: {generator.output_dir}/screenshots/")
    else:
        print("\n⚠️ Some generation failed. Check errors above.")
    
    return success

if __name__ == "__main__":
    main()