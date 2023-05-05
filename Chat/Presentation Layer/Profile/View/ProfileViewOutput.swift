import UIKit

protocol ProfileViewOutput {
    func viewIsReady()
    func didTakePhoto()
    func didChooseFromGallery()
    func didLoadFromNetwork()
    func didOpenProfileEdit(with transitioningDelegate: UIViewControllerTransitioningDelegate)
}
