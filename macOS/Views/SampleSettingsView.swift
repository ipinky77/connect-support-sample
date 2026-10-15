import SwiftUI

/// Normal macOS settings UI with deterministic sample values; no data is saved.
struct SampleSettingsView: View {
    private enum Page: String, CaseIterable, Identifiable {
        case general, notifications, privacy
        var id: Self { self }
        var title: LocalizedStringKey {
            switch self {
            case .general: "General"
            case .notifications: "Notifications"
            case .privacy: "Privacy"
            }
        }
        func windowTitle(locale: Locale) -> String {
            switch self {
            case .general: String(localized: "General", locale: locale)
            case .notifications: String(localized: "Notifications", locale: locale)
            case .privacy: String(localized: "Privacy", locale: locale)
            }
        }
        var icon: String {
            switch self {
            case .general: "gearshape"
            case .notifications: "bell"
            case .privacy: "hand.raised"
            }
        }
    }

    @Environment(\.locale) private var locale
    @State private var selection: Page?
    @State private var showDeviceDetails = true
    @State private var incidentNotifications = true
    @State private var includeDiagnostics = false

    // MARK: - Screenshot Integration: optional Settings page argument
    // -screenshotScreen settings opens this window; -screenshotSettingsPage chooses its page.
    // The same initializer handles Xcode launch arguments and CS's native session arguments.
    init(arguments: [String] = ProcessInfo.processInfo.arguments) {
        var page = Page.general
        if let index = arguments.firstIndex(of: "-screenshotSettingsPage"), arguments.indices.contains(index + 1) {
            page = Page(rawValue: arguments[index + 1]) ?? .general
        }
        _selection = State(initialValue: page)
    }

    var body: some View {
        NavigationSplitView {
            List(Page.allCases, selection: $selection) { page in
                Label(page.title, systemImage: page.icon).tag(page)
            }
            .listStyle(.sidebar)
            .navigationSplitViewColumnWidth(min: 160, ideal: 180, max: 240)
        } detail: {
            Form {
                switch selection ?? .general {
                case .general:
                    Section("Sample Preferences") {
                        Toggle("Show device details", isOn: $showDeviceDetails)
                        LabeledContent("Sample account", value: "Alex Morgan")
                    }
                case .notifications:
                    Section("Incident Notifications") {
                        Toggle("Notify about new incidents", isOn: $incidentNotifications)
                        Text("Notification settings are examples only. No notifications are sent.")
                    }
                case .privacy:
                    Section("Diagnostics") {
                        Toggle("Include diagnostics", isOn: $includeDiagnostics)
                        Text("This sample does not collect or transmit personal data.")
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle((selection ?? .general).windowTitle(locale: locale))
        }
        .frame(minWidth: 640, idealWidth: 780, minHeight: 480, idealHeight: 540)
    }
}
