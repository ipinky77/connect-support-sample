import SwiftUI

struct RootView: View {
    @Environment(\.openSettings) private var openSettings
    @Environment(\.locale) private var locale
    @Bindable var state: SampleState
    var body: some View {
        TabView(selection: $state.tab) {
            NavigationStack(path: $state.path) {
                DeviceList()
                    .navigationDestination(for: Device.self) { DeviceDetail(device: $0, state: state) }
                    .toolbar {
                        ToolbarItemGroup {
                            SettingsLink { Label("Settings", systemImage: "gearshape") }
                            Button("Show welcome", systemImage: "sparkles") { state.showOverlay = true }
                            Button("Notifications", systemImage: "bell") { state.showPopover = true }
                                .popover(isPresented: $state.showPopover) {
                                    IncidentPopover().environment(\.locale, locale)
                                }
                        }
                    }
            }.tabItem { Label("Devices", systemImage: "laptopcomputer.and.iphone") }.tag(SampleTab.devices)
            NavigationStack { AppsList() }
                .tabItem { Label("Apps", systemImage: "square.grid.2x2") }.tag(SampleTab.apps)
        }
        .sheet(isPresented: $state.showIncident) { IncidentForm().environment(\.locale, locale) }
        .overlay {
            if state.showOverlay { MainOverlay { state.showOverlay = false } }
        }
        // MARK: - Screenshot Integration: presentation after initial layout
        // Additional launch hook; the tabs, navigation, sheet, and overlay above are standard UI.
        .task {
            // Give the native presentation host its first layout pass.
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            state.presentScreenshotTarget()
            // MARK: - Screenshot Integration: -screenshotScreen settings opens a separate window
            if state.screenshotTarget == .settings { openSettings() }
        }
        // MARK: - Screenshot Integration: stable captures without transition animations
        // Normal launches retain the standard animation behavior.
        .transaction { if state.screenshotMode { $0.disablesAnimations = true } }
        .frame(minWidth: 620, minHeight: 620)
    }
}
