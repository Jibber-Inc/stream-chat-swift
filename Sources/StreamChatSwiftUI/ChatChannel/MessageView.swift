//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct MessageView<Factory: ViewFactory>: View {
    @Injected(\.utils) var utils
    
    private var messageTypeResolver: MessageTypeResolving {
        utils.messageTypeResolver
    }
    
    var factory: Factory
    var message: ChatMessage
    var contentWidth: CGFloat
    var isFirst: Bool
    
    var body: some View {
        VStack {
            if messageTypeResolver.hasCustomAttachment(message: message) {
                factory.makeCustomAttachmentViewType(
                    for: message,
                    isFirst: isFirst,
                    availableWidth: contentWidth
                )
            } else if messageTypeResolver.isDeleted(message: message) {
                factory.makeDeletedMessageView(
                    for: message,
                    isFirst: isFirst,
                    availableWidth: contentWidth
                )
            } else if !message.attachmentCounts.isEmpty {
                if messageTypeResolver.hasLinkAttachment(message: message) {
                    factory.makeLinkAttachmentView(
                        for: message,
                        isFirst: isFirst,
                        availableWidth: contentWidth
                    )
                }
                
                if messageTypeResolver.hasFileAttachment(message: message) {
                    factory.makeFileAttachmentView(
                        for: message,
                        isFirst: isFirst,
                        availableWidth: contentWidth
                    )
                }
                
                if messageTypeResolver.hasImageAttachment(message: message) {
                    factory.makeImageAttachmentView(
                        for: message,
                        isFirst: isFirst,
                        availableWidth: contentWidth
                    )
                }
                
                if messageTypeResolver.hasGiphyAttachment(message: message) {
                    ZStack {
                        factory.makeGiphyAttachmentView(
                            for: message,
                            isFirst: isFirst,
                            availableWidth: contentWidth
                        )
                        factory.makeGiphyBadgeViewType(
                            for: message,
                            availableWidth: contentWidth
                        )
                    }
                }
                
                if messageTypeResolver.hasVideoAttachment(message: message) {
                    factory.makeVideoAttachmentView(
                        for: message,
                        isFirst: isFirst,
                        availableWidth: contentWidth
                    )
                }
            } else {
                if message.shouldRenderAsJumbomoji {
                    EmojiTextView(message: message)
                } else if !message.text.isEmpty {
                    factory.makeMessageTextView(
                        for: message,
                        isFirst: isFirst,
                        availableWidth: contentWidth
                    )
                }
            }
        }
    }
}

public struct MessageTextView: View {
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts
    
    var message: ChatMessage
    var isFirst: Bool
    
    public var body: some View {
        Text(message.text)
            .standardPadding()
            .messageBubble(for: message, isFirst: isFirst)
            .foregroundColor(Color(colors.text))
            .font(fonts.body)
    }
}

public struct EmojiTextView: View {
    var message: ChatMessage
    
    @Injected(\.fonts) var fonts
    
    public var body: some View {
        Text(message.text)
            .font(fonts.emoji)
    }
}
