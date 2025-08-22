// プラットフォーム条件分岐インポート
export 'html_text_overlay_web.dart'
    if (dart.library.io) 'html_text_overlay_stub.dart';
