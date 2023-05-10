import Foundation
@testable import Chat

final class FileManagerServiceMock: FileManagerService {
    
    var invokedRead = false
    var invokedReadCount = 0
    var invokedReadParameters: (filename: String, Void)?
    var invokedReadParametersList = [(filename: String, Void)]()
    var stubbedReadCompletionResult: (Result<Data, Error>, Void)?

    func read(by filename: String, _ completion: @escaping (Result<Data, Error>) -> Void) {
        invokedRead = true
        invokedReadCount += 1
        invokedReadParameters = (filename, ())
        invokedReadParametersList.append((filename, ()))
        if let result = stubbedReadCompletionResult {
            completion(result.0)
        }
    }

    var invokedWrite = false
    var invokedWriteCount = 0
    var invokedWriteParameters: (data: Data, filename: String)?
    var invokedWriteParametersList = [(data: Data, filename: String)]()
    var stubbedWriteCompletionResult: (Error?, Void)?

    func write(_ data: Data, with filename: String, _ completion: @escaping (Error?) -> Void) {
        invokedWrite = true
        invokedWriteCount += 1
        invokedWriteParameters = (data, filename)
        invokedWriteParametersList.append((data, filename))
        if let result = stubbedWriteCompletionResult {
            completion(result.0)
        }
    }

    var invokedFileExist = false
    var invokedFileExistCount = 0
    var invokedFileExistParameters: (fileName: String, Void)?
    var invokedFileExistParametersList = [(fileName: String, Void)]()
    var stubbedFileExistResult: Bool! = false

    func fileExist(at fileName: String) -> Bool {
        invokedFileExist = true
        invokedFileExistCount += 1
        invokedFileExistParameters = (fileName, ())
        invokedFileExistParametersList.append((fileName, ()))
        return stubbedFileExistResult
    }
}
