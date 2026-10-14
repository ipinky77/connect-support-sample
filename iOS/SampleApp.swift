import SwiftUI

@main struct ScreenshotSampleApp: App {
    @State private var state = SampleState()
    var body: some Scene {
        WindowGroup { RootView(state: state) }
    }
}
