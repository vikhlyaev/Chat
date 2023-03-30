import Foundation

protocol DataManagerProtocol: AnyObject {
    func read(type: DataManagerType, completion: (Result<Data, DataManagerError>) -> Void)
    func write(_ data: Data, as type: DataManagerType, completion: (DataManagerError?) -> Void)
}

final class DataManager {
    private let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
}

// MARK: - DataManagerProtocol

extension DataManager: DataManagerProtocol {
    func read(type: DataManagerType, completion: (Result<Data, DataManagerError>) -> Void) {
        guard let url = documentDirectory?.appendingPathComponent(type.fileName) else {
            completion(.failure(.badURL))
            return
        }
        do {
            let data = try Data(contentsOf: url)
            completion(.success(data))
        } catch {
            completion(.failure(.dataReadError))
        }
    }
    
    func write(_ data: Data, as type: DataManagerType, completion: (DataManagerError?) -> Void) {
        guard let url = documentDirectory?.appendingPathComponent(type.fileName) else {
            completion(.badURL)
            return
        }
        do {
            try data.write(to: url, options: .atomic)
            completion(nil)
        } catch {
            completion(.dataWriteError)
        }
    }
}

enum DataManagerType {
    case plistData
    case photo
    
    var fileName: String {
        switch self {
        case .plistData:
            return "data.plist"
        case .photo:
            return "photo.png"
        }
    }
}

enum DataManagerError: Error {
    case badURL
    case badData
    case dataWriteError
    case dataReadError
}
