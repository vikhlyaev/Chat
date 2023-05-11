import XCTest
@testable import Chat

final class PhotoLoaderServiceTests: XCTestCase {
    
    var networkService: NetworkServiceMock!
    var fileManagerService: FileManagerServiceMock!
    var photoLoaderService: PhotoLoaderService!
    
    override func setUp() {
        super.setUp()
        networkService = NetworkServiceMock()
        fileManagerService = FileManagerServiceMock()
        photoLoaderService = PhotoLoaderServiceImpl(
            networkService: networkService,
            fileManagerService: fileManagerService
        )
    }
    
    override func tearDown() {
        networkService = nil
        fileManagerService = nil
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
    
    func testFetchPhotoSuccess() {
        networkService.stubbedDownloadCompletionResult = (
            Result.success(
                (UIImage(named: "PlaceholderPhoto")?.pngData()!)!
            ), ()
        )
        
        // Act
        photoLoaderService.fetchPhoto(by: "https://example.com") { result in
            switch result {
            case .success(let success):
                XCTAssertNil(success)
            case .failure(let failure):
                XCTAssertThrowsError(failure)
            }
        }
        
        // Assert
        XCTAssertTrue(networkService.invokedDownload)
        XCTAssertEqual(networkService.invokedDownloadCount, 1)
    }
    
    func testFetchPhotoFailure() {
        networkService.stubbedDownloadCompletionResult = (
            Result.failure(PhotoLoaderError.incorrectData), ()
        )
        
        // Act
        photoLoaderService.fetchPhoto(by: "https://example.com") { result in
            switch result {
            case .success(let success):
                XCTAssertNil(success)
            case .failure(let failure):
                XCTAssertThrowsError(failure)
            }
        }
        
        // Assert
        XCTAssertTrue(fileManagerService.invokedFileExist)
        XCTAssertEqual(fileManagerService.invokedFileExistCount, 1)
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
