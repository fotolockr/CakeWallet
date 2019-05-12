import UIKit
import FlexLayout

final class ProgressBar: BaseFlexView {
    let progressView: UIView
    let imageHolder: UIImageView
    let syncImage: UIImage
    var progressLabel: UILabel
    var statusLabel: UILabel
    
    required init() {
        progressView = UIView()
        imageHolder = UIImageView()
        syncImage = UIImage(named: "refresh_icon")!.resized(to: CGSize(width: 12, height: 12))
        progressLabel = UILabel(text: "0%")
        statusLabel = UILabel(text: "SYNCING BLOCKCHAIN")
        
        super.init()
        
        animateSyncImage()
    }
    
    override func configureView() {
        super.configureView()
        
        imageHolder.image = syncImage
        progressLabel.font = applyFont(ofSize: 12)
        progressLabel.textColor = UIColor.wildDarkBlue
        statusLabel.font = applyFont(ofSize: 10)
        statusLabel.textColor = UIColor.wildDarkBlue
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        progressView.layer.masksToBounds = true
        progressView.layer.cornerRadius = progressView.frame.size.height / 2
    }
    
    override func configureConstraints() {
        progressView.flex
            .direction(.row).alignItems(.center).justifyContent(.center)
            .backgroundColor(UIColor(red: 245, green: 246, blue: 249))
            .height(21)
            .define { flex in
                flex.addItem(imageHolder).marginRight(7)
                flex.addItem(statusLabel)
        }
        
        rootFlexContainer.flex
            .alignItems(.center).justifyContent(.center)
            .width(100%)
            .define { flex in
                flex.addItem(progressView).width(200)
        }
    }
    
    func updateProgress(_ progress: Int) {
        progressLabel.text = "\(progress)%"
        progressLabel.flex.markDirty()
        rootFlexContainer.flex.layout()
    }
    
    func animateSyncImage() {
        guard imageHolder.layer.animation(forKey: "rotate") == nil else {
            return
        }
        
        let animation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        animation.duration = 1.0
        animation.fillMode = kCAFillModeForwards
        animation.repeatCount = .infinity
        animation.values = [0, Double.pi / 2, Double.pi, Double.pi * 3 / 2, Double.pi * 2]
        let moments = [NSNumber(value: 0.0), NSNumber(value: 0.1),
                       NSNumber(value: 0.3), NSNumber(value: 0.8), NSNumber(value: 1.0)]
        animation.keyTimes = moments
        
        imageHolder.layer.add(animation, forKey: "rotate")
    }
}
