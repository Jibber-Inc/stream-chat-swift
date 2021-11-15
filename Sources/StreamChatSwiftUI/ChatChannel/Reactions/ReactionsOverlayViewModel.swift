//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import Combine
import StreamChat
import SwiftUI

public class ReactionsOverlayViewModel: ObservableObject, ChatMessageControllerDelegate {
    @Injected(\.chatClient) var chatClient
    
    @Published var message: ChatMessage
    @Published var errorShown = false
    
    private var messageController: ChatMessageController?
    
    public init(message: ChatMessage) {
        self.message = message
        makeMessageController()
    }
    
    func reactionTapped(_ reaction: MessageReactionType) {
        if userReactionIDs.contains(reaction) {
            // reaction should be removed
            messageController?.deleteReaction(reaction)
        } else {
            // reaction should be added
            messageController?.addReaction(reaction)
        }
    }
    
    // MARK: - ChatMessageControllerDelegate
    
    public func messageController(
        _ controller: ChatMessageController,
        didChangeMessage change: EntityChange<ChatMessage>
    ) {
        if let message = controller.message {
            self.message = message
        }
    }
    
    // MARK: - private
    
    private func makeMessageController() {
        if let channelId = message.cid {
            messageController = chatClient.messageController(
                cid: channelId,
                messageId: message.id
            )
            messageController?.synchronize()
            messageController?.delegate = self
            if let message = messageController?.message {
                self.message = message
            }
        }
    }
    
    private var userReactionIDs: Set<MessageReactionType> {
        Set(message.currentUserReactions.map(\.type))
    }
}
