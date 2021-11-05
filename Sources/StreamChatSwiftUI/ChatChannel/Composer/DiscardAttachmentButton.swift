//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import SwiftUI

public struct DiscardAttachmentButton: View {
    var attachmentIdentifier: String
    var onDiscard: (String) -> Void
    
    public var body: some View {
        TopRightView {
            Button(action: {
                withAnimation {
                    onDiscard(attachmentIdentifier)
                }
            }, label: {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 16, height: 16)
                    
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color.black.opacity(0.8))
                }
                .padding(.all, 4)
            })
        }
    }
}
