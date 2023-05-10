import XCTest
@testable import Chat

final class PhotoLoaderServiceTests: XCTestCase {
    
    var networkService: NetworkServiceMock!
    var photoLoaderService: PhotoLoaderService!
    
    override func setUp() {
        super.setUp()
        networkService = NetworkServiceMock()
        photoLoaderService = PhotoLoaderServiceImpl(networkService: networkService)
    }
    
    override func tearDown() {
        networkService = nil
        photoLoaderService = nil
        super.tearDown()
    }
    
    func testFetchPhotosNextPageMethod() {
        // Act
        photoLoaderService.fetchPhotosNextPage { _ in }
        
        // Assert
        XCTAssertTrue(networkService.invokedFetch)
        XCTAssertEqual(networkService.invokedFetchCount, 1)
    }
    
    func testFetchPhoto() {
        // Act
        photoLoaderService.fetchPhoto(by: "https://example.com") { _ in }
        
        // Assert
        XCTAssertTrue(networkService.invokedDownload)
        XCTAssertEqual(networkService.invokedDownloadCount, 1)
    }
    
    func testFetchPhotoData() {
        // Act
        photoLoaderService.fetchPhotoData(by: "https://example.com") { _ in }
        
        // Assert
        XCTAssertTrue(networkService.invokedDownload)
        XCTAssertEqual(networkService.invokedDownloadCount, 1)
    }
    
}
