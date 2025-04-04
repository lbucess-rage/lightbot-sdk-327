import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
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
      ..setBackgroundColor(Colors.white)
      ..addJavaScriptChannel(
        'ChatSDK',
        onMessageReceived: _handleJavaScriptMessage,
      )
      // 추가 설정
      ..setUserAgent('Flutter_WebView_LightbotSDK')
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            print('웹뷰 로딩 시작: $url');
          },
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

            // 웹뷰 크기 정보 전달
            _webViewController.runJavaScript('''
              window.viewportWidth = ${screenWidth};
              window.viewportHeight = ${screenHeight};
              console.log('뷰포트 크기:', ${screenWidth}, ${screenHeight});
            ''');

            // 스크롤 동작 최적화를 위한 JavaScript 실행
            _webViewController.runJavaScript('''
              // 스크롤 기능 향상을 위한 스타일 추가
              (function() {
                // 스타일 요소 생성
                const style = document.createElement('style');
                style.textContent = `
                  html, body {
                    overflow: auto !important;
                    -webkit-overflow-scrolling: touch !important;
                    touch-action: pan-y !important;
                    height: 100% !important;
                  }
                  
                  /* 모든 스크롤 가능한 요소에 스타일 적용 */
                  [class*="chat-messages"],
                  [class*="chatMessages"],
                  [class*="message-list"],
                  [class*="messageList"],
                  [class*="overflow"],
                  [class*="scroll"],
                  div[style*="overflow: auto"],
                  div[style*="overflow-y: auto"],
                  div[style*="overflow:auto"],
                  div[style*="overflow-y:auto"] {
                    overflow-y: auto !important;
                    -webkit-overflow-scrolling: touch !important;
                    touch-action: pan-y !important;
                    pointer-events: auto !important;
                  }
                  
                  /* iframe 내부 스크롤 허용 */
                  iframe {
                    pointer-events: auto !important;
                  }
                `;
                document.head.appendChild(style);
                console.log('스크롤 스타일이 적용되었습니다.');
              })();
              
              // 이벤트 핸들러 설정 (터치 이벤트 개선)
              (function() {
                // 스크롤 영역 자동 탐지
                const potentialScrollables = Array.from(document.querySelectorAll('*')).filter(el => {
                  const style = window.getComputedStyle(el);
                  return style.overflowY === 'auto' || style.overflowY === 'scroll' ||
                         style.overflow === 'auto' || style.overflow === 'scroll' ||
                         el.classList.toString().includes('chat') || 
                         el.classList.toString().includes('message');
                });
                
                console.log('스크롤 가능한 요소 감지:', potentialScrollables.length);
                
                // 모든 스크롤 가능한 요소에 passive 터치 리스너 추가
                potentialScrollables.forEach(el => {
                  el.style.webkitOverflowScrolling = 'touch';
                  el.style.overflowY = 'auto';
                  el.style.touchAction = 'pan-y';
                  
                  // 이벤트 리스너 추가
                  el.addEventListener('touchstart', function(e) {
                    // Do nothing, this enables better scroll performance
                  }, { passive: true });
                  
                  console.log('스크롤 처리가 적용된 요소:', el.tagName, el.classList?.toString());
                });
                
                // 문서 전체에 대한 스크롤 개선
                document.addEventListener('touchmove', function(e) {
                  // Allow default scrolling behavior
                }, { passive: true });
                
                // 주기적으로 새로운 스크롤 요소 확인 (동적 UI 대응)
                setInterval(() => {
                  const newScrollables = Array.from(document.querySelectorAll('*')).filter(el => {
                    const style = window.getComputedStyle(el);
                    return (style.overflowY === 'auto' || style.overflowY === 'scroll' ||
                           style.overflow === 'auto' || style.overflow === 'scroll') &&
                           !el.hasAttribute('scroll-fixed');
                  });
                  
                  newScrollables.forEach(el => {
                    el.setAttribute('scroll-fixed', 'true');
                    el.style.webkitOverflowScrolling = 'touch';
                    el.style.touchAction = 'pan-y';
                    el.addEventListener('touchstart', function(e) {}, { passive: true });
                  });
                }, 1000);
                
                console.log('스크롤 이벤트 핸들러가 설정되었습니다.');
              })();
              
              // 부모 컨테이너에 스크롤 이벤트 전파 방지
              (function() {
                const preventPropagation = (e) => {
                  e.stopPropagation();
                };
                
                // 스크롤 가능한 영역에서 터치 이벤트 버블링 방지
                const scrollContainers = document.querySelectorAll('[class*="message"], [class*="chat"]');
                scrollContainers.forEach(container => {
                  container.addEventListener('touchmove', preventPropagation, { passive: true });
                });
              })();
            ''');
          },
          onWebResourceError: (WebResourceError error) {
            print('웹뷰 에러: ${error.description}, 에러 코드: ${error.errorCode}');
          },
        ),
      )
      // 웹뷰 설정 최적화
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

    // 바텀시트에서 사용될 때는 패딩 조정
    final isInBottomSheet = ModalRoute.of(context)?.settings.name == null;
    if (isInBottomSheet) {
      horizontalPadding = 0.0;
      verticalPadding = 0.0;
    }

    return FadeTransition(
      opacity: _animation,
      child: Stack(
        children: [
          // 대화상자 사용 시에만 배경 딤 처리 표시
          if (!isInBottomSheet)
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
                  borderRadius: isInBottomSheet
                      ? BorderRadius.zero
                      : BorderRadius.circular(16),
                  boxShadow: isInBottomSheet
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                ),
                child: ClipRRect(
                  borderRadius: isInBottomSheet
                      ? BorderRadius.zero
                      : BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      // 웹챗 영역 (전체 화면)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          // 스크롤을 개선하기 위해 RepaintBoundary로 웹뷰 감싸기
                          return RepaintBoundary(
                            child: SizedBox(
                              width: constraints.maxWidth,
                              height: constraints.maxHeight,
                              child: WebViewWidget(
                                controller: _webViewController,
                                gestureRecognizers: {
                                  Factory<VerticalDragGestureRecognizer>(
                                      () => VerticalDragGestureRecognizer()),
                                },
                              ),
                            ),
                          );
                        },
                      ),

                      // 닫기 버튼 (대화상자 모드에서만 표시)
                      if (!isInBottomSheet)
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

                      // 로딩 표시
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
