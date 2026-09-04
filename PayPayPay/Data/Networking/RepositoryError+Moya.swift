import Foundation
import Moya

extension RepositoryError {
    init(error: Error) {
        if let moyaError = error as? MoyaError {
            switch moyaError {
            case .jsonMapping, .objectMapping, .stringMapping:
                self = .incorrectDataReturned
            case .statusCode(let response):
                self.init(statusCode: response.statusCode)
            case .underlying(let nsError as NSError, _):
                self.init(statusCode: nsError.code)
            default:
                self = .response(message: moyaError.errorDescription ?? "")
            }
        } else if let netWorkError = error as? RepositoryError {
            self = netWorkError
        } else {
            self = .unknown
        }
    }

    private init(statusCode: Int) {
        switch statusCode {
        case 500...502, 504...505:
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
