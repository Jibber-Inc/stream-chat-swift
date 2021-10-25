//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat
import UIKit

/// View model for the `ChatChannelListView`.
public class ChatChannelListViewModel: ObservableObject, ChatChannelListControllerDelegate {
    /// Context provided dependencies.
    @Injected(\.chatClient) var chatClient: ChatClient
    @Injected(\.images) var images: Images
    @Injected(\.utils) var utils: Utils
    
    /// Context provided utils.
    internal lazy var imageLoader = utils.imageLoader
    internal lazy var imageCDN = utils.imageCDN
    internal lazy var imageProcessor = utils.imageProcessor
    internal lazy var imageMerger = utils.imageMerger
    internal lazy var channelNamer = utils.channelNamer
    
    /// Placeholder images.
    internal lazy var placeholder1 = images.userAvatarPlaceholder1
    internal lazy var placeholder2 = images.userAvatarPlaceholder2
    internal lazy var placeholder3 = images.userAvatarPlaceholder3
    internal lazy var placeholder4 = images.userAvatarPlaceholder4
    
    /// The maximum number of images that combine to form a single avatar
    private let maxNumberOfImagesInCombinedAvatar = 4
    
    private var controller: ChatChannelListController!
    
    /// Used when screen is shown from a deeplink.
    private var selectedChannelId: String?
    
    /// Controls loading the channels.
    @Atomic private var loadingNextChannels: Bool = false
    
    /// Published variables.
    @Published var channels = LazyCachedMapCollection<ChatChannel>()
    @Published var selectedChannel: ChatChannel?
    @Published var deeplinkChannel: ChatChannel?
    @Published var loadedImages = [String: UIImage]()
    @Published var currentChannelId: String?
    @Published var channelAlertType: ChannelAlertType? {
        didSet {
            if channelAlertType != nil {
                alertShown = true
            }
        }
    }

    @Published var customChannelPopupType: ChannelPopupType? {
        didSet {
            if customChannelPopupType != nil {
                customAlertShown = true
            } else {
                customAlertShown = false
            }
        }
    }

    @Published var alertShown = false
    @Published var loading = false
    @Published var customAlertShown = false
    
    public init(selectedChannelId: String? = nil) {
        self.selectedChannelId = selectedChannelId
        makeChannelListController()
    }
    
    /// Returns the name for the specified channel.
    ///
    /// - Parameter channel: the channel whose display name is asked for.
    /// - Returns: `String` with the channel name.
    public func name(forChannel channel: ChatChannel) -> String {
        channelNamer(channel, chatClient.currentUserId) ?? ""
    }
    
    /// Checks if there are new channels to be loaded.
    ///
    /// - Parameter index: the currently displayed index.
    public func checkForChannels(index: Int) {
        if index < controller.channels.count - 10 {
            return
        }

        if _loadingNextChannels.compareAndSwap(old: false, new: true) {
            controller.loadNextChannels { [weak self] _ in
                guard let self = self else { return }
                self.loadingNextChannels = false
                self.channels = self.controller.channels
            }
        }
    }
    
    /// Returns the image avatar for the provided channel.
    ///
    /// - Parameter channel: the provided channel.
    /// - Returns: The resolved image avatar.
    public func image(for channel: ChatChannel) -> UIImage {
        if let image = loadedImages[channel.cid.id] {
            return image
        }
        
        if let url = channel.imageURL {
            loadChannelThumbnail(for: channel, from: url)
            return placeholder4
        }
        
        if channel.isDirectMessageChannel {
            let lastActiveMembers = self.lastActiveMembers(for: channel)
            if let otherMember = lastActiveMembers.first, let url = otherMember.imageURL {
                loadChannelThumbnail(for: channel, from: url)
                return placeholder3
            } else {
                return placeholder4
            }
        } else {
            let activeMembers = lastActiveMembers(for: channel)
            
            if activeMembers.isEmpty {
                return placeholder4
            }
            
            let urls = activeMembers
                .compactMap(\.imageURL)
                .prefix(maxNumberOfImagesInCombinedAvatar)
            
            if urls.isEmpty {
                return placeholder3
            } else {
                loadMergedAvatar(from: channel, urls: Array(urls))
                return placeholder4
            }
        }
    }
    
    /// Determines whether an online indicator is shown.
    ///
    /// - Parameter channel: the provided channel.
    /// - Returns: Boolean whether the indicator is shown.
    public func onlineIndicatorShown(for channel: ChatChannel) -> Bool {
        !channel.lastActiveMembers.filter { member in
            member.isOnline && member.id != chatClient.currentUserId
        }
        .isEmpty
    }
    
    public func onDeleteTapped(channel: ChatChannel) {
        channelAlertType = .deleteChannel(channel)
    }
    
    public func onMoreTapped(channel: ChatChannel) {
        customChannelPopupType = .moreActions(channel)
    }
    
    public func delete(channel: ChatChannel) {
        let controller = chatClient.channelController(
            for: .init(type: .messaging, id: channel.cid.id)
        )
         
        controller.deleteChannel { error in
            if error != nil {
                // handle error
                self.channelAlertType = .error
            }
        }
    }
    
    // MARK: - ChatChannelListControllerDelegate
    
    public func controllerWillChangeChannels(_ controller: ChatChannelListController) {
        channels = controller.channels
    }
    
    public func controller(
        _ controller: ChatChannelListController,
        didChangeChannels changes: [ListChange<ChatChannel>]
    ) {
        channels = controller.channels
    }
    
    public func controller(
        _ controller: ChatChannelListController,
        shouldAddNewChannelToList channel: ChatChannel
    ) -> Bool {
        true
    }
    
    public func controller(
        _ controller: ChatChannelListController,
        shouldListUpdatedChannel channel: ChatChannel
    ) -> Bool {
        true
    }
    
    // MARK: - private
    
    private func checkForDeeplinks() {
        if let selectedChannelId = selectedChannelId,
           let channelId = try? ChannelId(cid: selectedChannelId) {
            let chatController = chatClient.channelController(
                for: channelId,
                messageOrdering: .topToBottom
            )
            deeplinkChannel = chatController.channel
            self.selectedChannelId = nil
        }
    }
    
    private func makeChannelListController() {
        controller = chatClient.channelListController(
            query: .init(filter: .containMembers(userIds: [chatClient.currentUserId!]))
        )
        controller.delegate = self
        
        channels = controller.channels
        
        loading = true
        controller.synchronize { [unowned self] error in
            loading = false
            if error != nil {
                // handle error
                channelAlertType = .error
            } else {
                // access channels
                self.channels = controller.channels
                self.checkForDeeplinks()
            }
        }
    }
    
    private func lastActiveMembers(for channel: ChatChannel) -> [ChatChannelMember] {
        channel.lastActiveMembers
            .sorted { $0.memberCreatedAt < $1.memberCreatedAt }
            .filter { $0.id != chatClient.currentUserId }
    }
    
    private func loadChannelThumbnail(
        for channel: ChatChannel,
        from url: URL
    ) {
        imageLoader.loadImage(
            url: url,
            imageCDN: imageCDN,
            resize: true,
            preferredSize: .avatarThumbnailSize
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(image):
                self.loadedImages[channel.cid.id] = image
            case let .failure(error):
                // TODO: proper logger.
                print("error loading image: \(error.localizedDescription)")
            }
        }
    }
    
    private func loadMergedAvatar(from channel: ChatChannel, urls: [URL]) {
        imageLoader.loadImages(
            from: urls,
            placeholders: [],
            loadThumbnails: true,
            thumbnailSize: .avatarThumbnailSize,
            imageCDN: imageCDN
        ) { [weak self] images in
            guard let self = self else { return }
            DispatchQueue.global(qos: .userInteractive).async {
                let image = self.createMergedAvatar(from: images) ?? self.placeholder2
                DispatchQueue.main.async {
                    self.loadedImages[channel.cid.id] = image
                }
            }
        }
    }
}

/// Enum for the type of alert presented in the channel list view.
public enum ChannelAlertType {
    case deleteChannel(ChatChannel)
    case error
}

/// Enum describing the type of the custom popup for channel actions.
public enum ChannelPopupType {
    /// Shows the 'more actions' popup.
    case moreActions(ChatChannel)
}
