import UIKit

final class ProfileEditButton: UIButton {
    
    private var isAnimatesEditButton = false
    
    private var completion: (() -> Void)?
    
    convenience init(type buttonType: UIButton.ButtonType, andTitle title: String, _ completion: @escaping () -> Void) {
        self.init(type: buttonType)
        self.completion = completion
        setTitle(title, for: .normal)
        setupView()
        setupGestureRecognizers()
        
        
        
        
        
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        setTitleColor(.white, for: .normal)
        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        backgroundColor = .systemBlue
        layer.cornerRadius = 14
        titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupGestureRecognizers() {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(buttonLongPressed))
        longPressRecognizer.cancelsTouchesInView = true
        addGestureRecognizer(longPressRecognizer)
    }
    
    private func startEditButtonAnimation() {
        let rotate = CABasicAnimation(keyPath: "transform.rotation")
        rotate.fromValue = -(CGFloat.pi / 180 * 18)
        rotate.toValue = CGFloat.pi / 180 * 18
        
        let moveUpDown = CAKeyframeAnimation(keyPath: "position.y")
        moveUpDown.values = [
            layer.position.y,
            layer.position.y - 5,
            layer.position.y + 5,
            layer.position.y
        ]
        moveUpDown.keyTimes = [0, 0.25, 0.75, 1]
        
        let moveLeftRight = CAKeyframeAnimation(keyPath: "position.x")
        moveLeftRight.values = [
            layer.position.x,
            layer.position.x + 5,
            layer.position.x - 5,
            layer.position.x
        ]
        moveLeftRight.keyTimes = [0, 0.25, 0.75, 1]
        
        let animationGroup = CAAnimationGroup()
        animationGroup.autoreverses = true
        animationGroup.repeatCount = .infinity
        animationGroup.duration = 0.3
        animationGroup.animations = [moveUpDown, moveLeftRight, rotate]
        
        layer.add(animationGroup, forKey: "EditAnimation")
    }
    
    private func stopEditButtonAnimation() {
        UIView.animate(withDuration: 2, delay: 0, options: [.beginFromCurrentState]) {
            self.layer.removeAllAnimations()
        }
    }
    
    @objc
    private func buttonLongPressed(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == .began {
            isAnimatesEditButton = !isAnimatesEditButton
            if isAnimatesEditButton {
                startEditButtonAnimation()
            } else {
                stopEditButtonAnimation()
            }
        } else {
            return
        }
    }
    
    @objc
    private func buttonTapped() {
        completion?()
    }
}
