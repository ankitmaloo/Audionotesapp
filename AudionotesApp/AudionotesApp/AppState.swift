import Foundation

@MainActor
final class AppState: ObservableObject {
    enum Tab: Hashable {
        case notes
        case recording
    }

    @Published var activeTab: Tab = .notes
}
