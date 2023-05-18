import Foundation
import UIKit

protocol ChannelViewOutput {
    func viewIsReady()
    func didSendMessage(text: String)
    func didRequestName() -> String
    func didRequestLogoUrl() -> String?
    func didRequestUserId() -> String
    func didRequestNumberOfSections() -> Int
    func didRequestNumberOfRows(inSection section: Int) -> Int
    func didRequestMessage(for indexPath: IndexPath) -> (messages: MessageModel, isLink: Bool)
    func didRequestDate(inSection section: Int) -> Date
    func didRequestImage(by imageUrl: String, completion: @escaping (Data?) -> Void)
    func didOpenPhotoSelection()
}
