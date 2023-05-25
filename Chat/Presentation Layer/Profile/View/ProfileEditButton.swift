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
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = -(CGFloat.pi / 180 * 18)
        rotateAnimation.toValue = CGFloat.pi / 180 * 18
        
        let moveUpDownAnimation = CAKeyframeAnimation(keyPath: "position.y")
        moveUpDownAnimation.values = [
            layer.position.y,
            layer.position.y - 5,
            layer.position.y + 5,
            layer.position.y
        ]
        moveUpDownAnimation.keyTimes = [0, 0.25, 0.75, 1]
        
        let moveLeftRightAnimation = CAKeyframeAnimation(keyPath: "position.x")
        moveLeftRightAnimation.values = [
            layer.position.x,
            layer.position.x + 5,
            layer.position.x - 5,
            layer.position.x
        ]
        moveLeftRightAnimation.keyTimes = [0, 0.25, 0.75, 1]
        
        let animationGroup = CAAnimationGroup()
        animationGroup.autoreverses = true
        animationGroup.repeatCount = .infinity
        animationGroup.duration = 0.3
        animationGroup.animations = [moveUpDownAnimation, moveLeftRightAnimation, rotateAnimation]
        
        layer.add(animationGroup, forKey: "StartEditAnimation")
    }
    
    private func stopEditButtonAnimation() {
        guard let presentationLayer = layer.presentation() else { return }
        layer.removeAllAnimations()
        
        let rotateAnimation = CAKeyframeAnimation()
        rotateAnimation.keyPath = "transform.rotation"
        rotateAnimation.values = [presentationLayer.value(forKeyPath: "transform.rotation.z") ?? 0, 0]
        rotateAnimation.keyTimes = [0, 1]
        
        let moveAnimation = CAKeyframeAnimation()
        moveAnimation.keyPath = "position"
        moveAnimation.values = [
            presentationLayer.position,
            center
        ]
        moveAnimation.keyTimes = [0, 1]
        
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [rotateAnimation, moveAnimation]
        animationGroup.duration = 0.3
        animationGroup.fillMode = .both
        
        layer.add(animationGroup, forKey: "StopEditAnimation")
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
