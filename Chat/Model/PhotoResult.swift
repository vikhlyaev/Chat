import Foundation

struct PhotoResult: Decodable {
    let photos: [PhotoModel]
    
    enum CodingKeys: String, CodingKey {
        case photos = "hits"
    }
}

struct PhotoModel: Decodable, Hashable {
    let id: Int
    let previewURL: String
    let webformatURL: String
    let largeImageURL: String
}
