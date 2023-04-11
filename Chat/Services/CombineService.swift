import UIKit
import Dispatch
import Combine

final class CombineService {
    private let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    var photoPublisher = CurrentValueSubject<UIImage?, Never>(UIImage(named: "PlaceholderAvatar"))
    var profilePublisher = PassthroughSubject<ProfileViewModel, Never>()
    private var profileRequest: Cancellable?
    private var photoRequest: Cancellable?
    
    init() {
        profileRequest = profilePublisher
            .encode(encoder: PropertyListEncoder())
            .subscribe(on: DispatchQueue.main)
            .receive(on: DispatchQueue.global(qos: .utility))
            .sink(receiveCompletion: { completion in
                print(completion)
            }, receiveValue: { [weak self] profile in
                guard let url = self?.documentDirectory?.appendingPathComponent("profile.plist") else { return }
                try? profile.write(to: url)
            })
        
        photoRequest = photoPublisher
            .map({ $0?.pngData() ?? Data() })
            .subscribe(on: DispatchQueue.main)
            .receive(on: DispatchQueue.global(qos: .utility))
            .sink(receiveCompletion: { completion in
                print(completion)
            }, receiveValue: { [weak self] photo in
                guard let url = self?.documentDirectory?.appendingPathComponent("photo.png") else { return }
                try? photo.write(to: url)
            })
    }
    
    private func readPublisher(type: DataType) -> AnyPublisher<Data, Error> {
        Deferred {
            Future { promise in
                guard let url = self.documentDirectory?.appendingPathComponent(type.fileName) else {
                    promise(.failure(CombineServiceError.badURL))
                    return
                }
                do {
                    let data = try Data(contentsOf: url)
                    promise(.success(data))
                } catch {
                    promise(.failure(CombineServiceError.dataReadError))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    private func loadProfile(completion: @escaping (Result<ProfileViewModel, Error>) -> Void) {
        var resultProfile = ProfileViewModel()

        let loadProfileData = readPublisher(type: .plistData)
            .decode(type: ProfileViewModel.self, decoder: PropertyListDecoder())
            
        let loadProfilePhoto = readPublisher(type: .photo)
            .map({ UIImage(data: $0) })
           
        _ = Publishers.CombineLatest(loadProfileData, loadProfilePhoto)
                .sink(receiveCompletion: { completion in
                    print(completion)
                }, receiveValue: { [weak self] profile, photo in
                    resultProfile = profile
                    resultProfile.photo = photo
                    self?.updatePhoto(photo)
                })
        
        completion(.success(resultProfile))
    }
    
    func loadProfilePublisher() -> AnyPublisher<ProfileViewModel, Error> {
        Deferred {
            Future(self.loadProfile)
        }.eraseToAnyPublisher()
    }
    
    func updatePhoto(_ photo: UIImage?) {
        photoPublisher.send(photo)
    }
    
    func saveProfile(_ profile: ProfileViewModel) {
        profilePublisher.send(profile)
    }
}

enum DataType {
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

enum CombineServiceError: Error {
    case decodingError
    case encodingError
    case badURL
    case badData
    case dataWriteError
    case dataReadError
}
