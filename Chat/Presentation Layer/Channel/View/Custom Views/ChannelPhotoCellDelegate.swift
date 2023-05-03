import UIKit

protocol ChannelPhotoCellDelegate: AnyObject {
    func didRecieveImage(by imageUrl: String, _ completion: @escaping (UIImage?) -> Void)
}
