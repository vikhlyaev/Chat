import Foundation

protocol DataManagerProtocol: AnyObject {
    func read(_ type: DataType, completion: @escaping (Result<Data, DataManagerError>) -> Void)
    func write(_ element: Data, as type: DataType, completion: @escaping (DataManagerError?) -> Void)
}

final class DataManager {
    private let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
}

// MARK: - DataManagerProtocol

extension DataManager: DataManagerProtocol {
    func read(_ type: DataType, completion: @escaping (Result<Data, DataManagerError>) -> Void) {
        guard let url = documentDirectory?.appendingPathComponent(type.fileName) else {
            completion(.failure(.badURL))
            return
        }
        do {
            let data = try Data(contentsOf: url)
            completion(.success(data))
        } catch {
            completion(.failure(.readFailure))
        }
    }
    
    func write(_ element: Data, as type: DataType, completion: @escaping (DataManagerError?) -> Void) {
        guard let url = documentDirectory?.appendingPathComponent(type.fileName) else {
            completion(.badURL)
            return
        }
        do {
            try element.write(to: url, options: .atomic)
            completion(nil)
        } catch {
            completion(.writeFailure)
        }
    }
}

enum DataType {
    case name
    case information
    case photo
    case theme
    
    var fileName: String {
        switch self {
        case .name:
            return "name.txt"
        case .information:
            return "information.txt"
        case .photo:
            return "photo.txt"
        case .theme:
            return "theme.txt"
        }
    }
}

enum DataManagerError: Error {
    case badURL
    case writeFailure
    case readFailure
}
