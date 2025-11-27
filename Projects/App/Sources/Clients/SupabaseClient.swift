import Foundation
import Supabase
import ComposableArchitecture

// Define dependency key
private enum SupabaseClientKey: DependencyKey {
    static let liveValue = SupabaseClient(
        supabaseURL: URL(string: AppConfig.supabaseURL)!,
        supabaseKey: AppConfig.supabaseAnonKey
    )
}

extension DependencyValues {
    var supabase: SupabaseClient {
        get { self[SupabaseClientKey.self] }
        set { self[SupabaseClientKey.self] = newValue }
    }
}
