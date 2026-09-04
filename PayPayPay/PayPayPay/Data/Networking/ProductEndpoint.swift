import Foundation
import Moya

enum ProductEndpoint: TargetType {
    case products(baseURL: URL, page: Int)

    var baseURL: URL {
        switch self { case .products(let baseURL, _): return baseURL }
    }
    var path: String { "/goods" }
    var method: Moya.Method { .get }
    var task: Moya.Task {
        switch self {
        case .products(_, let page):
            // Preserve the existing API parameter contract during this migration.
            return .requestParameters(parameters: [path: page], encoding: URLEncoding.default)
        }
    }
    var headers: [String: String]? { nil }
    var sampleData: Data {
        guard let url = Bundle.main.url(forResource: "Products", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return Data() }
        return data
    }
}
