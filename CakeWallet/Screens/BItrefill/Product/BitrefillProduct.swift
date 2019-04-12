import UIKit
import FlexLayout
import SwiftyJSON
import Alamofire
import SwiftSVG


final class BitrefillProductTableCell: FlexCell {
    private static let imageSize = CGSize(width: 35, height: 35)
    private static var defaultThumbnail: UIImage = {
        return UIImage(named: "placeholder")!.resized(to: BitrefillProductTableCell.imageSize)
    }()
    
    let contentHolder: UIView
    let name: UILabel
    let imageContainer: UIView
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        contentHolder = UIView()
        name = UILabel()
        imageContainer = UIView()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    func configure(name: String, logoImageURL: String) {
        self.name.text = name
        self.addImageView(image: BitrefillProductTableCell.defaultThumbnail)
    
        fileDownloadingQueue.async {
            if let url = URL(string: logoImageURL) {
                do {
                    let data = try Data(contentsOf: url)
                    
                    DispatchQueue.main.async {
                        if let image = UIImage(data: data)?.resized(to: BitrefillProductTableCell.imageSize) {
                            self.addImageView(image: image)
                        } else {
                            self.addSVGImageView(data: data)
                        }
                    }
                } catch {
                    print(String(format: "Error: failed loading logo image for: %@. \n %@", name, error.localizedDescription))
                }
            }
        }
        
        self.name.flex.markDirty()
        contentView.flex.layout()
    }
    
    func addSVGImageView(data: Data) {
        let svgView =  UIView(SVGData: data) { layer in
            layer.resizeToFit(CGRect(origin: .zero, size: BitrefillProductTableCell.imageSize))
        }
        svgView.tag = 1101
        removeInnerImageContainer()
        imageContainer.addSubview(svgView)
    }
    
    func addImageView(image: UIImage) {
        let imageView = UIImageView(image: image)
        imageView.tag = 1102
        removeInnerImageContainer()
        imageContainer.addSubview(imageView)
    }
    
    func removeInnerImageContainer() {
        imageContainer.viewWithTag(1102)?.removeFromSuperview()
        imageContainer.viewWithTag(1101)?.removeFromSuperview()
    }
    
    override func configureView() {
        super.configureView()
        name.font = applyFont(ofSize: 17)
        selectionStyle = .none
    }
    
    override func configureConstraints() {
        contentHolder.flex
            .direction(.row)
            .justifyContent(.start)
            .alignItems(.center)
            .width(100%)
            .height(62)
            .paddingHorizontal(25)
            .backgroundColor(.white)
            .define{ flex in
                flex.addItem(imageContainer).size(BitrefillProductTableCell.imageSize)
                flex.addItem(name).marginLeft(30)
        }
        
        contentView.flex
            .width(100%)
            .height(80)
            .backgroundColor(Theme.current.container.background)
            .define{ flex in
                flex.addItem(contentHolder)
        }
    }
}


struct BitrefillProduct: Codable, JSONInitializable {
    private static func urlForLogo(withName name: String, andBackgrould backgroud: String) -> String {
        return String(
            format: "https://www.bitrefill.com/content/cn/b_rgb:%@,c_pad,d_operator.png,h_35,w_35/%@",
            backgroud,
            name
        )
    }
    
    let type: String
    let slug: String
    let isRanged: Bool
    let name: String
    let logoImageURL: String
    let recipientType: String
    let currency: String
    
    init(json: JSON) {
        type = json["type"].stringValue
        slug = json["slug"].stringValue
        isRanged = json["isRanged"].boolValue
        recipientType = json["recipientType"].stringValue
        name = json["name"].stringValue
        currency = json["currency"].stringValue
        let logoBackground = String(json["logoBackground"].stringValue.dropFirst())
        logoImageURL = BitrefillProduct.urlForLogo(
            withName: json["logoBaseImage"].stringValue,
            andBackgrould: logoBackground)
    }
}

extension BitrefillProduct: CellItem {
    func setup(cell: BitrefillProductTableCell) {
        cell.configure(name: name, logoImageURL: logoImageURL)
    }
}
