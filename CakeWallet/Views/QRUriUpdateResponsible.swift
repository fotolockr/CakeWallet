import Foundation
import CakeWalletLib

protocol QRUriUpdateResponsible: class {
    func getCrypto(for adressView: AddressView) -> CryptoCurrency
    func updated(_ adressView: AddressView, withURI uri: QRUri)
}
