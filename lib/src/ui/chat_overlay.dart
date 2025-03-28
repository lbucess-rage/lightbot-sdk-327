import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import '../config/lightbot_config.dart';

class LightbotChatOverlay extends StatefulWidget {
  final Function? onClose;
  final LightbotConfig config;

  const LightbotChatOverlay({Key? key, this.onClose, required this.config})
      : super(key: key);

  @override
  State<LightbotChatOverlay> createState() => _LightbotChatOverlayState();
}

class _LightbotChatOverlayState extends State<LightbotChatOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late WebViewController _webViewController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();

    _initWebView();
  }

  void _initWebView() {
    // 설정에서 값 가져오기
    final chatConfig = widget.config.toMap();

    // URL 쿼리 파라미터로 인코딩
    final encodedConfig = Uri.encodeComponent(jsonEncode(chatConfig));

    // 외부 URL 가져오기
    final externalUrl = widget.config.externalUrl;

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'ChatSDK',
        onMessageReceived: _handleJavaScriptMessage,
      )
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            setState(() {
              _isLoading = false;
            });

            // 화면 크기가 변경되었을 때 스케일 값을 업데이트
            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;

            // 화면 크기에 따라 스케일 조정 (외부 HTML에 전달된 값이 우선함)
            if (screenWidth < 320 || screenHeight < 600) {
              _webViewController.runJavaScript(
                'document.documentElement.style.setProperty("--chat-scale", "0.75");',
              );
            }
          },
          onWebResourceError: (WebResourceError error) {
            print('웹뷰 에러: ${error.description}, 에러 코드: ${error.errorCode}');
          },
        ),
      )
      ..enableZoom(true)
      ..clearCache()
      ..clearLocalStorage()
      // 외부 URL에 쿼리 파라미터 포함하여 로드
      ..loadRequest(Uri.parse('$externalUrl?config=$encodedConfig'));
  }

  void _handleJavaScriptMessage(JavaScriptMessage message) {
    print('웹챗으로부터 메시지 수신: ${message.message}');
    try {
      final data = jsonDecode(message.message);
      if (data is Map && data.containsKey('type')) {
        switch (data['type']) {
          case 'status':
            print('웹챗 상태 변경: ${data['status']}');
            break;
          case 'message':
            print('채팅 메시지: ${data['content']}');
            print('챗봇 응답: ${data['response']}');
            break;
        }
      }
    } catch (e) {
      print('메시지 파싱 오류: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _closeOverlay() {
    _animationController.reverse().then((value) {
      if (widget.onClose != null) {
        widget.onClose!();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    double horizontalPadding;
    double verticalPadding;

    if (screenSize.width < 320) {
      horizontalPadding = 4.0;
    } else if (screenSize.width < 360) {
      horizontalPadding = 8.0;
    } else if (screenSize.width < 400) {
      horizontalPadding = 12.0;
    } else {
      horizontalPadding = 16.0;
    }

    if (screenSize.height < 600) {
      verticalPadding = 16.0;
    } else if (screenSize.height < 700) {
      verticalPadding = 24.0;
    } else if (screenSize.height < 800) {
      verticalPadding = 32.0;
    } else {
      verticalPadding = 48.0;
    }

    return FadeTransition(
      opacity: _animation,
      child: Stack(
        children: [
          GestureDetector(
            onTap: _closeOverlay,
            child: Container(
              color: Colors.black54,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Center(
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
              ).animate(_animation),
              child: Container(
                width:
                    MediaQuery.of(context).size.width - (horizontalPadding * 2),
                height:
                    MediaQuery.of(context).size.height - (verticalPadding * 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return SizedBox(
                            width: constraints.maxWidth,
                            height: constraints.maxHeight,
                            child: WebViewWidget(
                              controller: _webViewController,
                            ),
                          );
                        },
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: InkWell(
                          onTap: _closeOverlay,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.black54,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      if (_isLoading)
                        const Center(
                          child: CircularProgressIndicator(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
