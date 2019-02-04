import UIKit

final class RestoreFromCloudView: BaseFlexView {
    let importFromCloudButton: UIButton
    
    required init() {
        importFromCloudButton = PrimaryButton(title: "From iCloud")
        super.init()
    }
    
    override func configureConstraints() {
        rootFlexContainer.flex.alignItems(.center).justifyContent(.center).define { flex in
            flex.addItem(importFromCloudButton).width(200).height(50)
        }
    }
}
