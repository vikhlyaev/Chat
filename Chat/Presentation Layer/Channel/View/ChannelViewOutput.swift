import Foundation

protocol ChannelViewOutput {
    func viewIsReady()
    func didSendMessage(text: String)
    func didRequestName() -> String
    func didRequestLogoUrl() -> String?
    func didRequestUserId() -> String
    func didRequestNumberOfSections() -> Int
    func didRequestNumberOfRows(inSection section: Int) -> Int
    func didRequestMessage(for indexPath: IndexPath) -> MessageModel
    func didRequestDate(inSection section: Int) -> Date
}
