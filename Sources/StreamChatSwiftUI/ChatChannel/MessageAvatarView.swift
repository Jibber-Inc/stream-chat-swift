//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import NukeUI
import StreamChat
import SwiftUI

public struct MessageAvatarView: View {
    var author: ChatUser
    
    public var body: some View {
        if let url = author.imageURL?.absoluteString {
            LazyImage(source: url)
                .clipShape(Circle())
                .frame(
                    width: CGSize.messageAvatarSize.width,
                    height: CGSize.messageAvatarSize.height
                )
        } else {
            Image(systemName: "person.circle")
                .resizable()
                .frame(
                    width: CGSize.messageAvatarSize.width,
                    height: CGSize.messageAvatarSize.height
                )
        }
    }
}

extension CGSize {
    static var messageAvatarSize = CGSize(width: 36, height: 36)
}
