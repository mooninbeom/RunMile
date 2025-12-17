//
//  WorkoutDTO.swift
//  Run Mile
//
//  Created by 문인범 on 4/18/25.
//

import Foundation
import RealmSwift


@available(*, deprecated, message: "대신 CDWorkoutDTO를 사용해주세요.\nRealm에서 CoreData로 DB가 변경되었습니다.")
final class WorkoutDTO: Object {
    @Persisted(primaryKey: true) public var id: UUID
    @Persisted public var date: Date?
    @Persisted public var distance: Double
    /// 역관계
    @Persisted(originProperty: "workouts") public var shoes: LinkingObjects<ShoesDTO>
}
