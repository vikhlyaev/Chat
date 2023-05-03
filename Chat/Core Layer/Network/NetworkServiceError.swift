import Foundation

enum NetworkServiceError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case parsingJsonError(Error)
    case invalidRequest
    case invalidData
    case invalidUrl
}
