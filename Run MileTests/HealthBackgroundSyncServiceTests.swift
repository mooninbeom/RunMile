//
//  HealthBackgroundSyncServiceTests.swift
//  Run MileTests
//
//  Created by Codex on 6/14/26.
//

import Testing
@testable import Run_Mile


struct HealthBackgroundSyncServiceTests {
    @Test func remainingPendingWorkoutIDsRemovesProcessedAndInvalidIDs() {
        let currentIDs = ["valid-1", "deleted", "valid-2", "malformed"]
        let removingIDs: Set<String> = ["deleted", "malformed"]
        
        let result = DefaultHealthBackgroundSyncService.remainingPendingRunningWorkoutIDs(
            currentIDs: currentIDs,
            removingIDs: removingIDs
        )
        
        #expect(result == ["valid-1", "valid-2"])
    }
}
