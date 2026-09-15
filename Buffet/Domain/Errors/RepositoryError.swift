/// Why a data operation failed, named after the situation the caller has to act on.
///
/// The cases describe outcomes rather than transports, so `Data` owns the translation from HTTP
/// status codes and `Presentation` owns the copy. Adding a case here means the app gained a new
/// way to react, not that the backend started returning a new code.
enum RepositoryError: Error, Equatable {
    /// The device has no usable connection; the request cannot succeed until it comes back.
    case offline
    /// The server could not be reached or did not answer in time; retrying may succeed.
    case unreachable
    /// The service is temporarily unable to serve the request.
    case unavailable
    /// The service refused the request because it is under maintenance.
    case underMaintenance
    /// The session is no longer valid; the customer has to sign in again.
    case unauthorized
    /// The requested item does not exist.
    case notFound
    /// The payload could not be understood or did not satisfy the domain's contract.
    case invalidData
    /// The service rejected the request and supplied text for the customer.
    case rejected(message: String)
    /// A failure the app cannot classify.
    case unknown
}
