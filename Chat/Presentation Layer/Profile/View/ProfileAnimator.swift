import UIKit

final class ProfileAnimator: NSObject {
    
    enum TransitionMode {
        case present
        case dismiss
    }
    
    private let transitionMode: TransitionMode
    private let duration: CGFloat
    private var circle: UIView?
    
    init(transitionMode: TransitionMode,
         duration: CGFloat) {
        self.transitionMode = transitionMode
        self.duration = duration
    }
    
    private func frameForCircle(
        withViewCenter viewCenter: CGPoint,
        viewSize: CGSize
    ) -> CGRect {
        let xLength = fmax(viewCenter.x, viewSize.width - viewCenter.x)
        let yLength = fmax(viewCenter.y, viewSize.height - viewCenter.y)
        let offsetVector = sqrt(xLength * xLength + yLength * yLength) * 2
        let size = CGSize(width: offsetVector, height: offsetVector)
        return CGRect(origin: .zero, size: size)
    }
}

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
            
            let circleFrame = frameForCircle(
                withViewCenter: presentedView.center,
                viewSize: presentedView.frame.size
            )
            circle = UIView(frame: circleFrame)
            guard let circle else { return }
            circle.layer.cornerRadius = circle.frame.height / 2
            circle.center = presentedView.center
            circle.backgroundColor
            presentedView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            containerView.addSubview(presentedView)
            
            UIView.animate(withDuration: duration) {
                presentedView.transform = CGAffineTransform.identity
            } completion: { finished in
                transitionContext.completeTransition(finished)
            }
        case .dismiss:
            guard let dismissedView = transitionContext.view(forKey: UITransitionContextViewKey.from) else {
                transitionContext.completeTransition(false)
                return
            }
            
            containerView.addSubview(dismissedView)
            
            UIView.animate(withDuration: duration) {
                dismissedView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            } completion: { finished in
                dismissedView.removeFromSuperview()
                transitionContext.completeTransition(finished)
            }
        }
    }
}
