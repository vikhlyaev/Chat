import UIKit

final class ParticleAnimation {
    
    private weak var window: UIWindow?
    private var layer: CAEmitterLayer?
    
    private lazy var tinkoffCell: CAEmitterCell = {
        var cell = CAEmitterCell()
        cell.contents = UIImage(named: "TinkoffLogo")?.cgImage
        cell.scale = 0.05
        cell.scaleRange = 0.05
        cell.emissionRange = .pi
        cell.lifetime = 0.5
        cell.birthRate = 10
        cell.velocity = -30
        cell.velocityRange = -20
        cell.xAcceleration = 30
        cell.yAcceleration = 25
        cell.spin = -0.5
        cell.spinRange = 1.0
        return cell
    }()
    
    init(on window: UIWindow) {
        self.window = window
        setupGestureRecognizers()
    }
    
    private func createLayer(position: CGPoint, size: CGSize) -> CAEmitterLayer {
        let logosLayer = CAEmitterLayer()
        logosLayer.emitterPosition = position
        logosLayer.emitterSize = size
        logosLayer.emitterShape = .point
        logosLayer.beginTime = CACurrentMediaTime()
        logosLayer.timeOffset = CFTimeInterval(Int.random(in: 0...6) + 5)
        logosLayer.emitterCells = [tinkoffCell]
        return logosLayer
    }
    
    private func setupGestureRecognizers() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizerAction))
        tapRecognizer.cancelsTouchesInView = false
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        longPressRecognizer.cancelsTouchesInView = false
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        panRecognizer.cancelsTouchesInView = false

        guard let window else { return }
        window.addGestureRecognizer(tapRecognizer)
        window.addGestureRecognizer(longPressRecognizer)
        window.addGestureRecognizer(panRecognizer)
    }
    
    @objc
    private func tapGestureRecognizerAction(_ gestureRecognizer: UIGestureRecognizer) {
        guard let window else { return }
        
        let position = gestureRecognizer.location(in: gestureRecognizer.view?.window)
        let logosLayer = createLayer(
            position: position,
            size: window.bounds.size
        )
        window.layer.addSublayer(logosLayer)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            logosLayer.removeFromSuperlayer()
        }
    }
    
    @objc
    private func panGestureRecognizerAction(_ gestureRecognizer: UIGestureRecognizer) {
        guard let window else { return }
        
        let position = gestureRecognizer.location(in: gestureRecognizer.view)
        
        switch gestureRecognizer.state {
        case .began:
            let logosLayer = createLayer(
                position: position,
                size: window.bounds.size
            )
            window.layer.addSublayer(logosLayer)
            layer = logosLayer
        case .changed:
            layer?.emitterPosition = position
        case .ended, .cancelled:
            layer?.removeFromSuperlayer()
        case .failed, .possible:
            break
        default:
            break
        }
    }
}
