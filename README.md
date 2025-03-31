<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# Lightbot SDK

Flutter 3.27.1 버전과 호환되는 웹챗 서비스를 Flutter 앱에 통합하기 위한 SDK입니다.

## 주요 기능

-   웹뷰를 사용한 챗봇 인터페이스 제공
-   다이얼로그 또는 바텀시트 형태로 챗봇 표시
-   사용자 정의 설정 지원 (멤버ID, 사용자이름, 스케일 등)
-   자바스크립트 메시지 통신 지원
-   화면 크기에 맞는 반응형 UI

## 시작하기

### 설치

`pubspec.yaml` 파일에 의존성을 추가합니다:

```yaml
dependencies:
    lightbot_sdk_v3271: ^0.0.1
```

또는 로컬 경로나 Git 저장소를 이용할 수 있습니다:

```yaml
dependencies:
    lightbot_sdk_v3271:
        path: ../lightbot_sdk_v3271
```

### 초기화

앱 시작 시 SDK를 초기화합니다:

```dart
import 'package:lightbot_sdk_v3271/lightbot_sdk_v3271.dart';

void main() {
  LightbotSDK.initialize(
    config: const LightbotConfig(
      memberId: 'm389218-3djjsdhj-3i8923',
      userName: '테스터',
      scale: '0.95',
    ),
  );
  runApp(const MyApp());
}
```

## 사용 예시

### 대화상자로 웹챗 표시

```dart
ElevatedButton(
  onPressed: () => LightbotSDK.showAsDialog(context),
  child: const Text('웹챗 열기'),
)
```

### 바텀시트로 웹챗 표시

```dart
ElevatedButton(
  onPressed: () => LightbotSDK.showAsBottomSheet(context),
  child: const Text('웹챗 바텀시트로 열기'),
)
```

### 사용자 정의 설정으로 웹챗 표시

```dart
LightbotSDK.showAsDialog(
  context,
  config: const LightbotConfig(
    memberId: 'custom-user',
    userName: '커스텀 사용자',
    scale: '0.9',
    additionalParams: {
        'ci': 'n0veu3t3gd648paqvp10lzkw',
        'directUrl':
            'https://lightbot-dev.lbucess.com/domain-cz5g02d?memberId=r1111&ci=n0veu3t3gd648paqvp10lzkw',
    },
  ),
)
```

## 환경 요구사항

-   Flutter: 3.16.0 이상, 3.28.0 미만
-   Dart SDK: 3.2.0 이상, 4.0.0 미만
-   webview_flutter: ^4.4.2

## 추가 정보

-   이 SDK는 Flutter 3.27.1 버전과 호환되도록 특별히 설계되었습니다.
-   웹챗 서비스를 모바일 앱에 손쉽게 통합할 수 있도록 도와줍니다.
-   이슈나 기능 요청은 GitHub 저장소에 등록해주세요.
-   라이센스: MIT
