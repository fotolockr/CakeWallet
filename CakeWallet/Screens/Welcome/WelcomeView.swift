import UIKit
import FlexLayout

final class WelcomeView: BaseScrollFlexViewWithBottomSection {
    let logoImage: UIImageView
    let titleContainer: UIView
    let bodyContainer: UIView
    let welcomeLabel: UILabel
    let welcomeSubtitleLabel: UILabel
    let descriptionTextView: UITextView
    let buttonsContiner: UIView
    let createWalletButton: UIButton
    let restoreButton: UIButton
    
    required init() {
        logoImage = UIImageView(image: UIImage(named: "welcome_image"))
        welcomeLabel = UILabel()
        welcomeSubtitleLabel = UILabel()
        titleContainer = UIView()
        bodyContainer = UIView()
        
        descriptionTextView = UITextView()
        buttonsContiner = UIView()
        createWalletButton = PrimaryButton(title: NSLocalizedString("create_new", comment: ""))
        restoreButton = SecondaryButton(title: NSLocalizedString("restore", comment: ""))
    
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        
        welcomeLabel.font = applyFont(ofSize: 26, weight: .bold)
        welcomeLabel.textAlignment = NSTextAlignment.center
        welcomeLabel.numberOfLines = 0
        
        welcomeSubtitleLabel.font = applyFont(ofSize: 22)
        welcomeSubtitleLabel.textAlignment = NSTextAlignment.center
        welcomeSubtitleLabel.numberOfLines = 0
        welcomeSubtitleLabel.textColor = UIColor(red: 126, green: 147, blue: 177)
        
        descriptionTextView.font = applyFont(ofSize: 16)
        descriptionTextView.textAlignment = NSTextAlignment.center
        descriptionTextView.textColor = UIColor(red: 126, green: 147, blue: 177)
        descriptionTextView.isEditable = false
        descriptionTextView.layer.masksToBounds = true
        descriptionTextView.backgroundColor = .clear
        descriptionTextView.layer.cornerRadius = 10
        descriptionTextView.isScrollEnabled = false
    }
    
    override func configureConstraints() {
        let deviceHeight = bounds.size.height
        
        print(deviceHeight)
        
        titleContainer.flex.alignItems(.center).define { flex in
            flex.addItem(welcomeLabel).marginBottom(10)
            flex.addItem(welcomeSubtitleLabel)
        }
        
        bodyContainer.flex.alignItems(.center).padding(0, 30, 0, 30).define { flex in
            flex.addItem(titleContainer).marginBottom(18)
            flex.addItem(descriptionTextView)
        }
        
        buttonsContiner.flex.define { flex in
            flex.addItem(createWalletButton).height(56)
            flex.addItem(restoreButton).height(56).marginTop(10)
        }
        
        rootFlexContainer.flex.justifyContent(.spaceBetween).width(100%).define { flex in
            flex.addItem(logoImage)
                .position(.absolute)
                .top(deviceHeight > 850 ? 35 : 0)
                .left(0).width(100%).marginBottom(15)
            flex.addItem(bodyContainer).paddingTop(deviceHeight * 0.4)
        }
        
        bottomSectionView.flex.define { flex in
            flex.addItem(buttonsContiner).alignSelf(.center).width(100%).padding(0, 20, 0, 20)
        }
    }
}
