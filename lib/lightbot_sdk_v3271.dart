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

    // 직접 다이얼로그 구현으로 변경
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: LightbotChatOverlay(
            config: chatConfig,
            onClose: () {
              Navigator.of(dialogContext).pop();
            },
          ),
        ),
      ),
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
      enableDrag: true,
      isDismissible: true,
      useSafeArea: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.98,
      ),
      builder: (context) => GestureDetector(
        // 이 GestureDetector는 바텀시트 내부 클릭이 바텀시트를 닫지 않도록 합니다
        onTap: () {},
        child: DraggableScrollableSheet(
          initialChildSize: 0.97,
          minChildSize: 0.6,
          maxChildSize: 0.98,
          expand: false,
          builder: (context, scrollController) {
            return Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(26),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 드래그 핸들 영역 (바텀시트로 작동하는 영역)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        width: double.infinity,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // 드래그 핸들
                            Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            // 닫기 버튼 (오른쪽)
                            Positioned(
                              right: 16,
                              child: IconButton(
                                icon: const Icon(Icons.close, size: 28),
                                onPressed: () {
                                  // 닫기 버튼을 눌렀을 때 바텀시트 닫기
                                  Navigator.of(context).pop();
                                },
                                padding: const EdgeInsets.all(8),
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 웹뷰 영역 (내부 스크롤 작동)
                      Expanded(
                        child: LightbotChatOverlay(
                          config: chatConfig,
                          onClose: () {
                            // 안전하게 바텀시트 닫기
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      routeSettings: const RouteSettings(arguments: "bottomSheet"),
    );
  }
}
