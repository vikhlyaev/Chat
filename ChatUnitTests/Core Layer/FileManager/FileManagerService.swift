import XCTest
@testable import Chat

final class FileManagerServiceTests: XCTestCase {

    var fileManagerService: FileManagerService!
    let filename = "Aaa"
    
    override func setUp() {
        super.setUp()
        fileManagerService = FileManagerServiceImpl()
    }
    
    override func tearDown() {
        fileManagerService = nil
        super.tearDown()
    }
    
    func testWriteMethod() {
        // Act
        fileManagerService.write(Data(), with: filename) { error in
            if error != nil {
                // Assert
                XCTAssertThrowsError(error)
            } else {
                // Assert
                XCTAssertNil(error)
            }
        }
    }
    
    func testReadMethod() {
        // Act
        fileManagerService.read(by: filename) { result in
            switch result {
            case .success(let data):
                // Assert
                XCTAssertNotNil(data)
            case .failure(let error):
                // Assert
                XCTAssertThrowsError(error)
            }
        }
    }
    
    func testFileExist() {
        // Act
        let result = fileManagerService.fileExist(at: filename)
        
        // Assert
        XCTAssertTrue(result)
    }
}
