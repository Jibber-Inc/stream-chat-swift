//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// View for the  action item in an action list (for channels and messages).
public struct ActionItemView: View {
    @Injected(\.colors) var colors
    @Injected(\.images) var images
    @Injected(\.fonts) var fonts

    var title: String
    var iconName: String
    var isDestructive: Bool
    var boldTitle: Bool = true

    public var body: some View {
        HStack(spacing: 16) {
            Image(uiImage: image)
                .resizable()
                .renderingMode(.template)
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 16)
                .foregroundColor(
                    isDestructive ? Color(colors.alert) : Color(colors.textLowEmphasis)
                )
            
            Text(title)
                .font(boldTitle ? fonts.bodyBold : fonts.body)
                .foregroundColor(
                    isDestructive ? Color(colors.alert) : Color(colors.text)
                )
            
            Spacer()
        }
        .frame(height: 40)
    }
    
    private var image: UIImage {
        // Check if it's in the app bundle.
        if let image = UIImage(named: iconName) {
            return image
        }
        
        // Support for system images.
        if let image = UIImage(systemName: iconName) {
            return image
        }
        
        // Check if it's bundled.
        if let image = UIImage(named: iconName, in: .streamChatUI) {
            return image
        }
        
        // Default image.
        return UIImage(systemName: "photo")!
    }
}
