extension RepositoryError {
    /// A message that is safe to show directly to the customer.
    var errorDescription: String {
        switch self {
        case .notConnectionToInternet: "网络连接不可用，请检查网络后重试"
        case .notReachedServer: "无法连接服务器，请稍后重试"
        case .authenticationFailed: "登录状态已失效，请重新登录"
        case .serverMaintenance: "服务器正在维护，请稍后重试"
        case .serverError: "服务器开小差了，请稍后重试"
        case .notFound: "请求的内容不存在"
        case .incorrectDataReturned: "数据格式有误，请稍后重试"
        case .response(let message): message.isEmpty ? "请求失败，请稍后重试" : message
        case .unknown: "未知错误，请稍后重试"
        }
    }
}
