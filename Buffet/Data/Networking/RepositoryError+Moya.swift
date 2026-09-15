import Foundation
import Moya

extension RepositoryError {
    /// Translates a transport failure into the situation the domain names.
    init(error: Error) {
        switch error {
        case let repositoryError as RepositoryError:
            self = repositoryError
        case let urlError as URLError:
            self.init(urlError: urlError)
        case let moyaError as MoyaError:
            self.init(moyaError: moyaError)
        default:
            self = .unknown
        }
    }

    private init(moyaError: MoyaError) {
        switch moyaError {
        case .jsonMapping, .objectMapping, .stringMapping:
            self = .invalidData
        case .statusCode(let response):
            self.init(statusCode: response.statusCode)
        case .underlying(let error, _):
            self.init(error: error)
        default:
            self = .rejected(message: moyaError.errorDescription ?? "")
        }
    }

    private init(urlError: URLError) {
        switch urlError.code {
        case .notConnectedToInternet:
            self = .offline
        case .cannotFindHost, .cannotConnectToHost, .dnsLookupFailed, .timedOut:
            self = .unreachable
        case .cancelled:
            self = .unknown
        default:
            self = .rejected(message: urlError.localizedDescription)
        }
    }

    /// Maps HTTP status codes onto domain situations; this is the only place that knows them.
    private init(statusCode: Int) {
        switch statusCode {
        case 401, 403:
            self = .unauthorized
        case 404:
            self = .notFound
        case 503:
            self = .underMaintenance
        case 500...599:
            self = .unavailable
        default:
            self = .unknown
        }
    }
}
