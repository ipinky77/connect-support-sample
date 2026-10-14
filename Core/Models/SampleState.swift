import SwiftUI

enum SampleTab: String { case devices, apps }
enum DetailSection: String, CaseIterable { case overview, specifications }
// MARK: - Screenshot Integration: target identifiers
// Additional to normal navigation: names accepted by -screenshotScreen.
enum ScreenshotTarget: String, CaseIterable {
    case main, deviceDetail = "device-detail", deviceSpecifications = "device-specifications"
    case createIncident = "create-incident", mainOverlay = "main-overlay", apps, incidentPopover = "incident-popover"
}
// MARK: - Standard app models
struct Device: Identifiable, Hashable {
    let id: String
    let symbol: String
    let cpu: String
    let memory: String
    let storage: String
    let ports: String
    var asset: String { "Device" + id }
    static let examples = [
        Device(id: "iPhone", symbol: "iphone", cpu: "A18", memory: "8 GB", storage: "256 GB", ports: "USB-C"),
        Device(id: "iPad", symbol: "ipad", cpu: "M4", memory: "16 GB", storage: "1 TB", ports: "USB-C · Smart Connector"),
        Device(id: "Mac", symbol: "laptopcomputer", cpu: "M4 Pro", memory: "24 GB", storage: "512 GB", ports: "MagSafe · 3 × USB-C · HDMI")
    ]
}
@MainActor @Observable final class SampleState {
    var tab: SampleTab = .devices
    var path: [Device] = []
    var section: DetailSection = .overview
    var showIncident = false
    var showOverlay = false
    var showPopover = false
    // MARK: - Screenshot Integration: launch state
    // Normal launches leave screenshotTarget nil and keep the default navigation state.
    let screenshotTarget: ScreenshotTarget?
    var screenshotMode: Bool { screenshotTarget != nil }
    // MARK: - Screenshot Integration: argument parsing and initial navigation
    // Reuse the normal tab, path, and segment instead of creating screenshot-only views.
    init(arguments: [String] = ProcessInfo.processInfo.arguments) {
        if let index = arguments.firstIndex(of: "-screenshotScreen"), arguments.indices.contains(index + 1) {
            screenshotTarget = ScreenshotTarget(rawValue: arguments[index + 1])
            if screenshotTarget == nil { print("Unknown screenshot target: \(arguments[index + 1])") }
        } else { screenshotTarget = nil }
        switch screenshotTarget {
        case .deviceDetail, .deviceSpecifications, .createIncident:
            path = [Device.examples[2]]
            if screenshotTarget == .deviceSpecifications { section = .specifications }
        case .apps: tab = .apps
        default: break
        }
    }
    // MARK: - Screenshot Integration: automatic presentation
    // Reuse the same presentation flags as the normal toolbar and detail buttons.
    // Present only after the navigation host has mounted. No network or data loading is needed.
    func presentScreenshotTarget() {
        switch screenshotTarget {
        case .createIncident: showIncident = true
        case .mainOverlay: showOverlay = true
        case .incidentPopover: showPopover = true
        default: break
        }
    }
}
