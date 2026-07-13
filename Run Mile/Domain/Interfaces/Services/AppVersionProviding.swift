import Foundation


protocol AppVersionProviding: Sendable {
    var currentVersion: String { get }
}
