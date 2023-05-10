import XCTest

final class ChatUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testCorrectProfile() throws {
        let app = XCUIApplication()
        app.launch()
        app.tabBars["Tab Bar"].buttons["Profile"].tap()
        
        let profilePhoto = app.images["Profile photo"]
        let addPhotoButton = app.buttons["Add photo button"]
        let profileName = app.staticTexts["Profile name"]

        XCTAssertTrue(profilePhoto.exists)
        XCTAssertTrue(addPhotoButton.exists)
        XCTAssertTrue(profileName.exists)
    }
}
