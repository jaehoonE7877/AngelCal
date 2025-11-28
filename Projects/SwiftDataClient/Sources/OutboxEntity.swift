import Foundation
import SwiftData

/// Persisted Outbox entry used for deferred sync operations.
@Model
public final class OutboxEntity {
    @Attribute(.unique) public var id: UUID
    public var entityType: String
    public var entityLocalID: UUID
    public var operation: String
    public var payload: Data
    public var createdAt: Date
    public var retryCount: Int
    public var lastError: String?
    
    public init(
        id: UUID = UUID(),
        entityType: String,
        entityLocalID: UUID,
        operation: String,
        payload: Data,
        createdAt: Date = Date(),
        retryCount: Int = 0,
        lastError: String? = nil
    ) {
        self.id = id
        self.entityType = entityType
        self.entityLocalID = entityLocalID
        self.operation = operation
        self.payload = payload
        self.createdAt = createdAt
        self.retryCount = retryCount
        self.lastError = lastError
    }
}

/// Immutable Sendable snapshot of an outbox entry.
public struct OutboxEntitySnapshot: Sendable {
    public let id: UUID
    public let entityType: String
    public let entityLocalID: UUID
    public let operation: String
    public let payload: Data
    public let createdAt: Date
    public let retryCount: Int
    public let lastError: String?
}

public extension OutboxEntity {
    /// Returns an immutable snapshot for cross-actor use.
    func snapshot() -> OutboxEntitySnapshot {
        OutboxEntitySnapshot(
            id: id,
            entityType: entityType,
            entityLocalID: entityLocalID,
            operation: operation,
            payload: payload,
            createdAt: createdAt,
            retryCount: retryCount,
            lastError: lastError
        )
    }
}
