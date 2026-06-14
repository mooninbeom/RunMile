//
//  ChartAxisValueFactoryTests.swift
//  Run MileTests
//
//  Created by Codex on 6/14/26.
//

import Testing
@testable import Run_Mile


struct ChartAxisValueFactoryTests {
    @Test func sameXScaleReturnsSingleTick() {
        let values = ChartAxisValueFactory.xAxisValues(for: 120...120)
        
        #expect(values == [120])
    }
    
    @Test func shortXScaleDoesNotCreateDuplicateTicks() {
        let values = ChartAxisValueFactory.xAxisValues(for: 0...3)
        
        #expect(values == [0, 1, 2, 3])
    }
    
    @Test func sameYScaleReturnsPaddedDomainAndTicks() {
        let scale = ChartAxisValueFactory.safeYScale(for: 100...100)
        let values = ChartAxisValueFactory.yAxisValues(for: 100...100)
        
        #expect(scale.lowerBound < 100)
        #expect(scale.upperBound > 100)
        #expect(values.count == 5)
    }
}
