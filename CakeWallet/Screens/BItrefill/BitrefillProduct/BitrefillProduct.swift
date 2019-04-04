import UIKit
import FlexLayout
import SwiftyJSON


extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}


final class BitrefillProductTableCell: FlexCell {
    let contentHolder = UIView()
    let name = UILabel()
    
    var image2 = UIImageView()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    func configure(name: String, logoImageURL: String) {
        self.name.text = name
    
        image2.image = UIImage(named: "placeholder")
        
//        if let ur = URL(string: logoImageURL) {
//            print("logoImageURL", logoImageURL)
//            print("==========================")
//
//
//            let data = try? Data(contentsOf: ur)
//
//            if let imageData = data {
//                image2.image = UIImage(data: imageData)
//            } else {
//                print("HELLO IM LOADING SOMETHING ELSE ")
//                print("================================")
//            }
//        }
        
        self.name.flex.markDirty()
        contentView.flex.layout()
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
                flex.addItem(image2).width(35).height(35)
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
    let type: String
    let slug: String
    let name: String
    let logoImageURL: String
    
    init(json: JSON) throws {
        type = json["type"].stringValue
        slug = json["slug"].stringValue
        name = json["name"].stringValue
        logoImageURL = json["logoImage"].stringValue
    }
}

extension BitrefillProduct: CellItem {
    func setup(cell: BitrefillProductTableCell) {
        cell.configure(name: name, logoImageURL: logoImageURL)
    }
}
