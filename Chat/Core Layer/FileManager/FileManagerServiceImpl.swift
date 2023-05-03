import Foundation

final class FileManagerServiceImpl {
    private let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    private let logService: LogService
    
    init(logService: LogService) {
        self.logService = logService
    }
    
    private func prepareUrl(for filename: String) throws -> URL {
        guard let url = documentDirectory?.appendingPathComponent(filename) else {
            logService.error("Unable to create a URL")
            throw FileManagerServiceError.badUrl
        }
        return url
    }
}

extension FileManagerServiceImpl: FileManagerService {
    func read(by filename: String, _ completion: @escaping (Result<Data, Error>) -> Void) {
        do {
            let url = try prepareUrl(for: filename)
            let data = try Data(contentsOf: url)
            completion(.success(data))
            logService.success("Data successfully read")
        } catch {
            completion(.failure(FileManagerServiceError.badData))
            logService.error("Data not read. Error: \(error)")
        }
    }
    
    func write(_ data: Data, with filename: String, _ completion: @escaping (Error?) -> Void) {
        do {
            let url = try prepareUrl(for: filename)
            try data.write(to: url, options: .atomic)
            completion(nil)
            logService.success("Data successfully write")
        } catch {
            completion(error)
            logService.error("Data not write. Error: \(error)")
        }
    }
    
    func fileExist(at fileName: String) -> Bool {
        guard let url = try? prepareUrl(for: fileName) else { return false }
        return FileManager.default.fileExists(atPath: url.path)
    }
}

enum FileManagerServiceError: Error {
    case badUrl
    case badData
}
