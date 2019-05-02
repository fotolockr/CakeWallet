import UIKit
import FlexLayout
import PinLayout

class BaseScrollFlexView: BaseView {
    let rootFlexContainer: UIView
    let scrollView: UIScrollView
    
    override init(frame: CGRect) {
        rootFlexContainer = UIView()
        scrollView = UIScrollView()
        super.init(frame: frame)
        configureView()
    }
    
    required init() {
        rootFlexContainer = UIView()
        scrollView = UIScrollView()
        super.init(frame: CGRect.zero)
        configureView()
    }
    
    override func configureView() {
        super.configureView()
        rootFlexContainer.flex.backgroundColor(Theme.current.container.background)
        scrollView.addSubview(rootFlexContainer)
        addSubview(scrollView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.pin.all(pin.safeArea)
        rootFlexContainer.pin.top().left().right()
        rootFlexContainer.flex.layout(mode: .adjustHeight)
        scrollView.contentSize = rootFlexContainer.frame.size
    }
}

class BaseScrollFlexViewWithBottomSection: BaseView {
    private static let bottomViewTopOffset = 20 as CGFloat
    private static let bottomViewBottomOffset = 20 as CGFloat
    let bottomSectionView: UIView
    let rootFlexContainer: UIView
    let contentView: UIView
    let scrollView: UIScrollView
    
    override init(frame: CGRect) {
        bottomSectionView = UIView()
        rootFlexContainer = UIView()
        contentView = UIView()
        scrollView = UIScrollView()
        super.init(frame: frame)
        configureView()
    }
    
    required init() {
        bottomSectionView = UIView()
        rootFlexContainer = UIView()
        contentView = UIView()
        scrollView = UIScrollView()
        super.init(frame: CGRect.zero)
        configureView()
    }
    
    override func configureView() {
        super.configureView()
        rootFlexContainer.flex.backgroundColor(Theme.current.container.background)
        contentView.addSubview(rootFlexContainer)
        scrollView.addSubview(contentView)
        addSubview(scrollView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.pin.all(pin.safeArea)
        contentView.pin.top().left().right()
        rootFlexContainer.pin.top().left().right()
        bottomSectionView.flex.paddingBottom(10).layout(mode: .adjustHeight)
        contentView.flex.layout(mode: .adjustHeight)
        rootFlexContainer.flex.layout(mode: .adjustHeight)
        bottomSectionView.flex.layout(mode: .adjustHeight)
        
        let totalHeight = bottomSectionView.frame.height
            + rootFlexContainer.frame.size.height
            + BaseScrollFlexViewWithBottomSection.bottomViewTopOffset
        
        bottomSectionView.removeFromSuperview()
        
        if totalHeight >= scrollView.frame.size.height {
            contentView.flex
                .addItem(bottomSectionView)
                .position(.relative)
                .marginTop(BaseScrollFlexViewWithBottomSection.bottomViewTopOffset)
                .height(bottomSectionView.frame.size.height)
                .top(0)
                .left(0)
                .width(rootFlexContainer.frame.size.width)
        } else {
            let height = bottomSectionView.frame.size.height
            let yPosition = scrollView.frame.size.height - height - BaseScrollFlexViewWithBottomSection.bottomViewBottomOffset
            
            scrollView.flex
                .addItem(bottomSectionView)
                .position(.absolute)
                .width(rootFlexContainer.frame.size.width)
                .top(yPosition)
                .left(rootFlexContainer.frame.origin.x)
        }
        
        bottomSectionView.flex.layout(mode: .adjustHeight)
        bottomSectionView.flex.markDirty()
        rootFlexContainer.flex.layout(mode: .adjustHeight)
        rootFlexContainer.flex.markDirty()
        contentView.flex.layout(mode: .adjustHeight)
        contentView.flex.layout()
        scrollView.contentSize = contentView.frame.size
        scrollView.flex.layout()
    }
}
