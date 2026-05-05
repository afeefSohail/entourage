import UIKit

extension UIColor {
    
    enum ColorMode {
        case ARGB
        case RGBA
    }
    
    convenience init(_ hexString: String, mode: ColorMode = .ARGB) {
        
        var hexString = hexString
            .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "#"))
            .replacingOccurrences(of: "0x", with: "").uppercased()
        
        // We should have 6 or 8 characters now.
        let hexStringLength = hexString.count
        if hexStringLength != 6 && hexStringLength != 8 {
            // set to clear color
            hexString = "00000000"
        }
        
        let hexStringContainsAlpha = hexString.count == 8
        var alphaHex = "FF"
        var colorHex = hexString
        if hexStringContainsAlpha {
            switch mode {
            case .ARGB:
                alphaHex = String(hexString[hexString.startIndex...hexString.index(hexString.startIndex, offsetBy: 1)])
                colorHex = String(hexString[hexString.index(hexString.startIndex, offsetBy: 2)...hexString.index(hexString.startIndex, offsetBy: 7)])
            case .RGBA:
                alphaHex = String(hexString[hexString.index(hexString.startIndex, offsetBy: 6)...hexString.index(hexString.startIndex, offsetBy: 7)])
                colorHex = String(hexString[hexString.startIndex...hexString.index(hexString.startIndex, offsetBy: 5)])
            }
        }
        
        let colorStrings: [String] = [
            String(colorHex[colorHex.startIndex...colorHex.index(colorHex.startIndex, offsetBy: 1)]),
            String(colorHex[colorHex.index(colorHex.startIndex, offsetBy: 2)...colorHex.index(colorHex.startIndex, offsetBy: 3)]),
            String(colorHex[colorHex.index(colorHex.startIndex, offsetBy: 4)...colorHex.index(colorHex.startIndex, offsetBy: 5)]),
            alphaHex
        ]
        
        // Convert string components into their CGFloat (r,g,b,a) components
        let colorFloats: [CGFloat] = colorStrings.map {
            var componentInt: CUnsignedInt = 0
            Scanner(string: $0).scanHexInt32(&componentInt)
            return CGFloat(componentInt) / CGFloat(255.0)
        }
        
        self.init(red: colorFloats[0], green: colorFloats[1], blue: colorFloats[2], alpha: colorFloats[3])
    }
    
    convenience init(_ hex: UInt32, mode: ColorMode = .ARGB) {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        
        switch mode {
        case .ARGB:
            red = CGFloat((hex & 0x00FF0000) >> 16) / 255.0
            green = CGFloat((hex & 0x0000FF00) >> 8) / 255.0
            blue = CGFloat((hex & 0x000000FF)) / 255.0
            alpha = CGFloat((hex & 0xFF000000) >> 24) / 255.0
            
        case .RGBA:
            red = CGFloat((hex & 0xFF000000) >> 24) / 255.0
            green = CGFloat((hex & 0x00FF0000) >> 16) / 255.0
            blue = CGFloat((hex & 0x0000FF00) >> 8) / 255.0
            alpha = CGFloat((hex & 0x000000FF)) / 255.0
        }
        
        if alpha == 0 { alpha = 1 }
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
}

extension UIColor {
    
    func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: abs(percentage))
    }
    
    func darker(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage))
    }
    
    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if getRed(&r, green: &g, blue: &b, alpha: &a) {
            return UIColor(red: min(r + percentage / 100, 1.0),
                           green: min(g + percentage / 100, 1.0),
                           blue: min(b + percentage / 100, 1.0),
                           alpha: a)
        } else {
            return nil
        }
    }
    
    func invert() -> UIColor? {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if getRed(&r, green: &g, blue: &b, alpha: &a) {
            return UIColor(red: 1 - r, green: 1 - g, blue: 1 - b, alpha: a)
        } else {
            return nil
        }
    }
    
}

