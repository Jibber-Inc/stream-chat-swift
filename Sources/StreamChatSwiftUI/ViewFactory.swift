//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import Foundation
import Photos
import StreamChat
import SwiftUI

/// Factory used to create views.
public protocol ViewFactory: AnyObject {
    var chatClient: ChatClient { get }
    
    /// Returns the navigation bar display mode.
    func navigationBarDisplayMode() -> NavigationBarItem.TitleDisplayMode
    
    // MARK: - channels
    
    associatedtype HeaderViewModifier: ChannelListHeaderViewModifier
    /// Creates the channel list header view modifier.
    ///  - Parameter title: the title displayed in the header.
    func makeChannelListHeaderViewModifier(title: String) -> HeaderViewModifier
    
    associatedtype NoChannels: View
    /// Creates the view that is displayed when there are no channels available.
    func makeNoChannelsView() -> NoChannels
    
    associatedtype LoadingContent: View
    /// Creates the loading view.
    func makeLoadingView() -> LoadingContent
    
    associatedtype ChannelListItemType: View
    func makeChannelListItem(
        currentChannelId: Binding<String?>,
        channel: ChatChannel,
        channelName: String,
        avatar: UIImage,
        onlineIndicatorShown: Bool,
        disabled: Bool,
        selectedChannel: Binding<ChatChannel?>,
        channelDestination: @escaping (ChatChannel) -> ChannelDestination,
        onItemTap: @escaping (ChatChannel) -> Void,
        onDelete: @escaping (ChatChannel) -> Void,
        onMoreTapped: @escaping (ChatChannel) -> Void
    ) -> ChannelListItemType
    
    associatedtype MoreActionsView: View
    /// Creates the more channel actions view.
    /// - Parameters:
    ///  - channel: the channel where the actions are applied.
    ///  - onDismiss: handler when the more actions view is dismissed.
    ///  - onError: handler when an error happened.
    func makeMoreChannelActionsView(
        for channel: ChatChannel,
        onDismiss: @escaping () -> Void,
        onError: @escaping (Error) -> Void
    ) -> MoreActionsView
    
    /// Returns the supported  channel actions.
    /// - Parameters:
    ///  - channel: the channel where the actions are applied.
    ///  - onDismiss: handler when the more actions view is dismissed.
    ///  - onError: handler when an error happened.
    /// - Returns: list of `ChannelAction` items.
    func suppotedMoreChannelActions(
        for channel: ChatChannel,
        onDismiss: @escaping () -> Void,
        onError: @escaping (Error) -> Void
    ) -> [ChannelAction]
    
    // MARK: - messages
    
    associatedtype ChannelDestination: View
    /// Returns a function that creates the channel destination.
    func makeChannelDestination() -> (ChatChannel) -> ChannelDestination
    
    associatedtype UserAvatar: View
    /// Creates the message avatar view.
    /// - Parameter author: the message author whose avatar is displayed.
    func makeMessageAvatarView(for author: ChatUser) -> UserAvatar
    
    associatedtype ChatHeaderViewModifier: ChatChannelHeaderViewModifier
    /// Creates the channel header view modifier.
    /// - Parameter channel: the displayed channel.
    func makeChannelHeaderViewModifier(for channel: ChatChannel) -> ChatHeaderViewModifier
    
    associatedtype MessageTextViewType: View
    /// Creates the message text view.
    /// - Parameters:
    ///   - message: the message that will be displayed.
    ///   - isFirst: whether it is first in the group (latest creation date).
    ///   - availableWidth: the available width for the view.
    ///  - Returns: view displayed in the text message slot.
    func makeMessageTextView(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat
    ) -> MessageTextViewType
    
    associatedtype ImageAttachmentViewType: View
    /// Creates the image attachment view.
    /// - Parameters:
    ///   - message: the message that will be displayed.
    ///   - isFirst: whether it is first in the group (latest creation date).
    ///   - availableWidth: the available width for the view.
    ///  - Returns: view displayed in the image attachment slot.
    func makeImageAttachmentView(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat
    ) -> ImageAttachmentViewType
    
    associatedtype GiphyAttachmentViewType: View
    /// Creates the giphy attachment view.
    /// - Parameters:
    ///   - message: the message that will be displayed.
    ///   - isFirst: whether it is first in the group (latest creation date).
    ///   - availableWidth: the available width for the view.
    ///  - Returns: view displayed in the giphy attachment slot.
    func makeGiphyAttachmentView(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat
    ) -> GiphyAttachmentViewType
    
    associatedtype LinkAttachmentViewType: View
    /// Creates the link attachment view.
    /// - Parameters:
    ///   - message: the message that will be displayed.
    ///   - isFirst: whether it is first in the group (latest creation date).
    ///   - availableWidth: the available width for the view.
    ///  - Returns: view displayed in the link attachment slot.
    func makeLinkAttachmentView(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat
    ) -> LinkAttachmentViewType
    
    associatedtype FileAttachmentViewType: View
    /// Creates the file attachment view.
    /// - Parameters:
    ///   - message: the message that will be displayed.
    ///   - isFirst: whether it is first in the group (latest creation date).
    ///   - availableWidth: the available width for the view.
    ///  - Returns: view displayed in the file attachment slot.
    func makeFileAttachmentView(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat
    ) -> FileAttachmentViewType
    
    associatedtype VideoAttachmentViewType: View
    /// Creates the video attachment view.
    /// - Parameters:
    ///   - message: the message that will be displayed.
    ///   - isFirst: whether it is first in the group (latest creation date).
    ///   - availableWidth: the available width for the view.
    ///  - Returns: view displayed in the video attachment slot.
    func makeVideoAttachmentView(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat
    ) -> VideoAttachmentViewType
    
    associatedtype DeletedMessageViewType: View
    /// Creates the deleted message view.
    /// - Parameters:
    ///   - message: the deleted message that will be displayed with indicator.
    ///   - isFirst: whether it is first in the group (latest creation date).
    ///   - availableWidth: the available width for the view.
    ///  - Returns: view displayed in the deleted message slot.
    func makeDeletedMessageView(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat
    ) -> DeletedMessageViewType
    
    associatedtype CustomAttachmentViewType: View
    /// Creates custom attachment view.
    /// If support for more than one custom view is needed, just do if-else check inside the view.
    /// - Parameters:
    ///   - message: the message that will be displayed.
    ///   - isFirst: whether it is first in the group (latest creation date).
    ///   - availableWidth: the available width for the view.
    ///  - Returns: view displayed in the custom attachment slot.
    func makeCustomAttachmentViewType(
        for message: ChatMessage,
        isFirst: Bool,
        availableWidth: CGFloat
    ) -> CustomAttachmentViewType
    
    associatedtype GiphyBadgeViewType: View
    /// Creates giphy badge view.
    /// If support for more than one custom view is needed, just do if-else check inside the view.
    /// - Parameters:
    ///   - message: the message that will be displayed.
    ///   - availableWidth: the available width for the view.
    ///  - Returns: view displayed in the giphy badge slot.
    func makeGiphyBadgeViewType(
        for message: ChatMessage,
        availableWidth: CGFloat
    ) -> GiphyBadgeViewType
    
    associatedtype MessageComposerViewType: View
    /// Creates the message composer view.
    /// - Parameters:
    ///  - channelController: The `ChatChannelController` for the channel.
    ///  - onMessageSent: Called when a message is sent.
    /// - Returns: view displayed in the message composer slot.
    func makeMessageComposerViewType(
        with channelController: ChatChannelController,
        onMessageSent: @escaping () -> Void
    ) -> MessageComposerViewType
    
    associatedtype LeadingComposerViewType: View
    /// Creates the leading part of the composer view.
    /// - Parameter state: Indicator what's the current picker state (can be ignored for different types of views).
    /// - Returns: view displayed in the leading part of the message composer view.
    func makeLeadingComposerView(
        state: Binding<PickerTypeState>
    ) -> LeadingComposerViewType
    
    /// Creates the composer input view.
    /// - Parameters:
    ///  - text: the text displayed in the input view.
    ///  - addedAssets: list of the added assets (in case they need to be displayed in the input view).
    ///  - addedFileURLs: list of the added file URLs (in case they need to be displayed in the input view).
    ///  - shouldScroll: whether the input field is scrollable.
    ///  - removeAttachmentWithId: called when the attachment is removed from the input view.
    /// - Returns: view displayed in the middle area of the message composer view.
    associatedtype ComposerInputViewType: View
    func makeComposerInputView(
        text: Binding<String>,
        addedAssets: [AddedAsset],
        addedFileURLs: [URL],
        shouldScroll: Bool,
        removeAttachmentWithId: @escaping (String) -> Void
    ) -> ComposerInputViewType
    
    associatedtype TrailingComposerViewType: View
    /// Creates the trailing composer view.
    /// - Parameters:
    ///  - enabled: whether the view is enabled (e.g. button).
    ///  - onTap: called when the view is tapped.
    /// - Returns: view displayed in the trailing area of the message composer view.
    func makeTrailingComposerView(
        enabled: Bool,
        onTap: @escaping () -> Void
    ) -> TrailingComposerViewType
    
    associatedtype AttachmentPickerViewType: View
    /// Creates the attachment picker view.
    /// - Parameters:
    ///  - attachmentPickerState: currently selected attachment picker.
    ///  - filePickerShown: binding controlling the display of the file picker.
    ///  - cameraPickerShown: binding controlling the display of the camera picker.
    ///  - addedFileURLs: list of the added file urls.
    ///  - onPickerStateChange: called when the picker state is changed.
    ///  - photoLibraryAssets: list of assets fetched from the photo library.
    ///  - onAssetTap: called when an asset is tapped on.
    ///  - isAssetSelected: checks whether an asset is selected.
    ///  - cameraImageAdded: called when an asset from the camera is added.
    ///  - askForAssetsAccessPermissions: provides access to photos library (and others if needed).
    ///  - isDisplayed: thether the attachment picker view is displayed.
    ///  - height: the current  height of the picker.
    ///  - popupHeight: the  height of the popup when displayed.
    /// - Returns: view displayed in the attachment picker slot.
    func makeAttachmentPickerView(
        attachmentPickerState: AttachmentPickerState,
        filePickerShown: Binding<Bool>,
        cameraPickerShown: Binding<Bool>,
        addedFileURLs: Binding<[URL]>,
        onPickerStateChange: @escaping (AttachmentPickerState) -> Void,
        photoLibraryAssets: PHFetchResult<PHAsset>?,
        onAssetTap: @escaping (AddedAsset) -> Void,
        isAssetSelected: @escaping (String) -> Bool,
        cameraImageAdded: @escaping (AddedAsset) -> Void,
        askForAssetsAccessPermissions: @escaping () -> Void,
        isDisplayed: Bool,
        height: CGFloat,
        popupHeight: CGFloat
    ) -> AttachmentPickerViewType
}
