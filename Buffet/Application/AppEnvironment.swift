import Foundation

enum AppEnvironment: String {
    case dev
    case stg
    case pro

    static let current: AppEnvironment = {
        let rawValue = requiredString("AppEnvironment")
        guard let environment = AppEnvironment(rawValue: rawValue) else {
            preconditionFailure("Invalid AppEnvironment in Info.plist: \(rawValue)")
        }
        return environment
    }()

    static let apiBaseURL: URL = {
        let value = requiredString("APIBaseURL")
        guard let url = URL(string: value),
              let scheme = url.scheme, ["https", "http"].contains(scheme),
              let host = url.host, !host.isEmpty else {
            preconditionFailure("Missing or invalid API_BASE_URL in the environment xcconfig")
        }
        return url
    }()

    /// Reads a value that the build settings inject into Info.plist, failing fast when it is absent.
    private static func requiredString(_ key: String) -> String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String else {
            preconditionFailure("Missing \(key) in Info.plist")
        }
        return value
    }
}
