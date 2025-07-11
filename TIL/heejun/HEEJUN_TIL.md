# TIL 기록

## 3월 4일
개발에 앞서 APP을 하기로 했는데 어떤 프레임워크 혹은 언어를 사용해야하는지 고민이 되어 네이티브와 플러터의 사용을 고민했다. 

# 네이티브 vs 플러터

 

# 안드로이드 네이티브 vs 플러터 상세 비교

## 1. 개발 환경 및 언어

### 안드로이드 네이티브

- **주요 언어**: Kotlin, Java
- **IDE**: Android Studio
- **빌드 도구**: Gradle
- **UI 작성 방식**: XML 레이아웃 또는 Jetpack Compose

### 플러터

- **주요 언어**: Dart
- **IDE**: Android Studio, VS Code
- **빌드 도구**: Flutter CLI
- **UI 작성 방식**: 위젯 기반 선언적 UI

## 2. 성능 비교

### 안드로이드 네이티브

- 플랫폼에 직접 접근으로 최상의 성능
- 하드웨어 가속 완벽 지원
- 메모리 관리의 효율성
- 플랫폼 최적화 용이

### 플러터

- Skia 엔진으로 준수한 성능
- JIT/AOT 컴파일 지원
- 60fps 애니메이션 지원
- 약간의 성능 오버헤드 존재

## 3. 개발 생산성

### 안드로이드 네이티브

- 긴 빌드 시간
- 복잡한 설정 필요
- 안정적인 개발 환경
- 풍부한 레퍼런스

### 플러터

- Hot Reload로 빠른 개발
- 간단한 프로젝트 설정
- 크로스 플랫폼 개발 가능
- 적은 코드량

## 4. 상태관리

### 안드로이드 네이티브

- ViewModel
- LiveData
- Flow
- StateFlow
- DataBinding

### 플러터

- Provider
- GetX
- Bloc
- Riverpod
- ChangeNotifier

## 5. UI/UX 개발

### 안드로이드 네이티브

- Material Design 완벽 지원
- 플랫폼 기본 컴포넌트 사용
- XML 기반 레이아웃
- Jetpack Compose로 선언적 UI 가능

### 플러터

- 커스텀 위젯 개발 용이
- 풍부한 내장 위젯
- 일관된 크로스 플랫폼 UI
- 애니메이션 구현 용이

## 6. 비동기 처리

### 안드로이드 네이티브

- Coroutines
- RxJava
- Thread
- AsyncTask (Deprecated)

### 플러터

- Future
- async/await
- Stream
- Isolate

## 7. 학습 곡선

### 안드로이드 네이티브

- 높은 진입 장벽
- 안드로이드 생명주기 이해 필요
- 복잡한 아키텍처 패턴
- 플랫폼 특화 지식 필요

### 플러터

- 상대적으로 낮은 진입 장벽
- 단순한 위젯 기반 개발
- 직관적인 상태관리
- 웹 개발자 친화적

## 8. 적합한 프로젝트 유형

### 안드로이드 네이티브

- 하드웨어 집약적 앱
- 고성능 요구 앱
- 플랫폼 특화 기능 필요
- 엔터프라이즈급 앱

### 플러터

- MVP/프로토타입
- 크로스 플랫폼 앱
- UI 중심 앱
- 빠른 개발 필요한 프로젝트

## 9. 커뮤니티 및 생태계

### 안드로이드 네이티브

- 거대한 개발자 커뮤니티
- 풍부한 서드파티 라이브러리
- 오랜 기간 축적된 자료
- 안정적인 생태계

### 플러터

- 빠르게 성장하는 커뮤니티
- 활발한 패키지 개발
- 구글의 강력한 지원
- 최신 개발 트렌드 반영

## 10. 취업 시장

### 안드로이드 네이티브

- 많은 채용 기회
- 높은 연봉 수준
- 안정적인 경력 개발
- 전문성 인정

### 플러터

- 증가하는 채용 수요
- 크로스 플랫폼 개발자 수요
- 스타트업 선호
- 새로운 시장 기회
---
노션에 적어 놓은것 .. 결국 학습기간이 짧아 진입장벽이 낮은 플러터를 택했는데 이것마저도 어려운것같다 ㅠㅠ

## 3월 5일 
### Dart의 비동기 프로그래밍 Future
```dart
// 즉시 값을 반환하는 Future
Future<String> getInstantValue() {
  return Future.value('즉시 반환된 값');
}

// 지연 후 값을 반환하는 Future
Future<String> getDelayedValue() {
  return Future.delayed(Duration(seconds: 2), () {
    return '2초 후 반환된 값';
  });
}

// 비동기 함수 (async 키워드 사용)
Future<String> fetchUserData() async {
  // 네트워크 요청이나 시간이 걸리는 작업 가정
  await Future.delayed(Duration(seconds: 3));
  return '사용자 데이터';
}
```
예시 코드는 AI 를 사용해 가져온것 
1학기 관통프로젝트 부터 느낀 비동기의 중요성 아직 완벽 파악한진 모르지만 언어별로 가장 먼저 관심이 가는 분야이다.

## 3월 6일
![alt text](image.png) <br>
며칠간 주제만 고민해도 해소가 되지 않는다 .. 경험과 상상력은 무시 못하는것 같음을 느낀다 난 둘다 많이 부족한것같다.. 그래서 팀원들과의 의견투합이 중요한 것 같다.. 덕분에 내 부족한 아이이더에 많은 살을 붙였다. 