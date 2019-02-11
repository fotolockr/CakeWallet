import UIKit
import FlexLayout

final class RestoreFromCloudView: BaseFlexView {
    let importFromCloudButton: UIButton
    let descriptionLabel: UILabel
    
    required init() {
        importFromCloudButton = PrimaryButton(title: "From iCloud")
        descriptionLabel = UILabel(fontSize: 12)
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        descriptionLabel.textColor = .lightGray
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
    }
    
    override func configureConstraints() {
        rootFlexContainer.flex.alignItems(.center).justifyContent(.center).define { flex in
            flex.addItem(importFromCloudButton).width(200).height(50)
            flex.addItem(descriptionLabel).width(80%).marginTop(50)
        }
    }
}
