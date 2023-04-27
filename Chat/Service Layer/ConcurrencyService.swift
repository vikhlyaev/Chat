import UIKit
import Dispatch
import Combine

protocol ConcurrencyServiceProtocol: AnyObject {
    var profileSubject: PassthroughSubject<ProfileViewModel, Error> { get set }
    var photoSubject: CurrentValueSubject<UIImage?, Error> { get set }
    func profilePublisher() -> AnyPublisher<ProfileViewModel, Error>
}

final class ConcurrencyService {
    private let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    private var cancellables = Set<AnyCancellable>()
    
    var profileSubject = PassthroughSubject<ProfileViewModel, Error>()
    var photoSubject = CurrentValueSubject<UIImage?, Error>(UIImage(named: "PlaceholderAvatar"))
    
    init() {
        profilePublisher()
            .sink { completion in
                print(completion)
            } receiveValue: { profile in
                self.profileSubject.send(profile)
                self.photoSubject.send(profile.photo)
            }
            .store(in: &cancellables)
        
        profileSubject
            .encode(encoder: PropertyListEncoder())
            .subscribe(on: DispatchQueue.main)
            .receive(on: DispatchQueue.global(qos: .utility))
            .sink { _ in
                print("profile saved")
            } receiveValue: { [weak self] profileData in
                guard
                    let url = self?.documentDirectory?.appendingPathComponent(DataType.plistData.fileName)
                else {
                    return
                }
                try? profileData.write(to: url)
            }
            .store(in: &cancellables)
        
        photoSubject
            .map({ $0?.pngData() ?? Data() })
            .subscribe(on: DispatchQueue.main)
            .receive(on: DispatchQueue.global(qos: .utility))
            .sink(receiveCompletion: { _ in
                print("photo saved")
            }, receiveValue: { [weak self] photo in
                guard let url = self?.documentDirectory?.appendingPathComponent(DataType.photo.fileName) else { return }
                try? photo.write(to: url)
            })
            .store(in: &cancellables)
    }

}

// MARK: - ConcurrencyServiceProtocol

extension ConcurrencyService: ConcurrencyServiceProtocol {
    private func readPublisher(type: DataType) -> AnyPublisher<Data, Error> {
        Deferred {
            Future { promise in
                guard let url = self.documentDirectory?.appendingPathComponent(type.fileName) else {
                    promise(.failure(ConcurrencyServiceError.badUrl))
                    return
                }
                do {
                    let data = try Data(contentsOf: url)
                    promise(.success(data))
                } catch {
                    promise(.failure(ConcurrencyServiceError.dataReadError))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func profilePublisher() -> AnyPublisher<ProfileViewModel, Error> {
        Deferred {
            Future { promise in
                var resultProfile = ProfileViewModel()
                
                let loadProfileData = self.readPublisher(type: .plistData)
                    .decode(type: ProfileViewModel.self, decoder: PropertyListDecoder())
                    
                let loadProfilePhoto = self.readPublisher(type: .photo)
                    .map({ UIImage(data: $0) })
                   
                _ = Publishers.CombineLatest(loadProfileData, loadProfilePhoto)
                        .sink(receiveCompletion: { completion in
                            switch completion {
                            case .finished:
                                print("profile loaded")
                            case .failure(let error):
                                promise(.failure(error))
                            }
                        }, receiveValue: { [weak self] profile, photo in
                            resultProfile = profile
                            resultProfile.photo = photo
                            self?.photoSubject.send(photo)
                        })
                
                promise(.success(resultProfile))
            }
        }.eraseToAnyPublisher()
    }
}

enum ConcurrencyServiceError: Error {
    case decodingError
    case encodingError
    case badUrl
    case dataReadError
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
