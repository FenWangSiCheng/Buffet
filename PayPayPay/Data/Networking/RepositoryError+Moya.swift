import Foundation
import Moya

extension RepositoryError {
    init(error: Error) {
        if let repositoryError = error as? RepositoryError {
            self = repositoryError
        } else if let urlError = error as? URLError {
            self.init(urlError: urlError)
        } else if let moyaError = error as? MoyaError {
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
        } else {
            self = .unknown
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
