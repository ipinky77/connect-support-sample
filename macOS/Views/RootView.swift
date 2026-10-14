import SwiftUI

struct RootView: View {
    @Bindable var state: SampleState
    var body: some View {
        TabView(selection: $state.tab) {
            NavigationStack(path: $state.path) {
                DeviceList()
                    .navigationDestination(for: Device.self) { DeviceDetail(device: $0, state: state) }
                    .toolbar {
                        ToolbarItemGroup {
                            Button("Show welcome", systemImage: "sparkles") { state.showOverlay = true }
                            Button("Notifications", systemImage: "bell") { state.showPopover = true }
                                .popover(isPresented: $state.showPopover) {
                                    IncidentPopover()
                                }
                        }
                    }
            }.tabItem { Label("Devices", systemImage: "laptopcomputer.and.iphone") }.tag(SampleTab.devices)
            NavigationStack { AppsList() }
                .tabItem { Label("Apps", systemImage: "square.grid.2x2") }.tag(SampleTab.apps)
        }
        .sheet(isPresented: $state.showIncident) { IncidentForm() }
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
        }
        // MARK: - Screenshot Integration: stable captures without transition animations
        // Normal launches retain the standard animation behavior.
        .transaction { if state.screenshotMode { $0.disablesAnimations = true } }
        .frame(minWidth: 620, minHeight: 620)
    }
}
