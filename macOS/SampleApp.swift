import SwiftUI

@main struct ScreenshotSampleApp: App {
    // MARK: - Screenshot Integration: native session shared by main and Settings windows
    @State private var screenshots = SampleScreenshotSession()

    var body: some Scene {
        WindowGroup {
            RootView(state: screenshots.state)
                // MARK: - Screenshot Integration: main-window sizing and readiness
                .background(SampleScreenshotWindow(session: screenshots).frame(width: 0, height: 0))
                .id(screenshots.configuration?.session ?? "normal")
                .environment(\.locale, screenshots.locale)
        }

        // Standard macOS Settings scene; SettingsLink also opens it during normal use.
        Settings {
            SampleSettingsView(arguments: screenshots.arguments)
                // MARK: - Screenshot Integration: Settings owns its own capture window
                .background(SampleScreenshotWindow(session: screenshots, target: .settings).frame(width: 0, height: 0))
                .id(screenshots.configuration?.session ?? "normal-settings")
                .environment(\.locale, screenshots.locale)
        }
    }
}
