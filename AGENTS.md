# Run Mile Codex Guide

이 문서는 Codex가 Run Mile 프로젝트에서 작업할 때 우선 참고해야 하는 프로젝트 지침입니다. 변경 전에는 현재 코드 구조를 먼저 확인하고, 기존 패턴을 보존하면서 필요한 범위만 수정하세요.

## 서비스 목표

Run Mile은 iOS HealthKit에 저장된 러닝 운동 기록을 기반으로 러닝화 마일리지를 추적하는 앱입니다. 사용자가 신발을 등록하고 운동 기록을 연결하면 신발별 누적 거리, 목표 마일리지, 사용 이력, 운동 상세 분석을 확인할 수 있게 돕습니다.

핵심 가치는 다음과 같습니다.

- 러닝화 교체 시점을 감으로 관리하지 않고 실제 운동 거리로 관리합니다.
- iOS 건강 데이터의 러닝 workout을 가져와 운동 목록, 운동 상세, 그래프, 지도 경로, 페이스 분석에 활용합니다.
- 운동 완료 후 신발 마일리지 자동 등록과 알림을 통해 기록 누락을 줄입니다.
- 신발 상세, 운동 상세, HOF 리포트처럼 러너가 “내 기록과 장비를 돌아보는 경험”을 제공합니다.

## 제품 무드와 디자인 시스템

Run Mile의 현재 UI 무드는 밝고 선명한 네오 브루탈리즘입니다. 기본 iOS 스타일을 그대로 쓰기보다 굵은 타이포그래피, 강한 대비, 검은 외곽선, 하드 섀도우, 원색 포인트로 에너지 있는 러닝 앱 느낌을 유지합니다.

디자인 토큰은 `Run Mile/Resources/RunMileDesignSystem.swift`와 `Run Mile/Resources/FontStyle.swift`를 우선 사용합니다.

- 색상은 `RunMileColor`를 사용합니다. 임의의 `Color.red`, `Color.gray`, hex 값을 뷰에 직접 추가하지 마세요.
- 주요 색상은 `primary #FF3333`, `secondary #FFFF00`, `accent #0066FF`, `background white`, `border black`입니다.
- 카드와 버튼은 검은 border, 작은 radius, 하드 shadow를 유지합니다. `runMileBrutalCard`, `runMilePrimaryButton`, `runMileSecondaryButton`를 우선 고려하세요.
- 네오 브루탈 하드 섀도우용 도형은 반드시 전경 뷰보다 뒤에 배치합니다. `ZStack`에서는 offset을 적용한 섀도우 도형을 먼저 선언하고, 실제 배경과 border를 가진 전경 도형을 그 위에 선언하세요.
- 하드 섀도우 도형은 검은색 fill만 사용하고 별도의 border를 추가하지 않습니다. 섀도우용 `RoundedRectangle`을 `overlay`나 높은 `zIndex`에 두어 전경 외곽선과 겹치게 만들지 마세요. 이 경우 상단과 좌측에도 선이 노출되어 이중 외곽선처럼 보입니다.
- 하드 섀도우가 적용된 카드, 버튼, 아이콘은 최종 화면에서 전경 외곽선이 한 줄인지 확인합니다. 검은 섀도우는 의도한 offset 방향인 오른쪽과 아래쪽에서만 보여야 합니다.
- 간격, radius, 크기, stroke는 `RunMileSpacing`, `RunMileRadius`, `RunMileSize`, `RunMileStroke`를 사용합니다.
- 타이포그래피는 system condensed 계열의 bold/heavy/black 무드입니다. 기존 `FontStyle` 또는 현재 화면의 폰트 패턴을 먼저 따르세요.
- 문구는 한국어 기준으로 짧고 명확하게 작성합니다. 러너를 격려하되 과장된 마케팅 문구보다 “지금 무엇을 할 수 있는지”가 바로 보이게 씁니다.
- 지도/운동 분석 UI는 기존 흐름을 유지합니다. 페이스 경로는 빠를수록 초록, 느릴수록 빨강 계열의 그라데이션을 유지하고, 범례/마커/분석 시트는 가시성을 우선합니다.

새 UI를 만들 때는 기존 디자인 시스템에 없는 새로운 색/그림자/폰트 체계를 만들기 전에, 토큰 추가가 정말 필요한지 먼저 판단하세요.

## 아키텍처

Run Mile은 클린 아키텍처와 SwiftUI MVVM을 기준으로 개발합니다. 의존성 방향은 바깥 레이어가 안쪽 추상화에 의존하도록 유지합니다.

### 레이어 역할

- `Run Mile/Domain`: 앱의 핵심 모델, UseCase, Repository/Service 프로토콜을 둡니다. 비즈니스 규칙과 앱이 다루는 개념을 표현합니다.
- `Run Mile/Data`: HealthKit, CoreData, 캐시 등 외부 데이터 접근 구현체를 둡니다. Domain의 Repository 프로토콜을 구현합니다.
- `Run Mile/Presentation`: SwiftUI View, ViewModel, 화면별 component/sheet/section/model을 둡니다.
- `Run Mile/App/Core`: `AppDIContainer`, `ScreenFactory`, preview DI, 앱 공용 service wiring을 둡니다.
- `Run Mile/Helper`: UIKit delegate, extension, manager처럼 앱 전역 보조 기능을 둡니다.

### DI와 화면 생성

- `AppDIContainer`는 Repository, UseCase, ViewModel, 앱 공용 service 생성 책임을 가집니다.
- `ScreenDependencyProviding`은 화면 생성에 필요한 ViewModel factory 인터페이스입니다.
- `ScreenFactory`는 `NavigationCoordinator.Screen`과 `NavigationCoordinator.Sheet`를 실제 SwiftUI View로 변환합니다.
- `NavigationCoordinator`는 navigation path, sheet, alert 상태와 이동 명령만 관리합니다.
- View에서 Data 구현체나 UseCase 구현체를 직접 생성하지 마세요. 새 화면이 필요하면 DIContainer와 ScreenFactory 경로를 연결하세요.

### HealthKit과 자동 마일리지

HealthKit 관련 동기화는 `HealthBackgroundSyncService` 흐름을 우선 따릅니다.

- `enableBackgroundDelivery()`로 HealthKit background delivery를 등록합니다.
- `HKObserverQuery`로 workout 변경을 감지합니다.
- `HKAnchoredObjectQuery`로 anchor 이후 변경분을 가져옵니다.
- 러닝 workout만 필터링하고 pending UUID를 저장한 뒤, completion을 빠르게 호출합니다.
- 실제 신발 자동 등록과 알림은 별도 Task에서 처리하고, 앱 재진입 시 pending workout을 재시도합니다.

이 흐름은 iOS 백그라운드 실행 특성상 즉시/항상 실행이 보장되지 않습니다. UX나 로그를 작성할 때 “보장된 실시간 처리”처럼 표현하지 마세요.

## 폴더링 규칙

기존 기능 단위 폴더링을 따릅니다.

- 신발: `Presentation/1.Shoes`
- 운동: `Presentation/2.Workout`
- 마이페이지/HOF: `Presentation/3.MyPage`
- 공용 컴포넌트: `Presentation/Components`
- 에러 타입: `Presentation/Errors`
- 화면별 하위 뷰: 해당 feature 폴더 아래 `Components`, `Sections`, `Sheets`, `Map`, `Charts`, `Models`, `Preview` 등을 사용합니다.

새 파일을 만들 때는 다음 기준을 사용합니다.

- 부모 View가 길어지거나 하위 UI가 의미 단위를 가지면 별도 파일로 분리합니다.
- 화면 전용 하위 뷰는 해당 화면의 `Components` 또는 `Sections`에 둡니다.
- 여러 화면에서 쓰는 뷰만 `Presentation/Components`로 올립니다.
- 선택 상태, 화면 표시 모델, 카탈로그 같은 Presentation 전용 값은 feature의 `Models`에 둡니다.
- sheet 전용 UI는 `Sheets`에 둡니다.
- map/chart처럼 복잡한 UI 영역은 전용 하위 폴더를 유지합니다.

## View와 ViewModel 분리

View는 화면을 그리는 일과 사용자 액션을 ViewModel로 전달하는 일에 집중합니다.

View에 둬도 되는 것:

- SwiftUI layout, modifier, view composition
- `@FocusState`, gesture local state처럼 View에 강하게 묶인 UI 전용 상태
- 작은 private view builder 또는 매우 짧은 화면 조립 코드
- Preview

ViewModel로 옮겨야 하는 것:

- 데이터 로딩, 저장, 삭제, HealthKit/CoreData 접근
- navigation, sheet, alert 표시 명령
- 표시용 문자열 포맷팅과 상태 계산
- 버튼/셀/차트/지도 선택 액션 처리
- business rule, filtering, sorting, validation
- 여러 subview가 공유하는 상태

ViewModel 작성 규칙:

- 기본적으로 `@Observable final class`를 사용합니다.
- View는 `@State private var viewModel`로 주입받은 ViewModel을 보관합니다.
- 초기화는 `init(viewModel:)`로 받고, Preview에서는 `PreviewDIContainer`를 사용합니다.
- 액션 메서드는 `addShoesButtonTapped`, `shoesCellTapped`, `mapAnalysisCloseButtonTapped`처럼 사용자 이벤트 중심으로 이름을 짓습니다.
- async 작업 후 UI 상태를 바꿀 때는 `@MainActor` 경계를 명확히 합니다.
- 복잡한 computed property나 표시 모델은 ViewModel 또는 Presentation model로 분리합니다.

## UseCase와 Repository 규칙

- ViewModel은 UseCase에 의존합니다.
- UseCase는 Domain의 Repository 프로토콜에 의존합니다.
- Data 레이어 구현체는 `...RepositoryImpl` 네이밍을 사용하고, Domain 프로토콜을 구현합니다.
- 새 데이터 소스가 필요하면 먼저 Domain interface를 만들고 Data 구현체를 추가한 뒤 DIContainer에서 주입하세요.
- HealthKit, CoreData, UserDefaults, NotificationCenter 접근은 View나 ViewModel에 직접 흩뿌리지 않습니다.
- 핵심 데이터 로딩 실패는 명시적으로 `do-catch`하고 사용자에게 알립니다.
- 선택적/비핵심 metric은 실패 시 전체 화면을 실패시키기보다 빈 배열 또는 nil 상태로 안전하게 처리합니다.

## 코드 스타일

- Swift API Design Guidelines를 따릅니다.
- 들여쓰기는 4칸 space를 사용합니다.
- 파일/타입 네이밍은 기존 프로젝트 스타일을 따릅니다.
- 식별자는 영어를 사용하고, 사용자 노출 문구와 설명 주석은 한국어를 사용합니다.
- 불필요한 주석은 만들지 않습니다. 단, 새로 만든 public/internal 메서드 중 의도가 즉시 드러나지 않는 메서드에는 짧은 한국어 주석을 추가합니다.
- stale TODO, mock text, 임시 로그는 작업 완료 전 제거합니다.
- `try!`, 무분별한 `try?`, 강제 unwrap은 피합니다.
- 기존 사용자 변경을 되돌리지 마세요. 관련 없는 파일은 건드리지 않습니다.
- 수동 파일 수정은 patch 단위로 작고 명확하게 유지합니다.

## SwiftUI 구현 규칙

- 큰 View 하나에 모든 UI를 넣지 말고 의미 단위 subview로 나눕니다.
- body 안에서 무거운 계산, sorting/filtering, 날짜/거리/페이스 포맷팅을 반복하지 않습니다.
- 버튼 action은 가능하면 ViewModel 메서드 하나를 호출하도록 단순화합니다.
- alert/sheet/navigation은 `NavigationCoordinator` 흐름을 사용합니다.
- `NavigationLink`를 직접 늘리기보다 기존 Coordinator/ScreenFactory 구조와 맞춥니다.
- 상태가 ViewModel에 있어야 하는지 View-local이어야 하는지 먼저 판단합니다.
- Preview가 깨지지 않도록 새 ViewModel factory가 필요하면 `PreviewDIContainer`와 mock use case도 같이 갱신합니다.

## 운동 상세/지도/차트 규칙

- 운동 상세 데이터는 핵심 데이터와 비핵심 metric을 구분합니다.
- 페이스, 심박, 파워, 고도, route 등은 이미 만들어진 `WorkoutDetailUseCase`, `WorkoutDetailViewModel`, `WorkoutDetailData` 흐름을 우선 확장합니다.
- route 렌더링은 부드러움과 시각적 안정성을 우선합니다. 경로 단절을 만들지 않도록 극단값 보정과 색상 계산을 분리해서 다룹니다.
- 지도 분석 UI에서는 데이터 소스가 화면마다 달라지지 않게 같은 보정/포맷팅 흐름을 사용합니다.
- 차트 축, 시간 표기, pace 표기는 기존 formatter/helper를 먼저 확인하고 재사용합니다.

## 신발 카탈로그 규칙

신발 브랜드/모델 목록은 `Run Mile/Presentation/1.Shoes/Models/ShoeCatalog.swift`에서 관리합니다.

- 브랜드 키와 순서는 앱 UX에 직접 영향을 주므로 임의로 바꾸지 마세요.
- 모델명을 바꿀 때는 신발 추가/수정 뷰의 선택 복원 로직도 함께 고려합니다.
- 모든 브랜드는 마지막 선택지로 `기타`를 유지합니다.
- 신발명이 저장된 뒤 카탈로그에서 사라진 모델은 수정 화면에서 custom model로 복원될 수 있습니다. 이 동작을 깨지 마세요.

## 검증

작업 후 가능한 범위에서 빌드 또는 관련 검증을 실행합니다.

권장 빌드:

```bash
xcodebuild -project "Run Mile.xcodeproj" -scheme "Run Mile" -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

Codex 환경에서 XcodeBuildMCP가 사용 가능하면 shell `xcodebuild`보다 XcodeBuildMCP의 simulator build 도구를 우선 사용합니다.

검증 결과를 최종 응답에 짧게 남기세요. 빌드를 실행하지 못했다면 이유를 명확히 말합니다.

## 작업 전 체크리스트

- 현재 feature 폴더와 유사 파일을 먼저 읽었는가?
- View에 로직이 들어가고 있지 않은가?
- ViewModel이 직접 Data 구현체를 만들고 있지 않은가?
- 새 의존성이 DIContainer/ScreenFactory/PreviewDIContainer에 반영됐는가?
- 디자인 토큰을 재사용했는가?
- 새 UI가 Run Mile의 네오 브루탈리즘 무드와 맞는가?
- HealthKit/notification/background 동작을 과도하게 보장한다고 표현하지 않았는가?
- 핵심 데이터 실패와 선택 데이터 부재를 구분했는가?
- 관련 없는 파일을 수정하지 않았는가?
