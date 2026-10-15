import SwiftUI
import AppKit
import Observation

// MARK: - Screenshot Integration
/// Cooperative setup works when Connect Support is sandboxed and launch arguments are ignored.
@MainActor @Observable final class SampleScreenshotSession {
    struct Configuration: Decodable {
        let session: String
        let width: Int
        let height: Int
        let language: String
        let locale: String
        let arguments: [String]
    }

    enum Target: Equatable { case main, settings }
    var captureTarget: Target {
        state.screenshotTarget == .settings ? .settings : .main
    }

    private(set) var state = SampleState()
    var arguments: [String] { configuration?.arguments ?? ProcessInfo.processInfo.arguments }

    // MARK: - Screenshot Integration: localized session state
    private(set) var configuration: Configuration?
    var locale: Locale { configuration.map { Locale(identifier: $0.locale) } ?? .current }
    private var setupObserver: NSObjectProtocol?
    private var closeObserver: NSObjectProtocol?

    // MARK: - Screenshot Integration: listen for sandbox-compatible CS requests
    init() {
        setupObserver = DistributedNotificationCenter.default().addObserver(
            forName: Notification.Name("ch.inmood.ConnectSupport.capture.configure.\(ProcessInfo.processInfo.processIdentifier)"),
            object: nil, queue: .main) { [weak self] notification in
                guard let object = notification.object as? String, let data = object.data(using: .utf8),
                      let configuration = try? JSONDecoder().decode(Configuration.self, from: data) else { return }
                MainActor.assumeIsolated { self?.apply(configuration) }
            }
    }

    // MARK: - Screenshot Integration: reuse normal navigation for the requested screen
    private func apply(_ incoming: Configuration) {
        guard UUID(uuidString: incoming.session) != nil,
              (640...4000).contains(incoming.width), (400...3000).contains(incoming.height) else { return }
        guard configuration?.session != incoming.session else { return }
        // Reuse the same argument parser and app state as a normal Xcode launch.
        state = SampleState(arguments: ["Screenshot Sample"] + incoming.arguments)
        configuration = incoming
        if let closeObserver { DistributedNotificationCenter.default().removeObserver(closeObserver) }
        closeObserver = DistributedNotificationCenter.default().addObserver(
            forName: Notification.Name("ch.inmood.ConnectSupport.capture.stop." + incoming.session),
            object: nil, queue: .main) { [weak self] _ in
                MainActor.assumeIsolated { self?.closeCaptureInstance() }
            }
    }

    // MARK: - Screenshot Integration: close only the capture instance
    private func closeCaptureInstance() {
        // Dismiss through SwiftUI bindings first, otherwise SwiftUI can recreate a
        // sheet that was ended only through AppKit.
        state.showIncident = false
        state.showPopover = false
        state.showOverlay = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let app = NSApplication.shared
            for window in app.windows {
                if let sheet = window.attachedSheet {
                    window.endSheet(sheet, returnCode: .cancel)
                    sheet.orderOut(nil)
                }
            }
            if app.modalWindow != nil { app.abortModal() }
            DispatchQueue.main.async { app.terminate(nil) }
        }
    }

    // MARK: - Screenshot Integration: return the actual window ID and size
    func confirmWindow(_ window: NSWindow) {
        guard let configuration else { return }
        DistributedNotificationCenter.default().postNotificationName(
            Notification.Name("ch.inmood.ConnectSupport.capture.ready." + configuration.session),
            object: String(decoding: (try? JSONSerialization.data(withJSONObject: [
                "session": configuration.session,
                "processID": ProcessInfo.processInfo.processIdentifier,
                "windowID": window.windowNumber,
                "width": window.frame.width,
                "height": window.frame.height
            ])) ?? Data(), as: UTF8.self),
            userInfo: nil, options: [.deliverImmediately])
    }


}

// MARK: - Screenshot Integration: size and identify the requested native window
struct SampleScreenshotWindow: NSViewRepresentable {
    let session: SampleScreenshotSession
    var target: SampleScreenshotSession.Target = .main
    func makeNSView(context: Context) -> SizingView { SizingView() }
    func updateNSView(_ view: SizingView, context: Context) {
        view.session = session
        view.target = target
        view.applySize()
    }

    final class SizingView: NSView {
        var session: SampleScreenshotSession?
        var target: SampleScreenshotSession.Target = .main
        private var appliedSession: String?

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            applySize()
        }

        func applySize() {
            guard let window, let session, let configuration = session.configuration,
                  target == session.captureTarget, appliedSession != configuration.session else { return }
            appliedSession = configuration.session
            DispatchQueue.main.async { [weak window] in
                guard let window else { return }
                var frame = window.frame
                frame.size = NSSize(width: configuration.width, height: configuration.height)
                let fits: (NSScreen) -> Bool = { screen in
                    screen.visibleFrame.width >= frame.width && screen.visibleFrame.height >= frame.height
                }
                guard let screen = window.screen.flatMap({ fits($0) ? $0 : nil }) ?? NSScreen.screens.first(where: fits) else {
                    session.confirmWindow(window)
                    return
                }
                let visible = screen.visibleFrame
                frame.origin.x = visible.midX - frame.width / 2
                frame.origin.y = visible.midY - frame.height / 2
                window.setFrame(frame, display: true)
                session.confirmWindow(window)
            }
        }
    }
}
