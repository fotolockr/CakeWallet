import UIKit


func makeIconedNavigationButton(iconName: String, target: Any? = nil, action: Selector? = nil) -> UIBarButtonItem {
    let button = UIBarButtonItem.init(
        image: UIImage(named: iconName)?.resized(to: CGSize(width: 26, height: 26)),
        style: .plain,
        target: target,
        action: action
    )
    button.tintColor = .purpley
    
    return button
}

func makeTitledNavigationButton(title: String, target: Any? = nil, action: Selector? = nil, textColor: UIColor = UIColor.wildDarkBlue) -> UIBarButtonItem {
    let button = UIBarButtonItem(title: title, style: .plain, target: target, action: action)
    
    button.setTitleTextAttributes([
        NSAttributedStringKey.font: applyFont(ofSize: 16),
        NSAttributedStringKey.foregroundColor: textColor],
                                  for: .normal)
    
    button.setTitleTextAttributes([
        NSAttributedStringKey.font: applyFont(ofSize: 16),
        NSAttributedStringKey.foregroundColor: textColor],
                                  for: .highlighted)
    
    return button
}
