/// 라이트봇 SDK 설정 클래스
class LightbotConfig {
  /// 외부 URL
  final String externalUrl;

  /// 회원 ID
  final String memberId;

  /// 사용자 이름
  final String userName;

  /// 스케일
  final String scale;

  /// 인증키
  final String authKey;

  /// 추가 파라미터
  final Map<String, dynamic> additionalParams;

  /// 생성자
  const LightbotConfig({
    this.externalUrl =
        'https://lightbot-rage.s3.ap-northeast-2.amazonaws.com/lightbot/page/v1/chatbot_external.html',
    this.memberId = '',
    this.userName = '',
    this.scale = '',
    this.authKey = '',
    this.additionalParams = const {},
  });

  /// 설정을 Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'memberId': memberId,
      'userName': userName,
      'scale': scale,
      'authKey': authKey,
      ...additionalParams,
    };
  }

  /// 새로운 설정으로 복사
  LightbotConfig copyWith({
    String? externalUrl,
    String? memberId,
    String? userName,
    String? scale,
    String? authKey,
    Map<String, dynamic>? additionalParams,
  }) {
    return LightbotConfig(
      externalUrl: externalUrl ?? this.externalUrl,
      memberId: memberId ?? this.memberId,
      userName: userName ?? this.userName,
      scale: scale ?? this.scale,
      authKey: authKey ?? this.authKey,
      additionalParams: additionalParams ?? this.additionalParams,
    );
  }
}
