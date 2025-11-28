import ComposableArchitecture
import Core
import Foundation

@Reducer
public struct WidgetGuideFeature {
    @ObservableState
    public struct State: Equatable {
        public var lastSuccess: Date?
        public var lastError: String?
        public var retryCount: Int = 0
        public var isRefreshing: Bool = false
        public init() {}
    }
    
    public enum Action {
        case refreshTimeline
        case refreshCompleted(TaskResult<Date>)
        case resetError
    }
    
    @Dependency(\.syncClient) var syncClient
    @Dependency(\.errorReporter) var errorReporter
    @Dependency(\.continuousClock) var clock
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .refreshTimeline:
                state.isRefreshing = true
                return .run { send in
                    await send(.refreshCompleted(TaskResult {
                        try await syncClient.syncEvents()
                        return Date()
                    }))
                }
            case .refreshCompleted(.success(let date)):
                state.isRefreshing = false
                state.lastError = nil
                state.retryCount = 0
                state.lastSuccess = date
                return .none
            case .refreshCompleted(.failure(let error)):
                state.isRefreshing = false
                state.lastError = error.localizedDescription
                errorReporter.handle(error, "WidgetGuideFeature.refresh")
                let retries = min(state.retryCount + 1, 3)
                state.retryCount = retries
                let delay = Duration.seconds(Double(pow(2.0, Double(retries))))
                return .run { send in
                    try await clock.sleep(for: delay)
                    await send(.refreshTimeline)
                }
            case .resetError:
                state.lastError = nil
                return .none
            }
        }
    }
}

public enum WidgetGuideCopy {
    public static let overview = "위젯 타입(오늘/다가오는/월간 미니/스탠드바이 오늘)과 캘린더를 선택해 홈/잠금/스탠드바이에 배치하세요."
    public static let refresh = "타임라인 새로고침이 실패하면 마지막 성공 데이터를 유지하고 백오프 후 자동 재시도합니다."
    public static let deeplink = "위젯을 탭하면 해당 날짜 또는 이벤트 상세로 딥링크됩니다."
    public static let placement = "홈 화면/잠금 화면/스탠드바이에 위젯을 추가한 뒤, 설정에서 연결 캘린더와 최대 이벤트 수를 조정하세요."
}
