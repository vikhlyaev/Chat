import Foundation

protocol ChannelViewInput: AnyObject {
    func showErrorAlert(with text: String)
    func updateTableView()
}
