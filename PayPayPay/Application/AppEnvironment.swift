import Foundation

enum AppEnvironment: String {
    case dev
    case stg
    case pro

    static let current: AppEnvironment = {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "AppEnvironment") as? String,
              let environment = AppEnvironment(rawValue: value) else {
            preconditionFailure("Missing or invalid AppEnvironment in Info.plist")
        }
        return environment
    }()

    static let apiBaseURL: URL = {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "APIBaseURL") as? String,
              let url = URL(string: value),
              let scheme = url.scheme, ["https", "http"].contains(scheme),
              let host = url.host, !host.isEmpty else {
            preconditionFailure("Missing or invalid API_BASE_URL in the environment xcconfig")
        }
        return url
    }()
}
