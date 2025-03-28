library lightbot_sdk_v3271;

import 'package:flutter/material.dart';
import 'src/config/lightbot_config.dart';
import 'src/ui/chat_overlay.dart';

export 'src/config/lightbot_config.dart';

/// Lightbot SDK 메인 클래스 (Flutter 3.27.1 호환)
class LightbotSDK {
  /// SDK 싱글턴 인스턴스
  static final LightbotSDK _instance = LightbotSDK._internal();

  /// 현재 설정
  LightbotConfig _config = const LightbotConfig();

  /// 팩토리 생성자
  factory LightbotSDK() => _instance;

  /// 내부 생성자
  LightbotSDK._internal();

  /// SDK 초기화
  static void initialize({LightbotConfig? config}) {
    if (config != null) {
      _instance._config = config;
    }
  }

  /// 현재 설정 가져오기
  static LightbotConfig get config => _instance._config;

  /// 설정 업데이트
  static void updateConfig(LightbotConfig newConfig) {
    _instance._config = newConfig;
  }

  /// 대화상자로 채팅 표시
  static Future<Object?> showAsDialog(
    BuildContext context, {
    LightbotConfig? config,
    bool barrierDismissible = true,
  }) async {
    final chatConfig = config ?? _instance._config;

    return showGeneralDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: '웹챗 닫기',
      pageBuilder: (context, animation, secondaryAnimation) {
        return Material(
          type: MaterialType.transparency,
          child: LightbotChatOverlay(
            config: chatConfig,
            onClose: () {
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  /// 바텀 시트로 채팅 표시
  static Future<Object?> showAsBottomSheet(
    BuildContext context, {
    LightbotConfig? config,
  }) async {
    final chatConfig = config ?? _instance._config;

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: LightbotChatOverlay(
          config: chatConfig,
          onClose: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
