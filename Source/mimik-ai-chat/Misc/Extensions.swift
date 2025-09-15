//
//  Extensions.swift
//  mimik-ai-chat
//
//  Created by rb on 2025-03-21.
//

import SwiftUI

public enum ScreenSize {
    static let screenWidth         = UIScreen.main.bounds.size.width
    static let screenHeight        = UIScreen.main.bounds.size.height
    static let screenMaxLength    = max(screenWidth, screenHeight)
    static let screenMinLength    = min(screenWidth, screenHeight)
}

public enum DeviceType {
    static let isTablet = UIDevice.current.userInterfaceIdiom == .pad
}

extension Color {
    // Metallic colors
    static let bronze = Color(red: 205/255, green: 127/255, blue: 50/255)
    static let darkBronze = Color(red: 164/255, green: 102/255, blue: 40/255)
    static let silver = Color(red: 192/255, green: 192/255, blue: 192/255)
    static let copper = Color(red: 184/255, green: 115/255, blue: 51/255)
    static let gold = Color(red: 255/255, green: 215/255, blue: 0/255)
    static let roseGold = Color(red: 183/255, green: 110/255, blue: 121/255)
    static let platinum = Color(red: 229/255, green: 228/255, blue: 226/255)
    static let titanium = Color(red: 42/255, green: 42/255, blue: 42/255)
    static let emerald = Color(red: 80/255, green: 200/255, blue: 120/255)
    static let sapphire = Color(red: 15/255, green: 82/255, blue: 186/255)
    static let ruby = Color(red: 224/255, green: 17/255, blue: 95/255)
    static let amethyst = Color(red: 153/255, green: 102/255, blue: 204/255)
    static let obsidian = Color(red: 25/255, green: 25/255, blue: 25/255)
    static let darkGray = Color(red: 169/255, green: 169/255, blue: 169/255)
    static let lightGray = Color(red: 211/255, green: 211/255, blue: 211/255)
}

extension View {
    // Applies `transform` to this view if `condition` is `true`.
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool,
                             transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    func textFieldModifier(minWidth: CGFloat = 100, minHeight: CGFloat = 34, borderColor: Color = .gray, lineWidth: CGFloat = 1) -> some View {
        self.modifier(BorderTextFieldModifier(minWidth: minWidth, minHeight: minHeight, borderColor: borderColor, lineWidth: lineWidth))
    }
    
    func customBackground(backgroundColor: Color, cornerRadius: CGFloat? = nil, borderColor: Color? = nil, borderWidth: CGFloat = 1.0, padding: CGFloat = 16.0) -> some View {
        self.modifier(CustomBackgroundModifier(backgroundColor: backgroundColor, cornerRadius: cornerRadius, borderColor: borderColor, borderWidth: borderWidth, padding: padding))
    }
}

extension String {
    func decodeBase64StringToImage() -> UIImage? {
        var paddedString: String = self
        let remainder = self.count % 4
        if remainder > 0 {
            paddedString = self.padding(toLength: self.count + 4 - remainder, withPad: "=", startingAt: 0)
        }

        if let decodedData = Data(base64Encoded: paddedString, options: .ignoreUnknownCharacters), let image = UIImage(data: decodedData) as UIImage? {
            return image
        }
        return nil
    }
}

extension Date {  
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd, h:mm a"
        return formatter
    }

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }
    
    func formattedTodayDate() -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(self) {
            return "Today, " + timeFormatter.string(from: self)
        } else {
            return dateFormatter.string(from: self)
        }
    }
}

extension UIImage {

    func base64FromJpeg(compressionQuality: CGFloat) -> String? {
        if let data = self.jpegData(compressionQuality: compressionQuality), !data.isEmpty {
            return data.base64EncodedString()
        }
        return String()
    }

    func resizeImage(targetSize: CGSize, bytesLimit: Int?, compressionQuality: CGFloat) -> UIImage? {
        let size = self.size

        let widthRatio  = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }

        UIGraphicsEndImageContext()

        if let specifiedByteLimit = bytesLimit {
            guard let checkedBytesSize = newImage.bytesSize(compressionQuality: compressionQuality), checkedBytesSize < specifiedByteLimit else {
                return self.resizeImage(targetSize: CGSize(width: targetSize.width * 0.9, height: targetSize.height * 0.9), bytesLimit: bytesLimit, compressionQuality: compressionQuality)
            }

            return newImage
        }

        return newImage
    }

    private func bytesSize(compressionQuality: CGFloat) -> Int? {

        guard let imageBase64String = self.base64FromJpeg(compressionQuality: compressionQuality), let checkedJsonData = Data(base64Encoded: imageBase64String) else {
            return nil
        }

        return checkedJsonData.count
    }
}

extension Color {
    static let mimikBlue = Color(red: 63/255, green: 171/255, blue: 233/255)
}
