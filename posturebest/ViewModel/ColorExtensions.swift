//
//  ColorExtensions.swift
//  posturebest
//
//  Created by Madeline Coco on 9/10/24.
//

import SwiftUI
import UIKit

extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexSanitized.hasPrefix("#") {
            hexSanitized.remove(at: hexSanitized.startIndex)
        }
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}

extension UIColor {
    convenience init?(hex: String) {
        var rgb: UInt64 = 0
        var alpha: CGFloat = 1.0
        
        // Remove the hash (#) if it exists
        let hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        
        // Set the alpha if the string has 8 characters
        if hexString.count == 8, let hexValue = UInt64(hexString, radix: 16) {
            rgb = hexValue >> 8
            alpha = CGFloat((hexValue & 0x000000FF)) / 255.0
        } else if hexString.count == 6, let hexValue = UInt64(hexString, radix: 16) {
            rgb = hexValue
        } else {
            return nil // Invalid hex string
        }
        
        let red = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let green = CGFloat((rgb >> 8) & 0xFF) / 255.0
        let blue = CGFloat(rgb & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
