//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat

/// Factory used to create view models.
public class ViewModelsFactory {
    private init() {}
    
    /// Creates the `ChannelListViewModel`.
    ///
    /// - Parameters:
    ///    - channelListController: possibility to inject custom channel list controller.
    ///    - selectedChannelId: pre-selected channel id (used for deeplinking).
    /// - Returns: `ChatChannelListViewModel`.
    public static func makeChannelListViewModel(
        channelListController: ChatChannelListController? = nil,
        selectedChannelId: String? = nil
    ) -> ChatChannelListViewModel {
        ChatChannelListViewModel(
            channelListController: channelListController,
            selectedChannelId: selectedChannelId
        )
    }
    
    /// Creates the `ChatChannelViewModel`.
    /// - Parameter channelController: the channel controller.
    public static func makeChannelViewModel(
        with channelController: ChatChannelController
    ) -> ChatChannelViewModel {
        let viewModel = ChatChannelViewModel(channelController: channelController)
        return viewModel
    }
    
    /// Creates the `NewChatViewModel`.
    public static func makeNewChatViewModel() -> NewChatViewModel {
        let viewModel = NewChatViewModel()
        return viewModel
    }
    
    /// Creates the view model for the more channel actions.
    ///
    /// - Parameters:
    ///   - channel: the provided channel.
    ///   - actions: list of the channel actions.
    /// - Returns: `MoreChannelActionsViewModel`.
    public static func makeMoreChannelActionsViewModel(
        channel: ChatChannel,
        actions: [ChannelAction]
    ) -> MoreChannelActionsViewModel {
        let viewModel = MoreChannelActionsViewModel(
            channel: channel,
            channelActions: actions
        )
        return viewModel
    }
    
    public static func makeMessageComposerViewModel(
        with channelController: ChatChannelController
    ) -> MessageComposerViewModel {
        MessageComposerViewModel(channelController: channelController)
    }
}