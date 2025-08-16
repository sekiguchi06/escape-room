import 'package:flutter_test/flutter_test.dart';
import 'dart:io';

void main() {
  group('Environment Configuration Tests', () {
    test('should have configuration files in place', () {
      // .envファイルが存在することを確認
      final envFile = File('.env');
      expect(envFile.existsSync(), isTrue);
      
      // 設定ファイルに必要な環境変数が含まれていることを確認
      final envContent = envFile.readAsStringSync();
      expect(envContent, contains('API_ENDPOINT'));
      expect(envContent, contains('LOG_LEVEL'));
      expect(envContent, contains('ENABLE_DEBUG_MENU'));
      expect(envContent, contains('APP_NAME'));
      expect(envContent, contains('FIREBASE_PROJECT_ID'));
    });

    test('should have environment-specific configuration files', () {
      // .env.dev ファイルの存在確認
      final envDevFile = File('.env.dev');
      expect(envDevFile.existsSync(), isTrue);
      
      // .env.prod ファイルの存在確認  
      final envProdFile = File('.env.prod');
      expect(envProdFile.existsSync(), isTrue);
    });

    test('should have VSCode configuration for environment management', () {
      // VSCode設定ファイルの存在確認
      final launchConfigFile = File('.vscode/launch.json');
      expect(launchConfigFile.existsSync(), isTrue);
      
      final settingsFile = File('.vscode/settings.json');
      expect(settingsFile.existsSync(), isTrue);
      
      // launch.jsonに環境設定が含まれていることを確認
      final launchContent = launchConfigFile.readAsStringSync();
      expect(launchContent, contains('dart-define-from-file'));
      expect(launchContent, contains('.env'));
    });

    test('should have env_config dart files', () {
      // EnvConfigクラスファイルの存在確認
      final envConfigFile = File('lib/config/env_config.dart');
      expect(envConfigFile.existsSync(), isTrue);
      
      // 生成されたファイルの存在確認
      final envConfigGenFile = File('lib/config/env_config.g.dart');
      expect(envConfigGenFile.existsSync(), isTrue);
    });

    test('should have valid Google Mobile Ads configuration format', () {
      // .envファイルから広告設定を確認
      final envFile = File('.env');
      final envContent = envFile.readAsStringSync();
      
      // Google AdMob IDのフォーマット確認
      expect(envContent, contains('GOOGLE_AD_APP_ID_ANDROID=ca-app-pub'));
      expect(envContent, contains('GOOGLE_AD_APP_ID_IOS=ca-app-pub'));
      expect(envContent, contains('BANNER_AD_UNIT_ID_ANDROID=ca-app-pub'));
      expect(envContent, contains('BANNER_AD_UNIT_ID_IOS=ca-app-pub'));
      expect(envContent, contains('INTERSTITIAL_AD_UNIT_ID_ANDROID=ca-app-pub'));
      expect(envContent, contains('INTERSTITIAL_AD_UNIT_ID_IOS=ca-app-pub'));
    });
  });

  group('Environment File Content Tests', () {
    test('development environment should have correct values', () {
      final envFile = File('.env');
      final envContent = envFile.readAsStringSync();
      
      expect(envContent, contains('API_ENDPOINT=https://dev-api.escaperoom-game.com'));
      expect(envContent, contains('LOG_LEVEL=1'));
      expect(envContent, contains('ENABLE_DEBUG_MENU=true'));
      expect(envContent, contains('APP_NAME=Escape Master (Dev)'));
      expect(envContent, contains('FIREBASE_PROJECT_ID=escape-master-dev'));
    });

    test('production environment should have different values', () {
      final envProdFile = File('.env.prod');
      final envProdContent = envProdFile.readAsStringSync();
      
      expect(envProdContent, contains('API_ENDPOINT=https://api.escaperoom-game.com'));
      expect(envProdContent, contains('LOG_LEVEL=3'));
      expect(envProdContent, contains('ENABLE_DEBUG_MENU=false'));
      expect(envProdContent, contains('APP_NAME=Escape Master'));
      expect(envProdContent, contains('FIREBASE_PROJECT_ID=escape-master-prod'));
    });
  });
}