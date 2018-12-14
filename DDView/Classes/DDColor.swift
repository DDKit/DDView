//
//  DDColor.swift
//  WebView
//
//  Created by 风荷举 on 2018/12/13.
//  Copyright © 2018年 ddWorker. All rights reserved.
//

import UIKit

public extension UIColor {
    /// Constructing color from hex string
    ///
    /// - Parameter hex: A hex string, can either contain # or not
    convenience init(hex string: String) {
        var hex = string.hasPrefix("#")
            ? String(string.dropFirst())
            : string
        guard hex.count == 3 || hex.count == 6
            else {
                self.init(white: 1.0, alpha: 0.0)
                return
        }
        if hex.count == 3 {
            for (index, char) in hex.enumerated() {
                hex.insert(char, at: hex.index(hex.startIndex, offsetBy: index * 2))
            }
        }
        
        self.init(
            red:   CGFloat((Int(hex, radix: 16)! >> 16) & 0xFF) / 255.0,
            green: CGFloat((Int(hex, radix: 16)! >> 8) & 0xFF) / 255.0,
            blue:  CGFloat((Int(hex, radix: 16)!) & 0xFF) / 255.0, alpha: 1.0)
    }
    
    /// Adjust color based on saturation
    ///
    /// - Parameter minSaturation: The minimun saturation value
    /// - Returns: The adjusted color
    public func color(minSaturation: CGFloat) -> UIColor {
        var (hue, saturation, brightness, alpha): (CGFloat, CGFloat, CGFloat, CGFloat) = (0.0, 0.0, 0.0, 0.0)
        getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        return saturation < minSaturation
            ? UIColor(hue: hue, saturation: minSaturation, brightness: brightness, alpha: alpha)
            : self
    }
    
    /// Convenient method to change alpha value
    ///
    /// - Parameter value: The alpha value
    /// - Returns: The alpha adjusted color
    public func alpha(_ value: CGFloat) -> UIColor {
        return withAlphaComponent(value)
    }
}

// MARK: - Helpers

public extension UIColor {
    
    public func hex(hashPrefix: Bool = true) -> String {
        var (r, g, b, a): (CGFloat, CGFloat, CGFloat, CGFloat) = (0.0, 0.0, 0.0, 0.0)
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let prefix = hashPrefix ? "#" : ""
        
        return String(format: "\(prefix)%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
    
    internal func rgbComponents() -> [CGFloat] {
        var (r, g, b, a): (CGFloat, CGFloat, CGFloat, CGFloat) = (0.0, 0.0, 0.0, 0.0)
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return [r, g, b]
    }
    
    public var isDark: Bool {
        let RGB = rgbComponents()
        return (0.2126 * RGB[0] + 0.7152 * RGB[1] + 0.0722 * RGB[2]) < 0.5
    }
    
    public var isBlackOrWhite: Bool {
        let RGB = rgbComponents()
        return (RGB[0] > 0.91 && RGB[1] > 0.91 && RGB[2] > 0.91) || (RGB[0] < 0.09 && RGB[1] < 0.09 && RGB[2] < 0.09)
    }
    
    public var isBlack: Bool {
        let RGB = rgbComponents()
        return (RGB[0] < 0.09 && RGB[1] < 0.09 && RGB[2] < 0.09)
    }
    
    public var isWhite: Bool {
        let RGB = rgbComponents()
        return (RGB[0] > 0.91 && RGB[1] > 0.91 && RGB[2] > 0.91)
    }
    
    public func isDistinct(from color: UIColor) -> Bool {
        let bg = rgbComponents()
        let fg = color.rgbComponents()
        let threshold: CGFloat = 0.25
        var result = false
        
        if abs(bg[0] - fg[0]) > threshold || abs(bg[1] - fg[1]) > threshold || abs(bg[2] - fg[2]) > threshold {
            if abs(bg[0] - bg[1]) < 0.03 && abs(bg[0] - bg[2]) < 0.03 {
                if abs(fg[0] - fg[1]) < 0.03 && abs(fg[0] - fg[2]) < 0.03 {
                    result = false
                }
            }
            result = true
        }
        
        return result
    }
    
    public func isContrasting(with color: UIColor) -> Bool {
        let bg = rgbComponents()
        let fg = color.rgbComponents()
        
        let bgLum = 0.2126 * bg[0] + 0.7152 * bg[1] + 0.0722 * bg[2]
        let fgLum = 0.2126 * fg[0] + 0.7152 * fg[1] + 0.0722 * fg[2]
        let contrast = bgLum > fgLum
            ? (bgLum + 0.05) / (fgLum + 0.05)
            : (fgLum + 0.05) / (bgLum + 0.05)
        
        return 1.6 < contrast
    }
    
}

// MARK: - Gradient

public extension Array where Element : UIColor {
    
    public func gradient(_ transform: ((_ gradient: inout CAGradientLayer) -> CAGradientLayer)? = nil) -> CAGradientLayer {
        var gradient = CAGradientLayer()
        gradient.colors = self.map { $0.cgColor }
        
        if let transform = transform {
            gradient = transform(&gradient)
        }
        
        return gradient
    }
}

// MARK: - Components

public extension UIColor {
    
    var redComponent : CGFloat {
        get {
            var r : CGFloat = 0
            self.getRed(&r, green: nil , blue: nil, alpha: nil)
            return r
        }
    }
    
    var greenComponent : CGFloat {
        get {
            var g : CGFloat = 0
            self.getRed(nil, green: &g , blue: nil, alpha: nil)
            return g
        }
    }
    
    var blueComponent : CGFloat {
        get {
            var b : CGFloat = 0
            self.getRed(nil, green: nil , blue: &b, alpha: nil)
            return b
        }
    }
    
    var alphaComponent : CGFloat {
        get {
            var a : CGFloat = 0
            self.getRed(nil, green: nil , blue: nil, alpha: &a)
            return a
        }
    }
}


// MARK: - Blending

public extension UIColor {
    
    /**adds hue, saturation, and brightness to the HSB components of this color (self)*/
    public func add(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) -> UIColor {
        var (oldHue, oldSat, oldBright, oldAlpha) : (CGFloat, CGFloat, CGFloat, CGFloat) = (0,0,0,0)
        getHue(&oldHue, saturation: &oldSat, brightness: &oldBright, alpha: &oldAlpha)
        
        // make sure new values doesn't overflow
        var newHue = oldHue + hue
        while newHue < 0.0 { newHue += 1.0 }
        while newHue > 1.0 { newHue -= 1.0 }
        
        let newBright: CGFloat = max(min(oldBright + brightness, 1.0), 0)
        let newSat: CGFloat = max(min(oldSat + saturation, 1.0), 0)
        let newAlpha: CGFloat = max(min(oldAlpha + alpha, 1.0), 0)
        
        return UIColor(hue: newHue, saturation: newSat, brightness: newBright, alpha: newAlpha)
    }
    
    /**adds red, green, and blue to the RGB components of this color (self)*/
    public func add(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        var (oldRed, oldGreen, oldBlue, oldAlpha) : (CGFloat, CGFloat, CGFloat, CGFloat) = (0,0,0,0)
        getRed(&oldRed, green: &oldGreen, blue: &oldBlue, alpha: &oldAlpha)
        // make sure new values doesn't overflow
        let newRed: CGFloat = max(min(oldRed + red, 1.0), 0)
        let newGreen: CGFloat = max(min(oldGreen + green, 1.0), 0)
        let newBlue: CGFloat = max(min(oldBlue + blue, 1.0), 0)
        let newAlpha: CGFloat = max(min(oldAlpha + alpha, 1.0), 0)
        return UIColor(red: newRed, green: newGreen, blue: newBlue, alpha: newAlpha)
    }
    
    
    public func add(hsb color: UIColor) -> UIColor {
        var (h,s,b,a) : (CGFloat, CGFloat, CGFloat, CGFloat) = (0,0,0,0)
        color.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return self.add(hue: h, saturation: s, brightness: b, alpha: 0)
    }
    public func add(rgb color: UIColor) -> UIColor {
        return self.add(red: color.redComponent, green: color.greenComponent, blue: color.blueComponent, alpha: 0)
    }
    
    public func add(hsba color: UIColor) -> UIColor {
        var (h,s,b,a) : (CGFloat, CGFloat, CGFloat, CGFloat) = (0,0,0,0)
        color.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return self.add(hue: h, saturation: s, brightness: b, alpha: a)
    }
    
    /**adds the rgb components of two colors*/
    public func add(rgba color: UIColor) -> UIColor {
        return self.add(red: color.redComponent, green: color.greenComponent, blue: color.blueComponent, alpha: color.alphaComponent)
    }
}

class CountedColor {
    let color: UIColor
    let count: Int
    
    init(color: UIColor, count: Int) {
        self.color = color
        self.count = count
    }
}

extension UIImage {
    fileprivate func resize(to newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 2)
        draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result!
    }
    
    public func colors(scaleDownSize: CGSize? = nil) -> (background: UIColor, primary: UIColor, secondary: UIColor, detail: UIColor) {
        let cgImage: CGImage
        
        if let scaleDownSize = scaleDownSize {
            cgImage = resize(to: scaleDownSize).cgImage!
        } else {
            let ratio = size.width / size.height
            let r_width: CGFloat = 250
            cgImage = resize(to: CGSize(width: r_width, height: r_width / ratio)).cgImage!
        }
        
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let bitsPerComponent = 8
        let randomColorsThreshold = Int(CGFloat(height) * 0.01)
        let blackColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        let whiteColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let raw = malloc(bytesPerRow * height)
        let bitmapInfo = CGImageAlphaInfo.premultipliedFirst.rawValue
        let context = CGContext(data: raw, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
        let data = UnsafePointer<UInt8>(context?.data?.assumingMemoryBound(to: UInt8.self))
        let imageBackgroundColors = NSCountedSet(capacity: height)
        let imageColors = NSCountedSet(capacity: width * height)
        
        let sortComparator: (CountedColor, CountedColor) -> Bool = { (a, b) -> Bool in
            return a.count <= b.count
        }
        
        for x in 0..<width {
            for y in 0..<height {
                let pixel = ((width * y) + x) * bytesPerPixel
                let color = UIColor(
                    red:   CGFloat((data?[pixel+1])!) / 255,
                    green: CGFloat((data?[pixel+2])!) / 255,
                    blue:  CGFloat((data?[pixel+3])!) / 255,
                    alpha: 1
                )
                
                if x >= 5 && x <= 10 {
                    imageBackgroundColors.add(color)
                }
                
                imageColors.add(color)
            }
        }
        
        var sortedColors = [CountedColor]()
        
        for color in imageBackgroundColors {
            guard let color = color as? UIColor else { continue }
            
            let colorCount = imageBackgroundColors.count(for: color)
            
            if randomColorsThreshold <= colorCount  {
                sortedColors.append(CountedColor(color: color, count: colorCount))
            }
        }
        
        sortedColors.sort(by: sortComparator)
        
        var proposedEdgeColor = CountedColor(color: blackColor, count: 1)
        
        if let first = sortedColors.first { proposedEdgeColor = first }
        
        if proposedEdgeColor.color.isBlackOrWhite && !sortedColors.isEmpty {
            for countedColor in sortedColors where CGFloat(countedColor.count / proposedEdgeColor.count) > 0.3 {
                if !countedColor.color.isBlackOrWhite {
                    proposedEdgeColor = countedColor
                    break
                }
            }
        }
        
        let imageBackgroundColor = proposedEdgeColor.color
        let isDarkBackgound = imageBackgroundColor.isDark
        
        sortedColors.removeAll()
        
        for imageColor in imageColors {
            guard let imageColor = imageColor as? UIColor else { continue }
            
            let color = imageColor.color(minSaturation: 0.15)
            
            if color.isDark == !isDarkBackgound {
                let colorCount = imageColors.count(for: color)
                sortedColors.append(CountedColor(color: color, count: colorCount))
            }
        }
        
        sortedColors.sort(by: sortComparator)
        
        var primaryColor, secondaryColor, detailColor: UIColor?
        
        for countedColor in sortedColors {
            let color = countedColor.color
            
            if primaryColor == nil &&
                color.isContrasting(with: imageBackgroundColor) {
                primaryColor = color
            } else if secondaryColor == nil &&
                primaryColor != nil &&
                primaryColor!.isDistinct(from: color) &&
                color.isContrasting(with: imageBackgroundColor) {
                secondaryColor = color
            } else if secondaryColor != nil &&
                (secondaryColor!.isDistinct(from: color) &&
                    primaryColor!.isDistinct(from: color) &&
                    color.isContrasting(with: imageBackgroundColor)) {
                detailColor = color
                break
            }
        }
        
        free(raw)
        
        return (
            imageBackgroundColor,
            primaryColor   ?? (isDarkBackgound ? whiteColor : blackColor),
            secondaryColor ?? (isDarkBackgound ? whiteColor : blackColor),
            detailColor    ?? (isDarkBackgound ? whiteColor : blackColor))
    }
    
    public func color(at point: CGPoint, completion: @escaping (UIColor?) -> Void) {
        let size = self.size
        let cgImage = self.cgImage
        
        DispatchQueue.global(qos: .userInteractive).async {
            let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            guard let imgRef = cgImage,
                let dataProvider = imgRef.dataProvider,
                let dataCopy = dataProvider.data,
                let data = CFDataGetBytePtr(dataCopy),
                rect.contains(point) else {
                    completion(nil)
                    return
            }
            
            let pixelInfo = (Int(size.width) * Int(point.y) + Int(point.x)) * 4
            let red = CGFloat(data[pixelInfo]) / 255.0
            let green = CGFloat(data[pixelInfo + 1]) / 255.0
            let blue = CGFloat(data[pixelInfo + 2]) / 255.0
            let alpha = CGFloat(data[pixelInfo + 3]) / 255.0
            
            DispatchQueue.main.async {
                completion(UIColor(red: red, green: green, blue: blue, alpha: alpha))
            }
        }
    }
}
