extension RepositoryError {
    func errorDescription() -> String {
        switch self {
        case .unknown: return "未知错误"
        default: return "网络请求失败"
        }
    }
}
