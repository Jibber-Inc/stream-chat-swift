//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import SwiftUI

public struct SendMessageButton: View {
    @Injected(\.images) var images
    @Injected(\.colors) var colors
    
    var enabled: Bool
    var onTap: () -> Void
    
    public var body: some View {
        Button {
            onTap()
        } label: {
            Image(uiImage: images.sendArrow)
                .renderingMode(.template)
                .rotationEffect(enabled ? Angle(degrees: -90) : .zero)
                .foregroundColor(
                    Color(
                        enabled ? enabledBackground : colors.disabledColorForColor(enabledBackground)
                    )
                )
        }
        .disabled(!enabled)
    }
    
    private var enabledBackground: UIColor {
        colors.highlightedAccentBackground
    }
}
