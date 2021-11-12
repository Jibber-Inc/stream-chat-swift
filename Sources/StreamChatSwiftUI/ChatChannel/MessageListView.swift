//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

import StreamChat
import SwiftUI

struct MessageListView<Factory: ViewFactory>: View, KeyboardReadable {
    @Injected(\.utils) var utils
    
    var factory: Factory
    @Binding var messages: LazyCachedMapCollection<ChatMessage>
    @Binding var messagesGroupingInfo: [String: [String]]
    @Binding var scrolledId: String?
    @Binding var showScrollToLatestButton: Bool
    @Binding var currentDateString: String?
    var isGroup: Bool
    var unreadCount: Int
    
    var onMessageAppear: (Int) -> Void
    var onScrollToBottom: () -> Void
    var onLongPress: (MessageDisplayInfo) -> Void
    
    @State private var width: CGFloat?
    @State private var height: CGFloat?
    @State private var keyboardShown = false
    
    private var dateFormatter: DateFormatter {
        utils.dateFormatter
    }
    
    private let scrollAreaId = "scrollArea"
    
    var body: some View {
        ZStack {
            ScrollViewReader { scrollView in
                ScrollView {
                    GeometryReader { proxy in
                        let frame = proxy.frame(in: .named(scrollAreaId))
                        let offset = frame.minY
                        let width = frame.width
                        let height = frame.height
                        Color.clear.preference(key: ScrollViewOffsetPreferenceKey.self, value: offset)
                        Color.clear.preference(key: WidthPreferenceKey.self, value: width)
                        Color.clear.preference(key: HeightPreferenceKey.self, value: height)
                    }
                    
                    LazyVStack(spacing: 0) {
                        ForEach(messages, id: \.messageId) { message in
                            MessageContainerView(
                                factory: factory,
                                message: message,
                                isInGroup: isGroup,
                                width: width,
                                showsAllInfo: showsAllData(for: message),
                                onLongPress: onLongPress
                            )
                            .padding(.horizontal, 8)
                            .padding(.bottom, showsAllData(for: message) ? 8 : 2)
                            .flippedUpsideDown()
                            .onAppear {
                                let index = messages.firstIndex { msg in
                                    msg.id == message.id
                                }
                                
                                if let index = index {
                                    onMessageAppear(index)
                                }
                            }
                        }
                    }
                }
                .coordinateSpace(name: scrollAreaId)
                .onPreferenceChange(WidthPreferenceKey.self) { value in
                    if let value = value, value != width {
                        self.width = value
                    }
                }
                .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { value in
                    showScrollToLatestButton = value ?? 0 < -20
                }
                .onPreferenceChange(HeightPreferenceKey.self) { value in
                    if let value = value, value != height {
                        self.height = value
                    }
                }
                .flippedUpsideDown()
                .frame(minWidth: self.width, minHeight: height)
                .onChange(of: scrolledId) { scrolledId in
                    if let scrolledId = scrolledId {
                        self.scrolledId = nil
                        withAnimation {
                            scrollView.scrollTo(scrolledId, anchor: .bottom)
                        }
                    }
                }
            }
            
//            if !viewModel.typingUsers.isEmpty {
//                VStack {
//                    Spacer()
//                    HStack {
//                        Text("\(viewModel.typingUsers[0]) is typing...")
//                            .padding(.horizontal)
//                            .padding(.vertical, 2)
//                        Spacer()
//                    }
//                    .background(Color.white.opacity(0.9))
//                }
//            }
//
            if showScrollToLatestButton {
                ScrollToBottomButton(
                    unreadCount: unreadCount,
                    onScrollToBottom: onScrollToBottom
                )
            }
            
            if let date = currentDateString {
                DateIndicatorView(date: date)
            }
        }
        .onReceive(keyboardPublisher) { visible in
            keyboardShown = visible
        }
        .modifier(HideKeyboardOnTapGesture(shouldAdd: keyboardShown))
    }
    
    private func showsAllData(for message: ChatMessage) -> Bool {
        let dateString = dateFormatter.string(from: message.createdAt)
        let prefix = message.author.id
        let key = "\(prefix)-\(dateString)"
        let inMessagingGroup = messagesGroupingInfo[key]?.contains(message.id) ?? false
        return inMessagingGroup
    }
}

public struct ScrollToBottomButton: View {
    @Injected(\.images) var images
    @Injected(\.colors) var colors
    
    private let buttonSize: CGFloat = 40
    
    var unreadCount: Int
    var onScrollToBottom: () -> Void
    
    public var body: some View {
        BottomRightView {
            Button {
                onScrollToBottom()
            } label: {
                Image(uiImage: images.scrollDownArrow)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: buttonSize, height: buttonSize)
                    .modifier(ShadowViewModifier(cornerRadius: buttonSize / 2))
            }
            .padding()
            .overlay(
                unreadCount > 0 ?
                    UnreadButtonIndicator(unreadCount: unreadCount) : nil
            )
        }
    }
}

struct UnreadButtonIndicator: View {
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts
    
    private let size: CGFloat = 16
    
    var unreadCount: Int
    
    var body: some View {
        Text("\(unreadCount)")
            .lineLimit(1)
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .font(fonts.footnoteBold)
            .frame(width: unreadCount < 10 ? size : nil, height: size)
            .padding(.horizontal, unreadCount < 10 ? 2 : 6)
            .background(Color(colors.highlightedAccentBackground))
            .cornerRadius(9)
            .foregroundColor(Color(colors.staticColorText))
            .offset(y: -size)
    }
}

public struct DateIndicatorView: View {
    @Injected(\.colors) var colors
    @Injected(\.fonts) var fonts
    
    var date: String
    
    public var body: some View {
        VStack {
            Text(date)
                .font(fonts.footnote)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .foregroundColor(.white)
                .background(Color(colors.textLowEmphasis))
                .cornerRadius(16)
                .padding(.all, 8)
            Spacer()
        }
    }
}
