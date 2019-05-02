import UIKit
import FlexLayout
import RxSwift
import RxCocoa

final class AddressTextField: UITextField {
    private static let holder = "..."
    private static let minHeight = 35 as CGFloat
    var originText: BehaviorRelay<String>
    let disposeBag: DisposeBag
    
    override init(frame: CGRect) {
        originText = BehaviorRelay(value: "")
        disposeBag = DisposeBag()
        super.init(frame: frame)
        delegate = self
        originText
            .subscribe(onNext: { [weak self] text in self?.change(text: text) })
            .disposed(by: disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        originText = BehaviorRelay(value: "")
        disposeBag = DisposeBag()
        super.init(coder: aDecoder)
        delegate = self
        originText
            .subscribe(onNext: { [weak self] text in self?.change(text: text) })
            .disposed(by: disposeBag)
    }
    
    func change(text: String?) {
        guard let text = text else {
            self.text = nil
            return
        }
        
        let length = numberOfCharactersThatFit(for: text)
        guard text.count > length && length > 0 else {
            self.text = text
            return
        }
        
        let middle = length / 2
        let begin = text[0..<middle]
        let end = text.suffix(middle - 3)
        let formattedText = begin + AddressTextField.holder + end
        self.text = formattedText
    }
    
    private func numberOfCharactersThatFit(for text: String?) -> Int {
        let fontRef = CTFontCreateWithName(font!.fontName as CFString, font!.pointSize, nil)
        let attributes = [kCTFontAttributeName : fontRef]
        let attributedString = NSAttributedString(string: text!, attributes: attributes as [NSAttributedStringKey : Any])
        let frameSetterRef = CTFramesetterCreateWithAttributedString(attributedString as CFAttributedString)
        var characterFitRange: CFRange = CFRange()
        let rightViewWidth = rightView?.frame.size.width ?? 0
        let width = bounds.size.width - rightViewWidth
        let height = bounds.size.height < AddressTextField.minHeight ? AddressTextField.minHeight : bounds.size.height
        CTFramesetterSuggestFrameSizeWithConstraints(frameSetterRef, CFRangeMake(0, 0), nil, CGSize(width: width, height: height), &characterFitRange)
        return Int(characterFitRange.length)
    }
}
