import XCTest
@testable import Chat

final class ProfileServiceTests: XCTestCase {
    
    var fileManagerService: FileManagerServiceMock!
    var coreDataService: CoreDataServiceMock!
    var profileService: ProfileService!
    
    override func setUp() {
        super.setUp()
        fileManagerService = FileManagerServiceMock()
        coreDataService = CoreDataServiceMock()
        profileService = ProfileServiceImpl(coreDataService: coreDataService, fileManagerService: fileManagerService)
    }
    
    override func tearDown() {
        profileService = nil
        fileManagerService = nil
        coreDataService = nil
        super.tearDown()
    }
    
    func testLoadProfile() {
        // Act
        profileService.loadProfile { result in
            switch result {
            case .success(let profile):
                XCTAssertNotNil(profile)
            case .failure(let error):
                XCTAssertThrowsError(error)
            }
        }
        
        // Assert
        XCTAssertTrue(coreDataService.invokedFetchProfile)
        XCTAssertEqual(coreDataService.invokedFetchProfileCount, 1)
    }
    
    func testSaveProfile() {
        // Arrange
        let profile = ProfileModel(id: "111", name: "Aaa", information: "Bbb")
        let expectation = expectation(description: "DispatchQueue.global()")
        
        // Act
        DispatchQueue.global(qos: .utility).async {
            self.profileService.saveProfile(profile) { _ in }
            expectation.fulfill()
        }
    
        // Assert
        wait(for: [expectation], timeout: 3)
        XCTAssertTrue(coreDataService.invokedUpdate)
        XCTAssertEqual(coreDataService.invokedUpdateCount, 1)
    }
    
}
