import Foundation

struct PhotoResult: Decodable {
    let photos: [Photo]
    
    enum CodingKeys: String, CodingKey {
        case photos = "hits"
    }
}

struct Photo: Decodable {
    let id: Int
    let previewURL: String
    let webformatURL: String
    let largeImageURL: String
}
