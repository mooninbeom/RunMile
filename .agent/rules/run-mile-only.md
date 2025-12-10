---
trigger: always_on
---

---
trigger: always_on
---

# Project Rules (iOS/Swift)

## 작성 가이드 (How to write rules)
이 파일은 AI 어시스턴트가 이 프로젝트를 작업할 때 항상 따라야 할 규칙을 정의하는 곳입니다.
각 섹션은 명확한 주제를 가지고 있어야 하며, 구체적인 지시사항을 포함해야 합니다.

**팁:**
- **명확성**: 모호한 표현보다는 구체적인 지시가 좋습니다. (예: "코드를 깨끗하게 짜줘" -> "SwiftLint 규칙을 준수하고, 함수는 20줄을 넘기지 마세요")
- **우선순위**: 중요한 규칙은 상단에 배치하거나 강조하세요.
- **예시**: 가능한 경우 코드 예시를 포함하면 AI가 이해하기 쉽습니다.

---

## 프로젝트 정의
- 해당 앱은 iOS 앱인 '런 마일(Run Mile)' 입니다.
- 해당 앱은 iOS 내에 건강 데이터 중 running workout 데이터를 추출 및 가공하여 다양한 솔루션 제공합니다.
- 운동 기록과 운동화를 매칭해 운동화의 누적 마일리지를 추적합니다.
- 현재 운동 기록들을 기본 Fitness 앱 보다 더욱 효율적으로 볼 수 있습니다.
- 운동 기록들을 바탕으로 예측 도착 시간 및 훈련정보를 제공합니다.

## 기본 규칙 (General Rules)

### 1. 언어 및 스타일 (Language & Style)
- **언어**: 모든 코드와 주석은 **한국어**로 작성합니다 (변수명, 함수명 등 식별자는 영어 사용).
- **Swift 버전**: 최신 Swift 버전을 사용합니다.
- **코드 스타일**: Swift API Design Guidelines를 따릅니다.
- **들여쓰기**: 4칸 공백(Space)을 사용합니다.

### 2. 아키텍처 (Architecture)
- **클린 아키텍쳐(Clean Architecture)**를 사용합니다.
- **Domain(도메인)**: 유즈케이스와 엔티티를 합쳐 도메인 레이어라고 부르는데 도메인 레이어는 누구와도 의존성을 이루지 않는 독립적인 레이어이다. 이 레이어에서는 비즈니스와 관련된 로직을 담당하며 앱에서 사용할 Model과 각각의 비즈니스 로직 단위를 나타내는 UseCase, UseCase의 실질적인 구현을 담당하게 할 Repository 인터페이스로 구성이 되어있다.
- **Data(데이터)**: 데이터베이스나 웹 프레임워크 등 일반적으로 프레임워크나 도구로 구성된다. 대개, 이 레이어에는 안쪽의 원과 통신할 연결 코드 이외에는 별다른 코드를 작성하지 않는다. 네트워크, UI, 데이터베이스, 라이브러리와 프레임워크, 인아웃풋 장치 등이 이에 포함되고 이 레이어에 있는 것들은 빈번하게 변경되는 것이므로 추상화와 제어의 역전을 통해 안쪽 레이어들을 변경으로부터 안전하게 만들어야 한다.
- **Presentation(프레젠테이션)**: domain 과 data 사이의 번역기 역할을 수행한다. 즉, 바깥 또는 안쪽으로 전달되는 모든 데이터를 데이터를 전달 받는 레이어에 용이한 형식으로 변환시켜주는 역할을 한다. View 레이어로 전달되는 데이터를 문자열로 변경해 전달하는 것을 예로 들 수 있다. 프리젠터, 뷰, 뷰모델은 모두 해당 레이어에 속한다.
- **MVVM 패턴**: SwiftUI 뷰와 비즈니스 로직을 분리하기 위해 MVVM 패턴을 사용합니다.
- **View**: UI 레이아웃만 담당하며, 로직은 포함하지 않습니다.
- **ViewModel**: `@Observable` (또는 `ObservableObject`)을 사용하여 상태를 관리합니다.
- **Model**: 데이터 구조체와 비즈니스 로직을 정의합니다.

### 3. SwiftUI 모범 사례 (SwiftUI Best Practices)
- **Preview**: 모든 View 파일에는 Preview를 포함하여 UI를 즉시 확인할 수 있게 합니다.
- **Modifier**: 뷰 수정자가 많아질 경우 별도의 ViewModifier로 분리하거나 extension으로 만듭니다.
- **상수 관리**: 색상, 폰트, 아이콘 등의 리소스는 `Constants` 또는 `DesignSystem` 열거형/구조체로 관리합니다.

### 4. 에러 처리 (Error Handling)
- `try?`나 `try!`의 사용을 지양하고, `do-catch` 블록을 사용하여 명시적으로 에러를 처리합니다.
- 사용자에게 보여줄 에러 메시지는 친절하고 명확하게 작성합니다.

### 5. UI 가이드라인
- Apple에서 제공하는 HIG(Human Interface Guideline) 기준에 맞추어 UI를 디자인합니다.

---

## 예시 (Examples)

### ViewModel 작성 예시
```swift
import SwiftUI

@Observable
class UserViewModel {
    var users: [User] = []
    var isLoading: Bool = false
    
    func fetchUsers() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // API 호출 로직
        } catch {
            print("Error fetching users: \(error)")
        }
    }
}
```

### View 작성 예시
```swift
struct UserListView: View {
    @State private var viewModel = UserViewModel()
    
    var body: some View {
        List(viewModel.users) { user in
            Text(user.name)
        }
        .task {
            await viewModel.fetchUsers()
        }
    }
}
```