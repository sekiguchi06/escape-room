#!/usr/bin/env python3
"""
文字列多言語化移行支援ツール

このスクリプトは、Flutterプロジェクトのハードコードされた文字列を
ARBファイルベースの多言語化システムに移行するためのツールです。

使用方法:
    python3 tools/string_migration.py --scan           # 文字列をスキャン
    python3 tools/string_migration.py --extract        # ARB候補を生成
    python3 tools/string_migration.py --validate       # 移行状況チェック
"""

import re
import os
import json
import argparse
from typing import List, Dict, Set, Tuple
from pathlib import Path

class StringMigrationTool:
    def __init__(self, project_root: str):
        self.project_root = Path(project_root)
        self.lib_dir = self.project_root / "lib"
        self.l10n_dir = self.project_root / "lib" / "l10n"
        self.arb_en = self.l10n_dir / "app_en.arb"
        self.arb_ja = self.l10n_dir / "app_ja.arb"
        
        # 日本語文字の正規表現
        self.japanese_pattern = re.compile(r'[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF\u3000-\u303F]')
        
        # 文字列リテラルの正規表現
        self.string_patterns = [
            re.compile(r"'([^'\\\\]*(\\\\.[^'\\\\]*)*)'"),  # シングルクォート
            re.compile(r'"([^"\\\\]*(\\\\.[^"\\\\]*)*)"'),  # ダブルクォート
        ]
        
        # 除外するパターン
        self.exclude_patterns = [
            r'import\s+',
            r'part\s+',
            r'//.*',
            r'/\*.*\*/',
            r'print\s*\(',
            r'debugPrint\s*\(',
            r'assert\s*\(',
            r'throw\s+',
        ]
        
        # 除外する文字列
        self.exclude_strings = {
            '', ' ', '\n', '\t', '\r',
            'lib/', 'assets/', 'images/', 'sounds/',
            'http', 'https', 'www', '.com', '.jp',
            'TODO', 'FIXME', 'DEBUG', 'ERROR',
        }
    
    def scan_hardcoded_strings(self) -> Dict[str, List[Dict]]:
        """
        ハードコードされた文字列をスキャンする
        """
        print("🔍 Scanning hardcoded strings...")
        results = {}
        
        for dart_file in self.lib_dir.rglob("*.dart"):
            strings = self._extract_strings_from_file(dart_file)
            if strings:
                results[str(dart_file.relative_to(self.project_root))] = strings
        
        return results
    
    def _extract_strings_from_file(self, file_path: Path) -> List[Dict]:
        """
        ファイルから文字列を抽出する
        """
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
        except Exception as e:
            print(f"❌ Error reading {file_path}: {e}")
            return []
        
        strings = []
        lines = content.split('\n')
        
        for line_num, line in enumerate(lines, 1):
            # 除外パターンをチェック
            if any(re.search(pattern, line) for pattern in self.exclude_patterns):
                continue
            
            # 文字列リテラルを抽出
            for pattern in self.string_patterns:
                for match in pattern.finditer(line):
                    string_content = match.group(1)
                    
                    # 除外文字列をスキップ
                    if string_content in self.exclude_strings:
                        continue
                    
                    # 空白のみをスキップ
                    if not string_content.strip():
                        continue
                    
                    # 技術的な文字列をスキップ
                    if self._is_technical_string(string_content):
                        continue
                    
                    string_info = {
                        'content': string_content,
                        'line': line_num,
                        'column': match.start() + 1,
                        'context': line.strip(),
                        'has_japanese': bool(self.japanese_pattern.search(string_content)),
                        'is_ui_text': self._is_likely_ui_text(string_content, line),
                        'suggested_key': self._suggest_key_name(string_content),
                    }
                    strings.append(string_info)
        
        return strings
    
    def _is_technical_string(self, string_content: str) -> bool:
        """
        技術的な文字列かどうかを判定
        """
        technical_indicators = [
            '/', '\\\\', ':', '.', '_test', '_debug',
            'localhost', '127.0.0.1', 'firebase',
            'ca-app-pub-', 'google.com', 'android',
        ]
        
        lower_content = string_content.lower()
        return any(indicator in lower_content for indicator in technical_indicators)
    
    def _is_likely_ui_text(self, string_content: str, line_context: str) -> bool:
        """
        UI テキストである可能性が高いかを判定
        """
        ui_indicators = [
            'Text(', 'title:', 'subtitle:', 'label:', 'hint:',
            'AppBar', 'AlertDialog', 'SnackBar', 'tooltip:',
            'ElevatedButton', 'TextButton', 'IconButton',
        ]
        
        return any(indicator in line_context for indicator in ui_indicators)
    
    def _suggest_key_name(self, string_content: str) -> str:
        """
        文字列からキー名を提案
        """
        # 日本語から英語への簡単なマッピング
        key_mappings = {
            'はじめる': 'buttonStart',
            'つづきから': 'buttonContinue',
            'あそびかた': 'buttonHowToPlay',
            '設定': 'settings',
            '閉じる': 'buttonClose',
            'キャンセル': 'buttonCancel',
            '確認': 'buttonConfirm',
            '戻る': 'back',
            'エラー': 'error',
            '成功': 'success',
        }
        
        if string_content in key_mappings:
            return key_mappings[string_content]
        
        # 一般的なパターンから推測
        content_lower = string_content.lower()
        
        # ボタン系
        if any(word in content_lower for word in ['button', 'click', 'tap']):
            return f"button{string_content.replace(' ', '').title()}"
        
        # エラー系
        if any(word in content_lower for word in ['error', 'failed', 'エラー']):
            return f"error{string_content[:10].replace(' ', '').title()}"
        
        # メッセージ系
        if any(word in content_lower for word in ['message', 'msg']):
            return f"message{string_content[:10].replace(' ', '').title()}"
        
        # デフォルト
        clean_content = re.sub(r'[^\w\s]', '', string_content)[:20]
        return f"text{clean_content.replace(' ', '').title()}"
    
    def generate_arb_candidates(self, scan_results: Dict[str, List[Dict]]) -> Dict[str, Dict]:
        """
        スキャン結果からARB候補を生成
        """
        print("📝 Generating ARB candidates...")
        
        en_candidates = {}
        ja_candidates = {}
        
        # 既存のARBファイルを読み込み
        existing_en = self._load_arb_file(self.arb_en) if self.arb_en.exists() else {}
        existing_ja = self._load_arb_file(self.arb_ja) if self.arb_ja.exists() else {}
        
        # 優先度付きで処理
        all_strings = []
        for file_path, strings in scan_results.items():
            for string_info in strings:
                all_strings.append((file_path, string_info))
        
        # UI テキストを優先してソート
        all_strings.sort(key=lambda x: (
            not x[1]['is_ui_text'],  # UI テキストを先に
            not x[1]['has_japanese'],  # 日本語文字列を先に
            x[1]['content']
        ))
        
        processed_contents = set()
        for file_path, string_info in all_strings:
            content = string_info['content']
            
            # 重複除去
            if content in processed_contents:
                continue
            processed_contents.add(content)
            
            # 既に ARB ファイルに存在するかチェック
            suggested_key = string_info['suggested_key']
            if suggested_key in existing_en:
                continue
            
            # メタデータ付きで ARB エントリを生成
            description = self._generate_description(content, string_info)
            
            en_candidates[suggested_key] = content if not string_info['has_japanese'] else "[TRANSLATION_NEEDED]"
            en_candidates[f"@{suggested_key}"] = {
                "description": description,
                "source_file": file_path,
                "source_line": string_info['line']
            }
            
            if string_info['has_japanese']:
                ja_candidates[suggested_key] = content
        
        return {
            'en': en_candidates,
            'ja': ja_candidates
        }
    
    def _load_arb_file(self, file_path: Path) -> Dict:
        """
        ARBファイルを読み込み
        """
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                return json.load(f)
        except Exception as e:
            print(f"❌ Error loading {file_path}: {e}")
            return {}
    
    def _generate_description(self, content: str, string_info: Dict) -> str:
        """
        文字列の説明を生成
        """
        if string_info['is_ui_text']:
            if 'button' in string_info['suggested_key'].lower():
                return f"Button label: {content}"
            elif 'error' in string_info['suggested_key'].lower():
                return f"Error message: {content}"
            elif 'title' in string_info['suggested_key'].lower():
                return f"Title text: {content}"
            else:
                return f"UI text: {content}"
        else:
            return f"Text content: {content}"
    
    def validate_migration_status(self) -> Dict:
        """
        移行状況を検証
        """
        print("✅ Validating migration status...")
        
        # ARB ファイルの状況
        arb_status = self._validate_arb_files()
        
        # AppLocalizations の使用状況
        usage_status = self._validate_localization_usage()
        
        # 残存するハードコード文字列
        remaining_strings = self.scan_hardcoded_strings()
        
        return {
            'arb_files': arb_status,
            'localization_usage': usage_status,
            'remaining_hardcoded': remaining_strings,
            'migration_progress': self._calculate_migration_progress(remaining_strings)
        }
    
    def _validate_arb_files(self) -> Dict:
        """
        ARB ファイルの妥当性を検証
        """
        status = {'en': {}, 'ja': {}}
        
        for lang, file_path in [('en', self.arb_en), ('ja', self.arb_ja)]:
            if not file_path.exists():
                status[lang]['exists'] = False
                continue
            
            status[lang]['exists'] = True
            arb_data = self._load_arb_file(file_path)
            
            # 文字列エントリの数（メタデータ除外）
            string_keys = [k for k in arb_data.keys() if not k.startswith('@') and not k.startswith('@@')]
            status[lang]['string_count'] = len(string_keys)
            
            # メタデータの完整性（英語のみ）
            if lang == 'en':
                missing_metadata = []
                for key in string_keys:
                    if f"@{key}" not in arb_data:
                        missing_metadata.append(key)
                status[lang]['missing_metadata'] = missing_metadata
        
        return status
    
    def _validate_localization_usage(self) -> Dict:
        """
        AppLocalizations の使用状況を検証
        """
        usage_count = 0
        files_with_usage = []
        
        for dart_file in self.lib_dir.rglob("*.dart"):
            try:
                with open(dart_file, 'r', encoding='utf-8') as f:
                    content = f.read()
                    
                if 'AppLocalizations.of(context)' in content:
                    usage_count += len(re.findall(r'AppLocalizations\.of\(context\)', content))
                    files_with_usage.append(str(dart_file.relative_to(self.project_root)))
            except Exception:
                continue
        
        return {
            'total_usage_count': usage_count,
            'files_count': len(files_with_usage),
            'files_with_usage': files_with_usage
        }
    
    def _calculate_migration_progress(self, remaining_strings: Dict) -> Dict:
        """
        移行進捗を計算
        """
        total_files = len(list(self.lib_dir.rglob("*.dart")))
        files_with_hardcoded = len(remaining_strings)
        
        total_hardcoded = sum(len(strings) for strings in remaining_strings.values())
        ui_text_count = sum(
            sum(1 for s in strings if s['is_ui_text']) 
            for strings in remaining_strings.values()
        )
        
        return {
            'total_dart_files': total_files,
            'files_with_hardcoded': files_with_hardcoded,
            'total_hardcoded_strings': total_hardcoded,
            'ui_text_remaining': ui_text_count,
            'migration_percentage': max(0, 100 - (files_with_hardcoded / total_files * 100)),
        }
    
    def export_results(self, data: Dict, output_file: str):
        """
        結果をファイルに出力
        """
        output_path = self.project_root / output_file
        
        try:
            with open(output_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
            print(f"✅ Results exported to: {output_path}")
        except Exception as e:
            print(f"❌ Error exporting results: {e}")
    
    def print_summary(self, data: Dict):
        """
        結果のサマリーを表示
        """
        if 'migration_progress' in data:
            # 検証結果のサマリー
            progress = data['migration_progress']
            print(f"\n📊 Migration Progress Summary:")
            print(f"  Total Dart files: {progress['total_dart_files']}")
            print(f"  Files with hardcoded strings: {progress['files_with_hardcoded']}")
            print(f"  Total hardcoded strings: {progress['total_hardcoded_strings']}")
            print(f"  UI text remaining: {progress['ui_text_remaining']}")
            print(f"  Migration progress: {progress['migration_percentage']:.1f}%")
            
            arb = data['arb_files']
            print(f"\n📚 ARB Files Status:")
            print(f"  English strings: {arb['en'].get('string_count', 0)}")
            print(f"  Japanese strings: {arb['ja'].get('string_count', 0)}")
            print(f"  Missing metadata: {len(arb['en'].get('missing_metadata', []))}")
        
        elif 'en' in data:
            # ARB 候補のサマリー
            print(f"\n📝 ARB Candidates Generated:")
            print(f"  English entries: {len([k for k in data['en'].keys() if not k.startswith('@')])}")
            print(f"  Japanese entries: {len(data['ja'].keys())}")
        
        else:
            # スキャン結果のサマリー
            total_strings = sum(len(strings) for strings in data.values())
            ui_strings = sum(
                sum(1 for s in strings if s['is_ui_text']) 
                for strings in data.values()
            )
            japanese_strings = sum(
                sum(1 for s in strings if s['has_japanese']) 
                for strings in data.values()
            )
            
            print(f"\n🔍 Scan Results Summary:")
            print(f"  Files with hardcoded strings: {len(data)}")
            print(f"  Total hardcoded strings: {total_strings}")
            print(f"  UI text strings: {ui_strings}")
            print(f"  Japanese strings: {japanese_strings}")


def main():
    parser = argparse.ArgumentParser(description="String migration tool for Flutter i18n")
    parser.add_argument('--scan', action='store_true', help='Scan for hardcoded strings')
    parser.add_argument('--extract', action='store_true', help='Extract ARB candidates')
    parser.add_argument('--validate', action='store_true', help='Validate migration status')
    parser.add_argument('--project-root', default='.', help='Project root directory')
    parser.add_argument('--output', help='Output file for results')
    
    args = parser.parse_args()
    
    # プロジェクトルートを escape_room に設定
    if args.project_root == '.':
        current_dir = Path.cwd()
        if current_dir.name == 'escape_room':
            project_root = str(current_dir)
        else:
            project_root = str(current_dir / 'escape_room')
    else:
        project_root = args.project_root
    
    tool = StringMigrationTool(project_root)
    
    if args.scan:
        results = tool.scan_hardcoded_strings()
        tool.print_summary(results)
        if args.output:
            tool.export_results(results, args.output)
    
    elif args.extract:
        # まずスキャンしてから ARB 候補を生成
        scan_results = tool.scan_hardcoded_strings()
        arb_candidates = tool.generate_arb_candidates(scan_results)
        tool.print_summary(arb_candidates)
        if args.output:
            tool.export_results(arb_candidates, args.output)
    
    elif args.validate:
        status = tool.validate_migration_status()
        tool.print_summary(status)
        if args.output:
            tool.export_results(status, args.output)
    
    else:
        parser.print_help()


if __name__ == "__main__":
    main()