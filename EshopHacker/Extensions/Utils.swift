//
//  Utils.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/1.
//  Copyright © 2019 Daubert. All rights reserved.
//

import UIKit

extension UILabel {
    func toImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        defer {
            UIGraphicsEndImageContext()
        }
        
        layer.render(in: context)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

extension UIImage {
    func newImage(scaledToSize newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage;
    }
}

extension Timer {
    
    class func ssbPlayerScheduledTimerWithTimeInterval(_ timeInterval: TimeInterval, block: @escaping ()->(), repeats: Bool) -> Timer {
        return scheduledTimer(timeInterval: timeInterval,
                              target: self,
                              selector: #selector(self.ssbPlayerBlcokInvoke(_:)),
                              userInfo: block,
                              repeats: repeats)
    }
    
    @objc class func ssbPlayerBlcokInvoke(_ timer: Timer) {
        if let block = timer.userInfo as? ()->() {
             block()
        }
    }
    
}

extension NumberFormatter {
    static var rmbCurrencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter
    }
}

extension String {
    func rmbExpression() -> String? {
        guard let price = Double(self) else {
            return nil
        }
        return NumberFormatter.rmbCurrencyFormatter.string(from: price as NSNumber)
    }
}

extension Array {
    func take(_ num: Int) -> [Element] {
        guard !isEmpty else {
            return []
        }
        var ret = [Element]()
        for i in 0..<Swift.min(self.count, num) {
            ret.append(self[i])
        }
        return ret
    }
}

extension NSAttributedString {
    
    class func create(from richText: String, from: Int, to: Int, color: UIColor) -> NSAttributedString {
        let attrStr = NSMutableAttributedString(string: richText)
        attrStr.addAttribute(.foregroundColor, value: color, range: .init(location: from, length: to))
        return attrStr
    }
}

extension UILabel {
    func linesOfString() -> [String] {
        guard let string = self.text else {
            return []
        }
        let rect = CGRect(origin: frame.origin, size: .init(width: .screenWidth, height: frame.height))
        let myFont = CTFontCreateWithName(font.fontName as CFString, font.pointSize, nil)
        let attrStr = NSMutableAttributedString(string: string)
        attrStr.addAttributes([
            kCTFontAttributeName as NSAttributedString.Key: myFont
        ],range: NSRange.init(location: 0, length: attrStr.length))
        let frameSetter = CTFramesetterCreateWithAttributedString(attrStr as CFAttributedString)
        let path = CGMutablePath()
        path.addRect(.init(origin: .zero, size: .init(width: rect.width, height: .greatestFiniteMagnitude)))
        let myFrame = CTFramesetterCreateFrame(frameSetter, .init(location: 0, length: 0), path, nil)
        let lines = (CTFrameGetLines(myFrame) as NSArray).map {  line -> String in
            let value = line as! CTLine
            let lineRange = CTLineGetStringRange(value)
            let range = NSRange(location: lineRange.location, length: lineRange.length)
            let str = (string as NSString).substring(with: range)
            CFAttributedStringSetAttribute(attrStr as CFMutableAttributedString, lineRange, kCTKernAttributeName, 0 as CFTypeRef)
            return str
        }
        return lines
    }
}
