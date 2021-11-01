//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import SwiftUI

/// View displaying system messages.
public struct SystemMessageView: View {
    @Injected(\.fonts) var fonts
    @Injected(\.colors) var colors
    
    var message: String
    
    public var body: some View {
        Text(message)
            .font(fonts.caption1)
            .bold()
            .foregroundColor(Color(colors.textLowEmphasis))
            .standardPadding()
    }
}
