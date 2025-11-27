import Foundation
import SwiftDataClient

public actor OutboxService {
    private let swiftDataClient: SwiftDataClient
    private let maxRetry: Int
    private let backoff: [TimeInterval]
    
    public init(swiftDataClient: SwiftDataClient, maxRetry: Int = 5, backoff: [TimeInterval] = [1,5,30,300,1800]) {
        self.swiftDataClient = swiftDataClient
        self.maxRetry = maxRetry
        self.backoff = backoff
    }
    
    public func enqueue(entityType: String, entityLocalID: UUID, operation: String, payload: Data) async throws {
        try await swiftDataClient.addToOutbox(entityType: entityType, entityLocalID: entityLocalID, operation: operation, payload: payload)
    }
    
    public func pending() async throws -> [OutboxEntity] {
        try await swiftDataClient.getPendingOutbox()
    }
    
    public func success(_ outbox: OutboxEntity) async throws {
        try await swiftDataClient.deleteOutbox(outbox)
    }
    
    public func failure(_ outbox: OutboxEntity, error: any Error) async throws {
        let message = String(describing: error)
        if outbox.retryCount < maxRetry {
            try await swiftDataClient.incrementOutboxRetry(outbox, error: message)
            if outbox.retryCount < backoff.count {
                try await Task.sleep(nanoseconds: UInt64(backoff[outbox.retryCount]) * 1_000_000_000)
            }
        }
    }
}
