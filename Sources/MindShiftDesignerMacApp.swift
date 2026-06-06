import SwiftUI

@main
struct MindShiftDesignerMacApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup("MindShift Designer") {
            MainView()
                .environment(appState)
        }
        .defaultSize(width: 1100, height: 780)
        .commands {
            CommandGroup(replacing: .newItem) {}
        }

        Settings {
            SettingsView()
                .frame(width: 460)
        }
    }
}

// ── App-weiter Zustand ────────────────────────────────────────────────────────

@Observable
class AppState {
    enum ActiveView { case home, wizard }
    var currentView: ActiveView = .home
    var statusMessage: String = ""

    var alertTitle: String = ""
    var alertMessage: String = ""
    var showAlert: Bool = false

    func showInfo(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }

    func showError(_ message: String) {
        alertTitle = "Fehler"
        alertMessage = message
        showAlert = true
    }
}
