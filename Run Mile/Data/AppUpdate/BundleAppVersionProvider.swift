import Foundation


struct BundleAppVersionProvider: AppVersionProviding {
    var currentVersion: String {
        Bundle.main.appVersion
    }
}
