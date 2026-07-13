import Foundation


actor UserDefaultsAppUpdatePreferenceStore: AppUpdatePreferenceStore {
    func dismissedVersion() -> String? {
        UserDefaults.standard.string(forKey: UserDefaults.Key.dismissedAppUpdateVersion)
    }

    func saveDismissedVersion(_ version: String) {
        UserDefaults.standard.set(version, forKey: UserDefaults.Key.dismissedAppUpdateVersion)
    }
}
