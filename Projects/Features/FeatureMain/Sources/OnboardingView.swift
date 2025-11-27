import SwiftUI
import ComposableArchitecture

public struct OnboardingFeature: Reducer {
    public struct State: Equatable {
        public init() {}
    }
    public enum Action { case complete }
    public init() {}
    public var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .complete:
                return .none
            }
        }
    }
}

public struct OnboardingView: View {
    let store: StoreOf<OnboardingFeature>
    let onComplete: () -> Void
    
    public init(store: StoreOf<OnboardingFeature>, onComplete: @escaping () -> Void) {
        self.store = store
        self.onComplete = onComplete
    }
    
    public var body: some View {
        VStack(spacing: 24) {
            Text("AngelCal")
                .font(.largeTitle).bold()
            Text("월/주 달력을 한눈에 보고 빠르게 일정을 추가하세요.")
                .multilineTextAlignment(.center)
            Button("시작하기") {
                onComplete()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
