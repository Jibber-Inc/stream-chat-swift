//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

/// View for the chat channel list.
public struct ChatChannelListView<Factory: ViewFactory>: View {
    @Injected(\.fonts) var fonts
    @Injected(\.colors) var colors
    
    @StateObject private var viewModel: ChatChannelListViewModel
    
    private let viewFactory: Factory
    private let title: String
    private var onItemTap: (ChatChannel) -> Void
    private var channelDestination: (ChatChannel) -> Factory.ChannelDestination
    
    public init(
        viewFactory: Factory,
        channelListController: ChatChannelListController? = nil,
        title: String = "Stream Chat",
        onItemTap: ((ChatChannel) -> Void)? = nil,
        selectedChannelId: String? = nil
    ) {
        let channelListVM = ViewModelsFactory.makeChannelListViewModel(
            channelListController: channelListController,
            selectedChannelId: selectedChannelId
        )
        _viewModel = StateObject(
            wrappedValue: channelListVM
        )
        self.viewFactory = viewFactory
        self.title = title
        if let onItemTap = onItemTap {
            self.onItemTap = onItemTap
        } else {
            self.onItemTap = { channel in
                channelListVM.selectedChannel = channel
            }
        }
        
        channelDestination = viewFactory.makeChannelDestination()
    }
    
    public var body: some View {
        NavigationView {
            Group {
                if viewModel.loading {
                    viewFactory.makeLoadingView()
                } else if viewModel.channels.isEmpty {
                    viewFactory.makeNoChannelsView()
                } else {
                    ZStack {
                        ChannelDeepLink(
                            deeplinkChannel: $viewModel.deeplinkChannel,
                            channelDestination: channelDestination
                        )
                        
                        ChannelList(
                            channels: viewModel.channels,
                            selectedChannel: $viewModel.selectedChannel,
                            currentChannelId: $viewModel.currentChannelId,
                            onlineIndicatorShown: viewModel.onlineIndicatorShown(for:),
                            imageLoader: viewModel.image(for:),
                            onItemTap: onItemTap,
                            onItemAppear: viewModel.checkForChannels(index:),
                            channelNaming: viewModel.name(forChannel:),
                            channelDestination: channelDestination,
                            onDelete: viewModel.onDeleteTapped(channel:),
                            onMoreTapped: viewModel.onMoreTapped(channel:)
                        )
                    }
                }
            }
            .alert(isPresented: $viewModel.alertShown) {
                switch viewModel.channelAlertType {
                case let .deleteChannel(channel):
                    return Alert(
                        title: Text(L10n.Alert.Actions.deleteChannelTitle),
                        message: Text(L10n.Alert.Actions.deleteChannelMessage),
                        primaryButton: .destructive(Text(L10n.Alert.Actions.delete)) {
                            viewModel.delete(channel: channel)
                        },
                        secondaryButton: .cancel()
                    )
                default:
                    return Alert(
                        title: Text(L10n.Alert.Error.title),
                        message: Text(L10n.Alert.Error.message),
                        dismissButton: .cancel(Text(L10n.Alert.Actions.ok))
                    )
                }
            }
            .modifier(viewFactory.makeChannelHeaderViewModifier(title: title))
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarTitleDisplayMode(viewFactory.navigationBarDisplayMode())
            .blur(radius: (viewModel.customAlertShown || viewModel.alertShown) ? 6 : 0)
        }
        .overlay(viewModel.customAlertShown ? customViewOverlay() : nil)
    }
    
    @ViewBuilder
    private func customViewOverlay() -> some View {
        switch viewModel.customChannelPopupType {
        case let .moreActions(channel):
            viewFactory.makeMoreChannelActionsView(for: channel) {
                withAnimation {
                    viewModel.customChannelPopupType = nil
                }
            } onError: { error in
                viewModel.showErrorPopup(error)
            }
            .edgesIgnoringSafeArea(.all)
        default:
            EmptyView()
        }
    }
}

extension ChatChannelListView where Factory == DefaultViewFactory {
    public init() {
        self.init(viewFactory: DefaultViewFactory.shared)
    }
}
