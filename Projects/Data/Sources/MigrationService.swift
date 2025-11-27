import Foundation

public struct MigrationService {
    public init() {}
    /// 게스트 모드 -> 로그인 시 로컬 데이터를 서버에 업로드하는 스켈레톤
    public func migrateGuestDataIfNeeded() async throws {
        // TODO: Outbox 항목을 우선 처리하거나, 게스트 로컬 데이터를 신규 계정으로 업로드
    }
}
