//
//  HealthBackgroundSyncService.swift
//  Run Mile
//
//  Created by Codex on 5/12/26.
//

import Foundation
import HealthKit


protocol HealthBackgroundSyncService {
    func enableBackgroundDelivery() async
    func registerHealthBackgroundQueryTask()
    func processPendingRunningWorkoutsIfNeeded() async
    func fetchRunningWorkout(id: UUID) async throws -> Workout?
}


/// HealthKit 운동 변경 감지와 신발 마일리지 자동 등록 플로우를 담당합니다.
///
/// `AppDIContainer`가 앱 전역에서 하나의 인스턴스를 보관하고, `AppDelegate`와 `WorkoutListViewModel`은
/// 같은 서비스를 주입받아 호출합니다. 그래서 앱 최초 실행 시뿐 아니라 WorkoutListView에서 HealthKit 권한이
/// 새로 승인된 직후에도 동일한 observer query를 즉시 등록할 수 있습니다.
///
/// 1. 앱 실행 또는 권한 승인 직후 `registerHealthBackgroundQueryTask()`로 `HKObserverQuery`를 등록합니다.
/// 2. `enableBackgroundDelivery()`는 HealthKit이 workout 변경 시 앱을 깨울 수 있도록 background delivery를 등록합니다.
/// 3. HealthKit workout 변경이 감지되면 observer callback에서 `fetchUpdatedWorkouts(completion:)`을 호출합니다.
/// 4. `fetchUpdatedWorkouts`는 저장된 `lastAnchor` 이후 변경분만 `HKAnchoredObjectQuery`로 가져옵니다.
/// 5. 변경분 중 러닝 workout만 필터링하고, 백그라운드 실행 시간이 부족할 때를 대비해 workout UUID를 pending 목록에 먼저 저장합니다.
/// 6. 새 anchor를 저장한 뒤 HealthKit의 completion handler를 빠르게 호출할 수 있도록 `completion()`을 먼저 실행합니다.
/// 7. 실제 신발 등록은 별도 `Task`에서 기존 자동 등록 플로우를 수행합니다.
/// 8. 자동 등록 성공 시 pending 목록에서 제거하고 완료 알림을 발행합니다.
/// 9. 앱이 백그라운드에서 처리 도중 중단된 경우, 다음 앱 실행 시 `processPendingRunningWorkoutsIfNeeded()`가 pending UUID를 다시 fetch해 재시도합니다.
final class DefaultHealthBackgroundSyncService: HealthBackgroundSyncService {
    private let healthStore = HKHealthStore()
    private let shoesRepository: ShoesDataRepository
    private let mileageGoalNotificationService: MileageGoalNotificationService
    private var workoutObserverQuery: HKObserverQuery?

    init(
        shoesRepository: ShoesDataRepository,
        mileageGoalNotificationService: MileageGoalNotificationService
    ) {
        self.shoesRepository = shoesRepository
        self.mileageGoalNotificationService = mileageGoalNotificationService
    }

    /// 백그라운드에서 HealthKit workout 변경을 받을 수 있도록 등록합니다.
    func enableBackgroundDelivery() async {
        do {
            try await healthStore.enableBackgroundDelivery(for: .workoutType(), frequency: .immediate)
        } catch {
            print(error.localizedDescription)
        }
    }

    /// HealthKit workout 변경 감지를 위한 observer query를 등록합니다.
    func registerHealthBackgroundQueryTask() {
        if let workoutObserverQuery {
            healthStore.stop(workoutObserverQuery)
        }

        prepareWorkoutAnchorIfNeeded()

        let observerQuery = HKObserverQuery(
            sampleType: .workoutType(),
            predicate: nil
        ) { [weak self] _, completionHandler, error in
            guard let self else {
                completionHandler()
                return
            }

            if let error {
                print(error.localizedDescription)
                completionHandler()
                return
            }

            self.fetchUpdatedWorkouts {
                completionHandler()
            }
        }

        self.workoutObserverQuery = observerQuery
        healthStore.execute(observerQuery)
    }

    /// 이전 백그라운드 실행에서 완료하지 못한 workout 처리를 앱 실행 시 재시도합니다.
    func processPendingRunningWorkoutsIfNeeded() async {
        let pendingIDs = UserDefaults.standard.pendingRunningWorkoutIDs
        guard !pendingIDs.isEmpty else {
            return
        }

        var workouts: [HKWorkout] = []
        var removablePendingIDs = Set<String>()
        for id in pendingIDs {
            guard let uuid = UUID(uuidString: id) else {
                removablePendingIDs.insert(id)
                continue
            }

            do {
                if let workout = try await healthStore.fetchSingleWorkoutData(id: uuid),
                   workout.workoutActivityType == .running {
                    workouts.append(workout)
                } else {
                    removablePendingIDs.insert(id)
                }
            } catch {
                print(error.localizedDescription)
            }
        }

        if !removablePendingIDs.isEmpty {
            UserDefaults.standard.pendingRunningWorkoutIDs = Self.remainingPendingRunningWorkoutIDs(
                currentIDs: pendingIDs,
                removingIDs: removablePendingIDs
            )
        }

        guard !workouts.isEmpty else {
            return
        }

        await processUpdatedRunningWorkouts(workouts)
        removePendingRunningWorkouts(workouts)
    }

    /// HealthKit에 저장된 러닝 workout을 UUID로 조회해 앱 도메인 모델로 변환합니다.
    func fetchRunningWorkout(id: UUID) async throws -> Workout? {
        guard let workout = try await healthStore.fetchSingleWorkoutData(id: id),
              workout.workoutActivityType == .running else {
            return nil
        }

        return Workout(workout: workout)
    }
}


private extension DefaultHealthBackgroundSyncService {
    /// 기존 HealthKit 데이터를 자동 등록하지 않도록 최초 기준 anchor만 저장합니다.
    func prepareWorkoutAnchorIfNeeded() {
        guard UserDefaults.standard.lastAnchor == nil else {
            return
        }

        let query = HKAnchoredObjectQuery(
            type: .workoutType(),
            predicate: nil,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { _, _, _, anchor, error in
            if let error {
                print(error.localizedDescription)
                return
            }

            if let anchor {
                UserDefaults.standard.lastAnchor = anchor
            }
        }

        healthStore.execute(query)
    }

    /// ObserverQuery가 감지한 HealthKit 변경분을 AnchoredObjectQuery로 가져옵니다.
    func fetchUpdatedWorkouts(completion: @escaping () -> Void) {
        guard let currentAnchor = UserDefaults.standard.lastAnchor else {
            prepareWorkoutAnchorIfNeeded()
            completion()
            return
        }

        let query = HKAnchoredObjectQuery(
            type: .workoutType(),
            predicate: nil,
            anchor: currentAnchor,
            limit: HKObjectQueryNoLimit
        ) { [weak self] _, samples, _, anchor, error in
            guard let self else {
                completion()
                return
            }

            if let error {
                print(error.localizedDescription)
                completion()
                return
            }

            let workouts = (samples as? [HKWorkout]) ?? []
            let runningWorkouts = workouts.filter {
                $0.workoutActivityType == .running
            }

            guard !runningWorkouts.isEmpty else {
                if let anchor {
                    UserDefaults.standard.lastAnchor = anchor
                }

                completion()
                return
            }

            enqueuePendingRunningWorkouts(runningWorkouts)

            if let anchor {
                UserDefaults.standard.lastAnchor = anchor
            }

            completion()

            Task {
                await self.processUpdatedRunningWorkouts(runningWorkouts)
                self.removePendingRunningWorkouts(runningWorkouts)
            }
        }

        healthStore.execute(query)
    }

    /// 백그라운드 실행 시간이 부족할 때를 대비해 처리 예정 workout UUID를 먼저 저장합니다.
    func enqueuePendingRunningWorkouts(_ workouts: [HKWorkout]) {
        let newIDs = workouts.map { $0.uuid.uuidString }
        let currentIDs = UserDefaults.standard.pendingRunningWorkoutIDs
        let mergedIDs = Array(Set(currentIDs + newIDs))

        UserDefaults.standard.pendingRunningWorkoutIDs = mergedIDs
    }

    /// 처리가 끝난 workout UUID를 pending 목록에서 제거합니다.
    func removePendingRunningWorkouts(_ workouts: [HKWorkout]) {
        let processedIDs = Set(workouts.map { $0.uuid.uuidString })
        let remainingIDs = Self.remainingPendingRunningWorkoutIDs(
            currentIDs: UserDefaults.standard.pendingRunningWorkoutIDs,
            removingIDs: processedIDs
        )

        UserDefaults.standard.pendingRunningWorkoutIDs = remainingIDs
    }

    /// 새로 추가된 러닝 운동들을 자동 등록 설정에 따라 처리합니다.
    func processUpdatedRunningWorkouts(_ workouts: [HKWorkout]) async {
        for workout in workouts {
            if !UserDefaults.standard.selectedShoesID.isEmpty {
                await autoRegisterShoes(workout: workout)
            } else {
                requestManualRegisterNotification(workout: workout)
            }
        }
    }

    /// 업데이트된 운동을 현재 자동 등록 신발에 연결합니다.
    func autoRegisterShoes(workout: HKWorkout) async {
        let newWorkout = Workout(workout: workout)

        do {
            guard let shoesID = UUID(uuidString: UserDefaults.standard.selectedShoesID) else {
                requestManualRegisterNotification(workout: workout)
                return
            }

            let shoes = try await shoesRepository.fetchSingleShoes(id: shoesID)
            let previousMileage = shoes.totalMileage

            guard !shoes.workouts.contains(where: { $0.id == newWorkout.id }) else {
                return
            }

            let newShoes = Shoes(
                id: shoes.id,
                image: shoes.image,
                shoesName: shoes.shoesName,
                nickname: shoes.nickname,
                goalMileage: shoes.goalMileage,
                currentMileage: shoes.currentMileage,
                workouts: shoes.workouts + [newWorkout]
            )

            try await shoesRepository.updateShoes(shoes: newShoes)
            let updatedShoes = try await shoesRepository.fetchSingleShoes(id: shoes.id)
            if updatedShoes.didReachGoal(from: previousMileage) {
                await mileageGoalNotificationService.requestGoalReachedNotification(shoes: updatedShoes)
            }
            requestAutoRegisterNotification(workout: workout, shoesName: shoesNotificationName(for: shoes))
        } catch {
            UserNotificationsManager.requestNotification(
                category: .manualRegister(newWorkout),
                title: "마일리지 자동 등록에 실패했습니다.",
                body: "앱에서 수동으로 등록 부탁드립니다."
            )
        }
    }

    /// 자동 등록 성공 후 사용자에게 완료 알림을 보냅니다.
    func requestAutoRegisterNotification(workout: HKWorkout, shoesName: String) {
        UserNotificationsManager.requestNotification(
            category: .autoRegister,
            title: notificationTitle(for: workout),
            body: "\(shoesName)에 마일리지가 자동으로 추가됐어요."
        )
    }

    /// 자동 등록 신발이 없을 때 수동 등록 안내 알림을 보냅니다.
    func requestManualRegisterNotification(workout: HKWorkout) {
        let entity = Workout(workout: workout)

        UserNotificationsManager.requestNotification(
            category: .manualRegister(entity),
            title: notificationTitle(for: workout),
            body: "오늘 함께 달린 신발을 선택해 마일리지를 기록해요."
        )
    }

    /// 러닝 완료 노티에서 공통으로 사용할 거리 기반 제목을 생성합니다.
    func notificationTitle(for workout: HKWorkout) -> String {
        guard let distance = workout.getKilometerDistance() else {
            return "러닝 완료🔥"
        }

        return String(format: "%.2fkm 러닝 완료🔥", distance)
    }

    /// 자동 등록 노티에 표시할 신발 이름을 결정합니다.
    func shoesNotificationName(for shoes: Shoes) -> String {
        shoes.shoesName.isEmpty ? shoes.nickname : shoes.shoesName
    }
}


extension DefaultHealthBackgroundSyncService {
    /// pending 목록에서 처리 완료 또는 더 이상 유효하지 않은 workout UUID를 제거합니다.
    static func remainingPendingRunningWorkoutIDs(
        currentIDs: [String],
        removingIDs: Set<String>
    ) -> [String] {
        currentIDs.filter { !removingIDs.contains($0) }
    }
}
