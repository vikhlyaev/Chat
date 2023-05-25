import Foundation
@testable import Chat

final class NetworkServiceMock: NetworkService {

    var invokedFetch = false
    var invokedFetchCount = 0
    var invokedFetchParameters: (request: URLRequest, Void)?
    var invokedFetchParametersList = [(request: URLRequest, Void)]()
    var stubbedFetchCompletionResult: (Result<Any, Error>, Void)?

    func fetch<T: Decodable>(for request: URLRequest, _ completion: @escaping (Result<T, Error>) -> Void) {
        invokedFetch = true
        invokedFetchCount += 1
        invokedFetchParameters = (request, ())
        invokedFetchParametersList.append((request, ()))
        if let result = stubbedFetchCompletionResult {
            completion(result.0 as! Result<T, Error>)
        }
    }

    var invokedDownload = false
    var invokedDownloadCount = 0
    var invokedDownloadParameters: (request: URLRequest, Void)?
    var invokedDownloadParametersList = [(request: URLRequest, Void)]()
    var stubbedDownloadCompletionResult: (Result<Data, Error>, Void)?

    func download(with request: URLRequest, _ completion: @escaping (Result<Data, Error>) -> Void) {
        invokedDownload = true
        invokedDownloadCount += 1
        invokedDownloadParameters = (request, ())
        invokedDownloadParametersList.append((request, ()))
        if let result = stubbedDownloadCompletionResult {
            completion(result.0)
        }
    }
}
