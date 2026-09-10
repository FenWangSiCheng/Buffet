enum RepositoryError: Error, Equatable {
    case unknown
    case notConnectionToInternet
    case notReachedServer
    case incorrectDataReturned
    case authenticationFailed
    case serverMaintenance
    case serverError
    case notFound
    case response(message: String)
}
