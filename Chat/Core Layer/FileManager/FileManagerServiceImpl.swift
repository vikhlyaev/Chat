import Foundation

final class FileManagerServiceImpl {
    private let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    
    private func prepareUrl(for filename: String) throws -> URL {
        guard let url = documentDirectory?.appendingPathComponent(filename) else {
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
        } catch {
            completion(.failure(FileManagerServiceError.badData))
        }
    }
    
    func write(_ data: Data, with filename: String, _ completion: @escaping (Error?) -> Void) {
        do {
            let url = try prepareUrl(for: filename)
            try data.write(to: url, options: .atomic)
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    func fileExist(at fileName: String) -> Bool {
        guard let url = try? prepareUrl(for: fileName) else { return false }
        return FileManager.default.fileExists(atPath: url.path)
    }
}
