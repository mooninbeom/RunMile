# 🏃👟 Run Mile / 런 마일
러너들에게 가장 중요한 것은 러닝화👟

아이폰에 등록되어있는 운동 기록으로 손 쉽게 러닝화 마일리지를 추적해줍니다!🔥🔥

|상태|앱스토어 배포 완료 및 유지보수 진행 중(v1.0.0)|
|:--|:--|
|기술 스택|SwiftUI, HealthKit, Realm, UserNotifications, Vision(이미지 배경 제거)|
|앱스토어|[Run Mile](https://apps.apple.com/kr/app/run-mile/id6747099791)|
|이메일 문의|dlsqja567@naver.com|

### 신발 관리를 위한 3 Stpes
1. 신발을 등록하고
2. 운동을 추가하세요!
3. 자동 등록을 통해 더욱 편리하게!

![Group 1](https://github.com/user-attachments/assets/2f46e30f-c99c-4f34-be48-795c76cc6c74)

</br>


## 개발 일지
|이름|링크|
|:--|:--|
|**0. 사이드 프로젝트 Run Mile 앱 개발기**|https://velog.io/@mooninbeom/0.-사이드-프로젝트-Run-Mile-앱-개발기|
|**1. HealthKit 데이터 사용(with Continuation)**|https://velog.io/@mooninbeom/1.-HealthKit-데이터-사용with-Continuation|
|**2. 백그라운드에서 HealthKit 활용하기**|https://velog.io/@mooninbeom/2.-백그라운드에서-HealthKit-활용하기-o2p1gg9l|

</br>



## 이번 프로젝트에서 내가 배운 것

### 클린 아키텍쳐를 내 입맛에 맞게 사용



### HealthKit 활용
이번 프로젝트의 핵심은 기기 내에 있는 운동 데이터를 가져오는 것 입니다.
때문에 **HealthKit**을 활용해 원하는 다양한 기능들을 구현했습니다.

**1️⃣ 권한 설정**

기본적으로 건강 데이터는 Privacy 영역이기 때문에 사용자의 권한 허용이 필요하고 다양한 데이터의 종류 중 필요한 영역만 추가해 요청을 해야합니다.
또한 읽기(Read), 쓰기(Share) 영역이 나누어져 있기 때문에 앱에서 필요한 부분만 고려해 필요한 타입만 추가해 요청해야 합니다.
Run Mile에서는 쓰기는 현재 사용하지 않고 운동 타입에 있어서 읽기 부분만 권한을 요청하고 있습니다.

Run Mile에서는 2개의 스텝으로 권한을 요청합니다.

</br>

**1. 권한 요청 확인**

권한 요청이 진행된 상태인지 확인하고 요청이 되지 않았을 경우 요청을 진행합니다.

권한 요청의 경우 허용/허용안함 여부에 상관없이 한 번 요청이 진행되고 나면 다시 앱에서는 요청을 할 수 없습니다.

그래서 불필요한 요청을 방지하기 위해 요청 전 요청 여부를 확인합니다.

만약 이미 요청된 상태이면 사용자가 직접 설정에서 바꾸어야 하기 때문에 해당 방향으로 유도하는 UX가 필요합니다.

```swift
/// in HealthDataUseCase.swift

/// Health 데이터 사용 권한 요청이 이루어졌는지 확인합니다.
private func checkAuthorizationStatus() async throws -> Bool {
    return try await withCheckedThrowingContinuation { continuation in
        store.getRequestStatusForAuthorization(
            toShare: Set(),
            read: Set([.workoutType()])
        ) { status, error in
            if let _ = error {
                continuation.resume(throwing: HealthError.unknownError)
            }
            
            switch status {
            case .shouldRequest:
                continuation.resume(returning: true)
            default:
                continuation.resume(returning: false)
            }
        }
    }
}
```

</br>

**2. 권한 요청**

권한 요청을 진행합니다.

요청을 진행하기 전 Health 데이터가 있는 기기인지 여부를 판별합니다.

```swift
/// in HealthDataUseCase.swift

/// Health 데이터 사용 권한을 요청합니다.
private func requestAuthorization() async throws {
    if HKHealthStore.isHealthDataAvailable() {
        try await store.requestAuthorization(
            toShare: Set(),
            read: Set([.workoutType()])
        )
    } else {
        throw HealthError.notAvailableDevice
    }
}
```

**3. info.plist 수정**

요청 시 나오는 메시지를 작성합니다.

해당 과정은 필수적이기 때문에 반드시 추가가 필요합니다.

만약 누락이 되어있거나 권한이 필요한 자세한 이유를 서술해놓지 않은 경우 출시 심사 시 리젝 사유가 될 수 있습니다.

실제로 건강 데이터 쪽은 아니지만 카메라 사용 관련 메시지에 `사진을 찍기 위해 카메라 허용이 필요합니다.`라고 적어놓으니 구체적이지 않다고 리젝을 당했습니다.

또한 앱을 올리는 과정에서 저희 앱은 읽기 부분만 사용하기에 해당 info 만 업데이트 했지만 쓰기 부분이 누락되어 있다고 업로드에 실패했습니다.

결과적으로 info에 Privacy와 관련된 해당 내용을 추가할 때 가능한 구체적인 작성이 필요하고 Health의 경우 Update, Share 둘 다 작성할 필요가 있습니다.

<img width="771" alt="스크린샷 2025-06-16 오후 4 12 16" src="https://github.com/user-attachments/assets/9179425e-a876-4a18-b6e6-f628d693dca1" />




</br></br>

**2️⃣ 데이터 불러오기**

`HKSampleQuery`를 통해 일반적인 데이터를 가져올 수 있는 쿼리문을 만들 수 있습니다.

해당 쿼리의 파라미터로 원하는 데이터를 필터링 할 수 있습니다.

Run Mile 에서는 운동 데이터만 필요하므로 workoutType으로 제한하고 날짜 내림차순으로 정렬을 진행했습니다.

쿼리 사용시 유의할 점은 반환 타입으로 나오는 `HKSample`은 다양한 건강 데이터들의 추상화 타입이기 때문에 변환하지 않으면 정보 접근이 제한 됩니다.(시간 관련 정보만 제공)

때문에 제대로 사용하기 위해서는 특정 타입에 맞추어 타입 캐스팅을 꼭 해야 합니다!(해당 프로젝트에서는 운동 데이터를 들고 오므로 거기에 맞는 `HKWorkout` 타입 캐스팅 진행)

```swift
/// in WorkoutDataRepositoryImpl.swift

private let store = HKHealthStore()

public func fetchWorkoutData() async throws -> [RunningData] {
    let predicate = HKQuery.predicateForWorkouts(with: .running)
    let descriptor = [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
    
    let result: [HKWorkout] = try await store.fetchData(
        sampleType: .workoutType(),
        predicate: predicate,
        limit: HKObjectQueryNoLimit,
        sortDescriptors: descriptor
    )
    
    return convertToRunningData(result)
}
```

구현부에서 간단하고 범용성 있는 사용을 위해 제네릭 메소드 사용
```swift
// in HealthKit+.swift

public func fetchData<T: HKSample>(
    sampleType: HKSampleType,
    predicate: NSPredicate? = nil,
    limit: Int,
    sortDescriptors: [NSSortDescriptor]? = nil
) async throws -> [T] {
    let predicate = HKQuery.predicateForWorkouts(with: .running)
    
    let data = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKSample], any Error>) in
        let query = HKSampleQuery(
            sampleType: sampleType,
            predicate: predicate,
            limit: limit,
            sortDescriptors: sortDescriptors) { query, samples, error in
                if let _ = error {
                    continuation.resume(with: .failure(HealthError.failedToLoadWorkoutData))
                }
                
                guard let samples = samples else {
                    continuation.resume(with: .failure(HealthError.failedToLoadWorkoutData))
                    return
                }
                
                continuation.resume(with: .success(samples))
            }
        self.execute(query)
    }
    
    guard let result = data as? [T] else { throw HealthError.failedToLoadWorkoutData }
    
    return result
}
```

</br>

**3️⃣ 백그라운드 업데이트 적용**

대표적인 운동 기록 앱 `Strava`의 경우 새로운 운동 데이터가 생기면 앱으로 자동 업데이트를 시켜줍니다.

이 기능에 대해 궁금증과 호기심이 생겨 공부 후 프로젝트에 도입했습니다.

`HKHealthStore`의 `enableBackgroundDelivery()`메소드를 통해 특정 타입의 건강 데이터가 업데이트 되었을 때를 트리거로 앱을 깨워 Background Task 를 진행시킬 수 있습니다.

유의할 점은 해당 기능은 특정 데이터의 업데이트 여부만 알려주기 때문에 업데이트된 데이터를 사용하기 위해서는 Background Task 안에서 새로운 Sample Query로 데이터를 fetch해야 합니다.

또한 앱이 완전 종료(suspended)되면 background 등록도 같이 종료되기 때문에 운동이 언제 진행될지 알 수 없는 특성 상 항상 트리거가 실행될 수 있도록 앱 실행 시(AppDelegate)에 등록되도록 구현했습니다.

Run Mile에서 해당 기능으로 구현하고자 한 feature는

새로운 운동(러닝)이 추가되었을 때 
* 자동 등록 기능이 켜져 있을 경우 -> 신발에 운동 추가 후, 추가 완료 noti 생성
* 자동 등록 기능 x -> 운동 완료 noti 생성(앱으로 유도하기 위함)

입니다.

```swift
/// in AppDelegate.swift

public static func setHealthBackgroundTask() async {
    let store = HKHealthStore()
    
    do {
        try await store.enableBackgroundDelivery(for: .workoutType(), frequency: .immediate)
        let query = HKObserverQuery(
            sampleType: .workoutType(),
            predicate: nil
        ) { query, completionHandler, error in
            if let error = error {
                print(error)
                return
            }
            
            let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            let sampleQuery = HKSampleQuery(queryDescriptors: [.init(sampleType: .workoutType(), predicate: nil)], limit: 1, sortDescriptors: [sort]) { _, samples, error in

                ...
              
                guard let workout = samples?.first as? HKWorkout else {
                    return
                }
                
                guard case .running = workout.workoutActivityType else {
                    return
                }
                
                let workoutId = workout.uuid.uuidString
                let currentId = UserDefaults.standard.recentWorkoutID
                
                if !UserDefaults.standard.isFirstLaunch {
                    UserDefaults.standard.recentWorkoutID = workoutId
                } else {
                    if workoutId != currentId {
                        let distance = workout.getKilometerDistance()
                        if !UserDefaults.standard.selectedShoesID.isEmpty {

                            UNUserNotificationCenter.requestNotification(
                                title: String(format: "%.2fkm 러닝 완료 🔥🔥", distance!),
                                body: distance == nil
                                ? "신발에 자동 등록이 완료되었습니다!"
                                : String(format: "신발에 자동 등록이 완료되었습니다. 러닝 후 스트레칭 꼭 잊지 마세요!", distance!)
                            )
                            
                            autoRegisterShoes(workout: workout)
                        } else {
                            UNUserNotificationCenter.requestNotification(
                                title: String(format: "%.2fkm 러닝 완료 🔥🔥", distance!),
                                body: distance == nil
                                ? "신발 마일리지를 등록할 준비가 완료되었습니다. 등록하러 가볼까요?"
                                : String(format: "%.2fkm, 잊지 말고 마일리지를 등록하러 오세요!", distance!)
                            )
                        }
                        UserDefaults.standard.recentWorkoutID = workoutId
                    }
                }
            }
            
            store.execute(sampleQuery)
            
            completionHandler()
        }
        
        store.execute(query)
    } catch {
        print(error)
    }
}
```

