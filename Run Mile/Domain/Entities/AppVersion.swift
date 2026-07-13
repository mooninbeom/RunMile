import Foundation


struct AppVersion: Comparable, Sendable {
    private let components: [Int]

    init?(_ rawValue: String) {
        let segments = rawValue.split(separator: ".", omittingEmptySubsequences: false)
        guard !segments.isEmpty else { return nil }

        var components: [Int] = []
        components.reserveCapacity(segments.count)

        for segment in segments {
            guard !segment.isEmpty,
                  segment.utf8.allSatisfy({ (48...57).contains($0) }),
                  let component = Int(segment) else {
                return nil
            }
            components.append(component)
        }

        while components.count > 1, components.last == 0 {
            components.removeLast()
        }
        self.components = components
    }

    static func < (lhs: AppVersion, rhs: AppVersion) -> Bool {
        lhs.components.lexicographicallyPrecedes(rhs.components)
    }
}
