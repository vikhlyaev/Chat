import UIKit

final class ProfileAnimator: NSObject {
    enum TransitionMode {
        case present
        case dismiss
    }
    
    private let transitionMode: TransitionMode
    private let duration: CGFloat
    
    init(transitionMode: TransitionMode,
         duration: CGFloat) {
        self.transitionMode = transitionMode
        self.duration = duration
    }
}

// MARK: - UIViewControllerAnimatedTransitioning

extension ProfileAnimator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        switch transitionMode {
        case .present:
            guard let presentedView = transitionContext.view(forKey: UITransitionContextViewKey.to) else {
                transitionContext.completeTransition(false)
                return
            }
            presentedView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            presentedView.alpha = 0
            containerView.addSubview(presentedView)
            UIView.animate(withDuration: duration) {
                presentedView.transform = CGAffineTransform.identity
                presentedView.alpha = 1
                presentedView.backgroundColor = .appBackground
            } completion: { finished in
                transitionContext.completeTransition(finished)
            }
        case .dismiss:
            guard let dismissedView = transitionContext.view(forKey: UITransitionContextViewKey.from) else {
                transitionContext.completeTransition(false)
                return
            }
            dismissedView.alpha = 1
            containerView.addSubview(dismissedView)
            UIView.animate(withDuration: duration) {
                dismissedView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                dismissedView.alpha = 0
            } completion: { finished in
                dismissedView.removeFromSuperview()
                transitionContext.completeTransition(finished)
            }
        }
    }
}
