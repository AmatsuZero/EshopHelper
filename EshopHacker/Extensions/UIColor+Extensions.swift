//
//  UIColor+Extensions.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/1/29.
//  Copyright © 2019 Daubert. All rights reserved.
//

import UIKit

extension UIColor {

    convenience init(r red: CGFloat, g green: CGFloat, b blue: CGFloat, a alpha: CGFloat = 1) {
        self.init(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
    }

    static var eShopColor: UIColor { return .init(r: 255, g: 120, b: 45) }
    static var lineColor: UIColor { return .init(r: 239, g: 239, b: 239) }

    func interpolate(with other: UIColor, percent: CGFloat) -> UIColor? {
        return UIColor.interpolate(betweenColor: self, and: other, percent: percent)
    }

    static func interpolate(betweenColor colorA: UIColor,
                            and colorB: UIColor,
                            percent: CGFloat) -> UIColor? {
        var redA: CGFloat = 0.0
        var greenA: CGFloat = 0.0
        var blueA: CGFloat = 0.0
        var alphaA: CGFloat = 0.0
        guard colorA.getRed(&redA, green: &greenA, blue: &blueA, alpha: &alphaA) else {
            return nil
        }

        var redB: CGFloat = 0.0
        var greenB: CGFloat = 0.0
        var blueB: CGFloat = 0.0
        var alphaB: CGFloat = 0.0
        guard colorB.getRed(&redB, green: &greenB, blue: &blueB, alpha: &alphaB) else {
            return nil
        }

        let iRed = CGFloat(redA + percent * (redB - redA))
        let iBlue = CGFloat(blueA + percent * (blueB - blueA))
        let iGreen = CGFloat(greenA + percent * (greenB - greenA))
        let iAlpha = CGFloat(alphaA + percent * (alphaB - alphaA))

        return UIColor(red: iRed, green: iGreen, blue: iBlue, alpha: iAlpha)
    }
}
