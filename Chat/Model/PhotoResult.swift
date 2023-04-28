import Foundation

struct PhotoResult: Decodable {
    let photos: [Photo]
}

struct Photo: Decodable {
    let id: Int
    let previewURL: String
    let webformatURL: String
    let largeImageURL: String
}
