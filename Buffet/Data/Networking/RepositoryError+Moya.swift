import Foundation
import Moya

extension RepositoryError {
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
            self = .incorrectDataReturned
        case .statusCode(let response):
            self.init(statusCode: response.statusCode)
        case .underlying(let error, _):
            self.init(error: error)
        default:
            self = .response(message: moyaError.errorDescription ?? "")
        }
    }

    private init(urlError: URLError) {
        switch urlError.code {
        case .notConnectedToInternet:
            self = .notConnectionToInternet
        case .cannotFindHost, .cannotConnectToHost, .dnsLookupFailed, .timedOut:
            self = .notReachedServer
        case .cancelled:
            self = .unknown
        default:
            self = .response(message: urlError.localizedDescription)
        }
    }

    private init(statusCode: Int) {
        switch statusCode {
        case 500...502, 504...599:
            self = .serverError
        case 503:
            self = .serverMaintenance
        case 404:
            self = .notFound
        case 401, 403:
            self = .authenticationFailed
        default:
            self = .unknown
        }
    }
}
