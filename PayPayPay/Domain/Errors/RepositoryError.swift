enum RepositoryError: Error, Equatable {

    // Unknown
    case unknown

    // Not connected to Internet
    case notConnectionToInternet

    // Cannot connect to server (DNS Failed,Timeout,etc.)
    case notReachedServer

    // Incorrect data returned from the server
    case incorrectDataReturned

    // 403 401 - Authentication failed
    case authenticationFailed

    // 503 - Server maintenance
    case serverMaintenance

    // 500 - Server error
    case serverError

    // 404 - Not found
    case notFound

    case response(message: String)

}
