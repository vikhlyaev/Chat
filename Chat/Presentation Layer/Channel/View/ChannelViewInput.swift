import UIKit

protocol ChannelViewInput: AnyObject {
    func showAlert(_ alert: UIViewController)
    func updateTableView()
}
