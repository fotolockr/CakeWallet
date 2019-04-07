import UIKit
import FlexLayout


final class BitrefillSelectCountryView: BaseFlexView {
    let label = UILabel(text: "Hello")
    
    required init() {
        
 
        super.init()
    }
    
    override func configureView() {
        super.configureView()
    }
    
    override func configureConstraints() {
        rootFlexContainer.flex
            .width(100%)
            .height(100%)
            .backgroundColor(.clear)
            .paddingTop(20)
            .define { flex in
                flex.addItem(label)
        }
    }
}

