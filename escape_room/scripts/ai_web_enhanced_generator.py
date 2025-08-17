#!/usr/bin/env python3
"""
Enhanced AI Asset Generator with Web Information Integration
WebFetch制限を考慮した実用的な画像生成自動化システム
"""

import os
import sys
import json
import requests
import subprocess
from pathlib import Path
from PIL import Image

# 設定 - WebFetch情報を基に更新
CONFIG = {
    "project_root": "/Users/sekiguchi/git/proto/casual_game_template",
    "output_dir": "generated_assets",
    
    # サービス優先順位 (利用可能性に基づく)
    "services": {
        "openai": {
            "available": True,
            "api_key_env": "OPENAI_API_KEY",
            "cost_per_image": 0.04,  # $0.04 for DALL-E 3 standard
            "quality": "high",
            "setup_complexity": "low"
        },
        "stability": {
            "available": True,
            "api_key_env": "STABILITY_API_KEY", 
            "cost_per_image": 0.02,  # Stability AI cheaper
            "quality": "high",
            "setup_complexity": "medium"
        },
        "firefly": {
            "available": False,  # API制限により自動化困難
            "api_key_env": "ADOBE_API_KEY",
            "cost_per_image": 0.0,  # 無料クレジット有り
            "quality": "high",
            "setup_complexity": "high"
        }
    },
    
    # プロンプト改良版 (Fireflyガイドから取得した情報を反映)
    "prompts": {
        "app_icon": """
        Create a professional mobile app icon for an escape room puzzle game called "Escape Master".
        Style: Flat design, anime-inspired, kawaii aesthetic, no gradients or shadows
        Central element: Adorable cartoon key character with cute eyes and smile
        Background: Soft pastel blue (#7EC8E3) with subtle sparkles
        Additional elements: Simple door silhouette, star decorations
        Colors: Pastel yellow key (#FFE066), soft pink accents (#FFB3E6), cream base (#FFF8DC)
        Technical: 1024x1024 resolution, vector art style, clean lines, child-friendly design
        Avoid: Text, existing characters, complex details, realistic shadows
        """,
        
        "screenshot_menu": """
        Mobile game menu screen for cute escape room puzzle game "Escape Master".
        Layout: Title at top in playful font, centered play button, settings icon
        Style: Flat design, pastel colors, anime/kawaii aesthetic
        Background: Soft gradient from light blue to cream with floating sparkles
        UI elements: Rounded buttons with soft shadows, cute icons
        Colors: Matching app icon palette - blues, yellows, pinks
        Mood: Welcoming, friendly, suitable for all ages
        Technical: Mobile portrait orientation, clean UI design
        """,
        
        "screenshot_gameplay": """
        Gameplay screen for cute escape room puzzle game showing active play.
        Scene: Cartoon-style room with kawaii furniture and decorations
        Items: Adorable key objects, cute locks, friendly furniture with faces
        UI: Bottom inventory bar with collected items, hint button
        Style: Flat design with subtle depth, pastel color scheme
        Lighting: Soft, even lighting with no harsh shadows
        Details: Interactive objects highlighted with soft glow
        Mood: Puzzling but non-threatening, suitable for children
        Technical: Mobile game interface, clear readability
        """,
        
        "screenshot_victory": """
        Victory/success screen for cute escape room puzzle game.
        Central: Cute key character celebrating with arms raised
        Effects: Colorful confetti, sparkles, stars radiating outward
        Text area: Space for "Congratulations!" message
        Background: Bright, cheerful gradient with celebration theme
        Style: Kawaii anime aesthetic, flat design with subtle animation feel
        Colors: Bright but soft pastels, gold accents for achievement feeling
        Mood: Joyful, rewarding, encouraging for players
        Elements: Trophy or medal icons, level completion indicators
        """
    },
    
    # iOSアイコンサイズ (Apple公式要件)
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
    ],
    
    # スクリーンショットサイズ (App Store要件)
    "screenshot_sizes": {
        "iphone_6_5": {"width": 1284, "height": 2778, "name": "iPhone 6.5\""},
        "iphone_5_5": {"width": 1242, "height": 2208, "name": "iPhone 5.5\""},
        "ipad_12_9": {"width": 2048, "height": 2732, "name": "iPad 12.9\""}
    }
}

class EnhancedAIGenerator:
    def __init__(self):
        self.project_root = Path(CONFIG["project_root"])
        self.output_dir = self.project_root / CONFIG["output_dir"]
        self.output_dir.mkdir(exist_ok=True)
        
        # 利用可能なサービスを自動検出
        self.available_service = self.detect_available_service()
        
    def detect_available_service(self):
        """利用可能なサービスを自動検出"""
        print("🔍 Detecting available AI services...")
        
        for service_name, config in CONFIG["services"].items():
            if config["available"]:
                api_key = os.getenv(config["api_key_env"])
                if api_key:
                    print(f"✅ {service_name.upper()}: Available")
                    return service_name
                else:
                    print(f"❌ {service_name.upper()}: Missing API key ({config['api_key_env']})")
        
        print("⚠️ No AI service available. Please set API keys.")
        return None
    
    def generate_with_openai(self, prompt, filename, size="1024x1024"):
        """OpenAI DALL-E 3 で画像生成"""
        try:
            import openai
            openai.api_key = os.getenv('OPENAI_API_KEY')
            
            print(f"🎨 Generating with DALL-E 3: {filename}")
            
            response = openai.Image.create(
                model="dall-e-3",
                prompt=prompt,
                size=size,
                quality="hd",
                style="vivid",
                n=1
            )
            
            image_url = response.data[0].url
            return self.download_image(image_url, filename)
            
        except Exception as e:
            print(f"❌ DALL-E generation failed: {e}")
            return None
    
    def generate_with_stability(self, prompt, filename):
        """Stability AI で画像生成"""
        try:
            api_key = os.getenv('STABILITY_API_KEY')
            if not api_key:
                print("❌ STABILITY_API_KEY not found")
                return None
            
            print(f"🎨 Generating with Stability AI: {filename}")
            
            url = "https://api.stability.ai/v1/generation/stable-diffusion-xl-1024-v1-0/text-to-image"
            
            body = {
                "steps": 40,
                "width": 1024,
                "height": 1024,
                "seed": 0,
                "cfg_scale": 5,
                "samples": 1,
                "text_prompts": [
                    {
                        "text": prompt,
                        "weight": 1
                    }
                ],
            }
            
            headers = {
                "Accept": "application/json",
                "Content-Type": "application/json",
                "Authorization": f"Bearer {api_key}",
            }
            
            response = requests.post(url, headers=headers, json=body)
            
            if response.status_code == 200:
                data = response.json()
                
                for i, image in enumerate(data["artifacts"]):
                    import base64
                    img_data = base64.b64decode(image["base64"])
                    
                    img_path = self.output_dir / filename
                    with open(img_path, "wb") as f:
                        f.write(img_data)
                    
                    print(f"✅ Generated: {img_path}")
                    return str(img_path)
            else:
                print(f"❌ Stability API error: {response.status_code}")
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
        """画像リサイズ（品質最適化）"""
        try:
            with Image.open(source_path) as img:
                # RGBA変換 (透明度対応)
                if img.mode != 'RGBA':
                    img = img.convert('RGBA')
                
                # 高品質リサイズ
                img = img.resize(size, Image.Resampling.LANCZOS)
                
                # App Store要件：1024x1024は透明度除去
                if size == (1024, 1024):
                    background = Image.new('RGB', size, (255, 255, 255))
                    if img.mode == 'RGBA':
                        background.paste(img, mask=img.split()[-1])
                    else:
                        background.paste(img)
                    img = background
                
                # 最適化保存
                img.save(target_path, 'PNG', optimize=True, quality=95)
                print(f"✅ Resized: {target_path.name} ({size[0]}x{size[1]})")
                return True
                
        except Exception as e:
            print(f"❌ Resize failed: {e}")
            return False
    
    def generate_app_icon_complete(self):
        """完全自動アプリアイコン生成"""
        print("🔑 Starting complete app icon generation...")
        
        if not self.available_service:
            print("❌ No AI service available")
            return False
        
        prompt = CONFIG["prompts"]["app_icon"]
        master_filename = "app_icon_master.png"
        
        # マスター画像生成
        if self.available_service == "openai":
            master_path = self.generate_with_openai(prompt, master_filename)
        elif self.available_service == "stability":
            master_path = self.generate_with_stability(prompt, master_filename)
        else:
            print(f"❌ Unknown service: {self.available_service}")
            return False
        
        if not master_path:
            print("❌ Master icon generation failed")
            return False
        
        # 全サイズ自動生成
        icon_dir = self.project_root / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
        success_count = 0
        
        print(f"📐 Generating {len(CONFIG['icon_sizes'])} icon sizes...")
        
        for icon_config in CONFIG["icon_sizes"]:
            target_path = icon_dir / icon_config["name"]
            if self.resize_image(master_path, target_path, icon_config["size"]):
                success_count += 1
        
        print(f"✅ App Icon Complete: {success_count}/{len(CONFIG['icon_sizes'])} sizes")
        return success_count == len(CONFIG["icon_sizes"])
    
    def generate_screenshots_complete(self):
        """完全自動スクリーンショット生成"""
        print("📸 Starting complete screenshot generation...")
        
        if not self.available_service:
            print("❌ No AI service available")
            return False
        
        screenshot_dir = self.output_dir / "screenshots"
        screenshot_dir.mkdir(exist_ok=True)
        
        screenshots = {
            "menu": CONFIG["prompts"]["screenshot_menu"],
            "gameplay": CONFIG["prompts"]["screenshot_gameplay"],
            "victory": CONFIG["prompts"]["screenshot_victory"]
        }
        
        generated_count = 0
        
        for name, prompt in screenshots.items():
            print(f"🎨 Generating {name} screenshot...")
            
            # マスター画像生成 (1024x1024 -> 各デバイスサイズに変換)
            master_filename = f"screenshot_{name}_master.png"
            
            if self.available_service == "openai":
                master_path = self.generate_with_openai(prompt, master_filename)
            elif self.available_service == "stability":
                master_path = self.generate_with_stability(prompt, master_filename)
            
            if master_path:
                # 各デバイスサイズに変換
                for device, size_config in CONFIG["screenshot_sizes"].items():
                    device_filename = f"screenshot_{name}_{device}.png"
                    device_path = screenshot_dir / device_filename
                    
                    target_size = (size_config["width"], size_config["height"])
                    if self.resize_image(master_path, device_path, target_size):
                        generated_count += 1
        
        total_expected = len(screenshots) * len(CONFIG["screenshot_sizes"])
        print(f"✅ Screenshots Complete: {generated_count}/{total_expected} files")
        
        return generated_count > 0
    
    def run_quality_check(self):
        """完全品質チェック"""
        print("🔍 Running comprehensive quality check...")
        
        checks = []
        
        # アイコンチェック
        icon_dir = self.project_root / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
        icon_issues = 0
        
        for icon_config in CONFIG["icon_sizes"]:
            icon_path = icon_dir / icon_config["name"]
            if icon_path.exists():
                try:
                    with Image.open(icon_path) as img:
                        if img.size == icon_config["size"]:
                            checks.append(f"✅ {icon_config['name']}: Perfect")
                        else:
                            checks.append(f"⚠️ {icon_config['name']}: Size mismatch")
                            icon_issues += 1
                except Exception as e:
                    checks.append(f"❌ {icon_config['name']}: Corrupted")
                    icon_issues += 1
            else:
                checks.append(f"❌ {icon_config['name']}: Missing")
                icon_issues += 1
        
        # スクリーンショットチェック
        screenshot_dir = self.output_dir / "screenshots"
        screenshot_count = 0
        if screenshot_dir.exists():
            screenshots = list(screenshot_dir.glob("*.png"))
            screenshot_count = len(screenshots)
            checks.append(f"✅ Screenshots: {screenshot_count} files generated")
        
        # サマリー
        print("\n" + "="*50)
        print("📊 QUALITY CHECK RESULTS")
        print("="*50)
        
        for check in checks[:5]:  # 最初の5件表示
            print(check)
        
        if len(checks) > 5:
            print(f"... and {len(checks) - 5} more checks")
        
        print(f"\n🎯 Summary:")
        print(f"   Icons: {len(CONFIG['icon_sizes']) - icon_issues}/{len(CONFIG['icon_sizes'])} perfect")
        print(f"   Screenshots: {screenshot_count} generated")
        print(f"   Overall: {'PASS' if icon_issues == 0 and screenshot_count > 0 else 'NEEDS ATTENTION'}")
        
        return icon_issues == 0 and screenshot_count > 0

def main():
    """メイン実行"""
    print("🚀 Enhanced AI Asset Generation System")
    print("=" * 60)
    
    generator = EnhancedAIGenerator()
    
    if not generator.available_service:
        print("\n💡 Setup Instructions:")
        print("   1. Get OpenAI API key: https://platform.openai.com/api-keys")
        print("   2. Set environment variable: export OPENAI_API_KEY='your-key'")
        print("   3. Alternative: Stability AI: export STABILITY_API_KEY='your-key'")
        return False
    
    # 実行モード選択
    mode = "all"  # デフォルト
    if len(sys.argv) > 1:
        mode = sys.argv[1]
    
    print(f"🔧 Using: {generator.available_service.upper()}")
    print(f"🎯 Mode: {mode}")
    print("")
    
    success = True
    
    # アイコン生成
    if mode in ["icon", "all"]:
        success &= generator.generate_app_icon_complete()
        print("")
    
    # スクリーンショット生成
    if mode in ["screenshots", "all"]:
        success &= generator.generate_screenshots_complete()
        print("")
    
    # 品質チェック
    generator.run_quality_check()
    
    if success:
        print("\n🎉 GENERATION COMPLETED SUCCESSFULLY!")
        print("📁 Generated files:")
        print("   - App Icons: ios/Runner/Assets.xcassets/AppIcon.appiconset/")
        print("   - Screenshots: generated_assets/screenshots/")
    else:
        print("\n⚠️ SOME OPERATIONS FAILED")
        print("Check error messages above and try again.")
    
    return success

if __name__ == "__main__":
    main()