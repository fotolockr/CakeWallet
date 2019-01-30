import UIKit

final class RestoreFromCloudView: BaseFlexView {
    let importFromCloudButton: UIButton
    let importFromFileButton: UIButton
    
    required init() {
        importFromCloudButton = PrimaryButton(title: "From iCloud")
        importFromFileButton = SecondaryButton(title: "From file")
        super.init()
    }
    
    override func configureConstraints() {
        rootFlexContainer.flex.alignItems(.center).justifyContent(.center).define { flex in
            flex.addItem(importFromCloudButton).width(200).height(50)
            flex.addItem(importFromFileButton).width(200).marginTop(20).height(50)
        }
    }
}
