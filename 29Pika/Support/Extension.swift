

import Foundation
import UIKit
import WebKit

extension UIImage {
    func resize(targetSize: CGSize) -> UIImage {
        let size = self.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.main.scale)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}



enum AppFont {
    case LargeTitleRegular
    case LargeTitleEmphasized
    
    case Title1Regular
    case Title1Emphasized
    
    case Title2Regular
    case Title2Emphasized
    
    case Title3Regular
    case Title3Emphasized
    
    case HeadlineRegular
    
    case BodyRegular
    case BodyEmphasized
    
    case CalloutRegular
    case CalloutEmphasized
    
    case SubheadlineRegular
    case SubheadlineEmphasized
    
    case FootnoteRegular
    case FootnoteEmphasized
    
    case Caption1Regular
    case Caption1Emphasized
    
    case Caption2Regular
    case Caption2Emphasized
    
    var font: UIFont {
        switch self {
        case .LargeTitleRegular:
            return .systemFont(ofSize: 34, weight: .regular)
        case .LargeTitleEmphasized:
            return .systemFont(ofSize: 34, weight: .bold)
        case .Title1Regular:
            return .systemFont(ofSize: 28, weight: .regular)
        case .Title1Emphasized:
            return .systemFont(ofSize: 28, weight: .bold)
        case .Title2Regular:
            return .systemFont(ofSize: 22, weight: .regular)
        case .Title2Emphasized:
            return .systemFont(ofSize: 22, weight: .bold)
        case .Title3Regular:
            return .systemFont(ofSize: 20, weight: .regular)
        case .Title3Emphasized:
            return .systemFont(ofSize: 20, weight: .bold)
        case .HeadlineRegular:
            return .systemFont(ofSize: 17, weight: .semibold)
        case .BodyRegular:
            return UIFont(name: "SFProText-Regular", size: 17)!
        case .BodyEmphasized:
            return UIFont(name: "SFProText-Semibold", size: 17)!
        case .CalloutRegular:
            return UIFont(name: "SFProText-Regular", size: 16)!
        case .CalloutEmphasized:
            return UIFont(name: "SFProText-Semibold", size: 16)!
        case .SubheadlineRegular:
            return UIFont(name: "SFProText-Regular", size: 15)!
        case .SubheadlineEmphasized:
            return UIFont(name: "SFProText-Semibold", size: 15)!
        case .FootnoteRegular:
            return UIFont(name: "SFProText-Regular", size: 13)!
        case .FootnoteEmphasized:
            return UIFont(name: "SFProText-Semibold", size: 13)!
        case .Caption1Regular:
            return UIFont(name: "SFProText-Regular", size: 12)!
        case .Caption1Emphasized:
            return UIFont(name: "SFProText-Medium", size: 12)!
        case .Caption2Regular:
            return UIFont(name: "SFProText-Regular", size: 11)!
        case .Caption2Emphasized:
            return UIFont(name: "SFProText-Semibold", size: 11)!
        }
    }
}

extension UIFont {
    static func appFont(_ font: AppFont) -> UIFont {
        return font.font
    }
}

extension UIViewController {
    func hideNavigationBar() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func showNavigationBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

extension UINavigationBar {
    func setShadowsHidden(_ hidden: Bool) {
        setValue(hidden, forKey: "hidesShadow")
    }
}


extension UIButton {
    func addTouchFeedback() {
        self.addTarget(self, action: #selector(didTouchDown), for: .touchDown)
        self.addTarget(self, action: #selector(didTouchUp), for: .touchUpInside)
        self.addTarget(self, action: #selector(didTouchUp), for: .touchUpOutside)
    }

    @objc private func didTouchDown() {
        self.alpha = 0.7

        let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        
        feedbackGenerator.prepare()
        
        feedbackGenerator.impactOccurred()
    }


    @objc private func didTouchUp() {
        self.alpha = 1.0
    }
}





extension UIView {
    enum GradientDirection {
        case vertical
        case horizontal
    }

    func applyGradient(colors: [UIColor?], direction: GradientDirection) {
        let validColors = colors.compactMap { $0 }
        guard !validColors.isEmpty else { return }

        self.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = validColors.map { $0.cgColor }
        
        switch direction {
        case .vertical:
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        case .horizontal:
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        }

        gradientLayer.frame = self.bounds
        gradientLayer.cornerRadius = self.layer.cornerRadius

        self.layer.insertSublayer(gradientLayer, at: 0)
    }

}


extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        let alpha = CGFloat(1.0)
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}




class WebViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    var urlString: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView

        if let urlString = urlString, let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
    }
}


import MobileCoreServices

extension URL {
    func mimeType() -> String? {
        let pathExtension = self.pathExtension as NSString
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension, nil)?.takeRetainedValue(),
           let mimeType = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
            return mimeType as String
        }
        return nil // Возвращаем nil, если MIME-тип не найден
    }
}

