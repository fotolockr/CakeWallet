import UIKit
import FlexLayout

final class ProgressBar: BaseFlexView {
    let progressView: UIView
    
    required init() {
        progressView = UIView()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rootFlexContainer.layer.masksToBounds = true
        rootFlexContainer.layer.cornerRadius = frame.size.height / 2
    }
    
    override func configureConstraints() {
        rootFlexContainer.flex.backgroundColor(Theme.current.progressBar.background).height(100%).define { flex in
            flex.addItem(progressView).height(100%).backgroundColor(Theme.current.progressBar.value).width(0%)
        }
    }
    
    func updateProgress(_ progress: Int) {
        progressView.flex.width(progress%)
        progressView.flex.markDirty()
        rootFlexContainer.flex.layout()
    }
}
