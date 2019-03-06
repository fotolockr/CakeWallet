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
        
        let welcomeLabelFontSize = Int(adaptiveLayout.getSize(forLarge: 32, forBig: 30, defaultSize: 24))
        let welcomeSubtitleFontSize = Int(adaptiveLayout.getSize(forLarge: 24, forBig: 22, defaultSize: 20))
        let welcomeDescriptionFontSize = Int(adaptiveLayout.getSize(forLarge: 17, forBig: 16, defaultSize: 16))
        
        welcomeLabel.font = applyFont(ofSize: welcomeLabelFontSize, weight: .bold)
        welcomeLabel.textAlignment = NSTextAlignment.center
        welcomeLabel.numberOfLines = 0
        
        welcomeSubtitleLabel.font = applyFont(ofSize: welcomeSubtitleFontSize, weight: .semibold)
        welcomeSubtitleLabel.textAlignment = NSTextAlignment.center
        welcomeSubtitleLabel.numberOfLines = 0
        welcomeSubtitleLabel.textColor = UIColor(red: 126, green: 147, blue: 177)
        
        descriptionTextView.font = applyFont(ofSize: welcomeDescriptionFontSize)
        descriptionTextView.textAlignment = NSTextAlignment.center
        descriptionTextView.textColor = UIColor(red: 126, green: 147, blue: 177)
        descriptionTextView.isEditable = false
        descriptionTextView.layer.masksToBounds = true
        descriptionTextView.backgroundColor = .clear
        descriptionTextView.layer.cornerRadius = 10
        descriptionTextView.isScrollEnabled = false
    }
    
    override func configureConstraints() {
        let logoImageTopPosition = adaptiveLayout.getSize(forLarge: 50, forBig: 20, defaultSize: -10)
        let bodyContainerPaddingTop = adaptiveLayout.getSize(forLarge: 400, forBig: 340, defaultSize: 280)
        
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
                .top(logoImageTopPosition)
                .left(0).width(100%).marginBottom(15)
            flex.addItem(bodyContainer).paddingTop(bodyContainerPaddingTop)
        }
        
        bottomSectionView.flex.define { flex in
            flex.addItem(buttonsContiner).alignSelf(.center).width(100%).padding(0, 20, 0, 20)
        }
    }
}
