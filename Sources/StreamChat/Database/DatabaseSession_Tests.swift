//
// Copyright © 2021 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatTestTools
import XCTest

class DatabaseSession_Tests: XCTestCase {
    var database: DatabaseContainerMock!
    
    override func setUp() {
        super.setUp()
        database = DatabaseContainerMock()
    }
    
    override func tearDown() {
        AssertAsync.canBeReleased(&database)
        super.tearDown()
    }
    
    func test_eventPayloadChannelData_isSavedToDatabase() {
        // Prepare an Event payload with a channel data
        let channelId: ChannelId = .unique
        let channelPayload = dummyPayload(with: channelId)
        
        let eventPayload = EventPayload(
            eventType: .notificationAddedToChannel,
            connectionId: .unique,
            cid: channelPayload.channel.cid,
            channel: channelPayload.channel
        )
        
        // Save the event payload to DB
        database.write { session in
            try session.saveEvent(payload: eventPayload)
        }
        
        // Try to load the saved channel from DB
        var loadedChannel: ChatChannel? {
            database.viewContext.channel(cid: channelId)?.asModel()
        }
        
        AssertAsync.willBeEqual(loadedChannel?.cid, channelId)
        
        // Try to load a saved channel owner from DB
        if let userId = channelPayload.channel.createdBy?.id {
            var loadedUser: ChatUser? {
                database.viewContext.user(id: userId)?.asModel()
            }
            
            AssertAsync.willBeEqual(loadedUser?.id, userId)
        }
        
        // Try to load the saved member from DB
        if let member = channelPayload.channel.members?.first {
            var loadedMember: ChatUser? {
                database.viewContext.member(userId: member.user.id, cid: channelId)?.asModel()
            }
            
            AssertAsync.willBeEqual(loadedMember?.id, member.user.id)
        }
    }
    
    func test_messageData_isSavedToDatabase() throws {
        // Prepare an Event payload with a message data
        let channelId: ChannelId = .unique
        let messageId: MessageId = .unique
        
        let channelPayload: ChannelDetailPayload = dummyPayload(with: channelId).channel
        
        let userPayload: UserPayload = .init(
            id: .unique,
            name: .unique,
            imageURL: .unique(),
            role: .admin,
            createdAt: .unique,
            updatedAt: .unique,
            lastActiveAt: .unique,
            isOnline: true,
            isInvisible: true,
            isBanned: true,
            extraData: [:]
        )
        
        let messagePayload = MessagePayload(
            id: messageId,
            type: .regular,
            user: userPayload,
            createdAt: channelPayload.createdAt.addingTimeInterval(300),
            updatedAt: .unique,
            text: "No, I am your father 🤯",
            showReplyInChannel: false,
            mentionedUsers: [],
            replyCount: 0,
            extraData: [:],
            reactionScores: [:],
            reactionCounts: [:],
            isSilent: false,
            isShadowed: false,
            attachments: []
        )
        
        let eventPayload: EventPayload = .init(
            eventType: .messageNew,
            connectionId: .unique,
            cid: channelId,
            currentUser: nil,
            user: nil,
            createdBy: nil,
            memberContainer: nil,
            channel: channelPayload,
            message: messagePayload,
            reaction: nil,
            watcherCount: nil,
            unreadCount: nil,
            createdAt: nil,
            isChannelHistoryCleared: false,
            banReason: nil,
            banExpiredAt: nil
        )
        
        // Save the event payload to DB
        database.write { session in
            try session.saveEvent(payload: eventPayload)
        }
        
        // Try to load the saved message from DB
        var loadedMessage: ChatMessage? {
            database.viewContext.message(id: messageId)?.asModel()
        }
        AssertAsync.willBeTrue(loadedMessage != nil)
        
        // Verify the channel has the message
        let loadedChannel: ChatChannel = try XCTUnwrap(database.viewContext.channel(cid: channelId)?.asModel())
        let message = try XCTUnwrap(loadedMessage)
        XCTAssert(loadedChannel.latestMessages.contains(message))
    }
    
    func test_deleteMessage() throws {
        let channelId: ChannelId = .unique
        let messageId: MessageId = .unique

        // Create current user in the DB
        try database.createCurrentUser()
        
        // Create channel in the DB
        try database.createChannel(cid: channelId)
        
        // Save the message to the DB and remember the messageId
        try database.createMessage(id: messageId, cid: channelId)
        
        // Delete the message from the DB
        try database.writeSynchronously { session in
            let dto = try XCTUnwrap(session.message(id: messageId))
            session.delete(message: dto)
        }
        
        // Assert message is deleted
        XCTAssertNil(database.viewContext.message(id: messageId))
    }

    func test_pinMessage() throws {
        let channelId: ChannelId = .unique
        let messageId: MessageId = .unique

        // Create current user in the DB
        try database.createCurrentUser()

        // Create channel in the DB
        try database.createChannel(cid: channelId)

        // Save the message to the DB and remember the messageId
        try database.createMessage(id: messageId, cid: channelId)

        // Pin message
        let expireDate = Date.unique
        try database.writeSynchronously { session in
            let dto = try XCTUnwrap(session.message(id: messageId))
            try session.pin(message: dto, pinning: .expirationDate(expireDate))
        }

        let message = database.viewContext.message(id: messageId)
        XCTAssertNotNil(message)
        XCTAssertNotNil(message?.pinnedAt)
        XCTAssertNotNil(message?.pinnedBy)
        XCTAssertEqual(message?.pinned, true)
        XCTAssertEqual(message?.pinExpires, expireDate)
    }

    func test_pinMessage_whenNoCurrentUser_throwsError() throws {
        let channelId: ChannelId = .unique
        let messageId: MessageId = .unique

        // Create channel in the DB
        try database.createChannel(cid: channelId)

        // Save the message to the DB and remember the messageId
        try database.createMessage(id: messageId, cid: channelId)

        XCTAssertThrowsError(
            // Pin message
            try database.writeSynchronously { session in
                let dto = try XCTUnwrap(session.message(id: messageId))
                try session.pin(message: dto, pinning: MessagePinning(expirationDate: .unique))
            }
        ) { error in
            XCTAssertTrue(error is ClientError.CurrentUserDoesNotExist)
        }
    }

    func test_unpinMessage() throws {
        let channelId: ChannelId = .unique
        let messageId: MessageId = .unique

        // Create current user in the DB
        try database.createCurrentUser()

        // Create channel in the DB
        try database.createChannel(cid: channelId)

        // Save the message to the DB and remember the messageId
        try database.createMessage(id: messageId, cid: channelId)

        // Unpin message
        try database.writeSynchronously { session in
            let dto = try XCTUnwrap(session.message(id: messageId))
            try session.pin(message: dto, pinning: .expirationTime(300))
            session.unpin(message: dto)
        }

        let message = database.viewContext.message(id: messageId)
        XCTAssertNotNil(message)
        XCTAssertNil(message?.pinnedAt)
        XCTAssertNil(message?.pinnedBy)
        XCTAssertNil(message?.pinExpires)
        XCTAssertEqual(message?.pinned, false)
    }
    
    func test_saveEvent_unreadCountFromEventPayloadIsApplied() throws {
        let eventPayload = EventPayload(
            eventType: .messageNew,
            connectionId: .unique,
            cid: .unique,
            currentUser: .dummy(
                userId: .unique,
                role: .user,
                unreadCount: nil
            ),
            unreadCount: .dummy
        )
        
        try database.writeSynchronously { session in
            try session.saveEvent(payload: eventPayload)
        }
        
        // Load current user
        let currentUser = database.viewContext.currentUser
        
        // Assert unread count is taken from event payload
        XCTAssertEqual(Int64(eventPayload.unreadCount!.messages), currentUser?.unreadMessagesCount)
        XCTAssertEqual(Int64(eventPayload.unreadCount!.channels), currentUser?.unreadChannelsCount)
    }
    
    func test_saveCurrentUserUnreadCount_failsIfThereIsNoCurrentUser() throws {
        func saveUnreadCountWithoutUser() throws {
            try database.writeSynchronously {
                try $0.saveCurrentUserUnreadCount(count: .dummy)
            }
        }
        
        XCTAssertThrowsError(try saveUnreadCountWithoutUser()) { error in
            XCTAssertTrue(error is ClientError.CurrentUserDoesNotExist)
        }
    }
    
    func test_saveEvent_doesNotChangeLastSyncedDate() throws {
        let lastSyncedAt: Date = .unique
        
        // Create current user in database.
        try database.createCurrentUser()
        
        // Update `lastSyncedAt` value
        try database.writeSynchronously { session in
            session.currentUser?.lastSyncedAt = lastSyncedAt
        }
        
        // Create event payload with specific `createdAt` date
        let eventPayload = EventPayload(
            eventType: .messageNew,
            connectionId: .unique,
            cid: .unique,
            currentUser: .dummy(
                userId: .unique,
                role: .user,
                unreadCount: nil
            ),
            unreadCount: .dummy,
            createdAt: .unique
        )
        
        // Save event to the database
        try database.writeSynchronously { session in
            try session.saveEvent(payload: eventPayload)
        }
        
        // Load current user
        let currentUser = database.viewContext.currentUser
        
        // Assert `eventPayload.createdAt` was not updated
        XCTAssertEqual(currentUser?.lastSyncedAt, lastSyncedAt)
    }
}
