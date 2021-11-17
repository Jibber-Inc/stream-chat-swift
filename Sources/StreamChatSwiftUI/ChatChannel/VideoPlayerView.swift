//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import AVKit
import StreamChat
import SwiftUI

public struct VideoPlayerView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Injected(\.fonts) var fonts
    @Injected(\.colors) var colors
    
    let attachment: ChatMessageVideoAttachment
    let author: ChatUser
    @Binding var isShown: Bool
    
    private let avPlayer: AVPlayer
    
    init(attachment: ChatMessageVideoAttachment, author: ChatUser, isShown: Binding<Bool>) {
        self.attachment = attachment
        self.author = author
        avPlayer = AVPlayer(url: attachment.payload.videoURL)
        _isShown = isShown
    }
    
    public var body: some View {
        VStack {
            ZStack {
                HStack {
                    Button {
                        isShown = false
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .padding()
                    .foregroundColor(Color(colors.text))
                    
                    Spacer()
                }
                
                VStack {
                    Text(author.name ?? "")
                        .font(fonts.bodyBold)
                    Text(onlineInfoText)
                        .font(fonts.footnote)
                        .foregroundColor(Color(colors.textLowEmphasis))
                }
            }
            VideoPlayer(player: avPlayer)
            Spacer()
        }
        .onAppear {
            avPlayer.play()
        }
    }
    
    private var onlineInfoText: String {
        if author.isOnline {
            return L10n.Message.Title.online
        } else {
            return L10n.Message.Title.offline
        }
    }
}
