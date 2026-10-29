# Connect Support Screenshot Sample

**Documentation revision 1.1 · 2026-10-29:** Clarified the required macOS window-adapter modifier order and the window-readiness timeout it prevents.

A standalone SwiftUI sample app for AbbzThor Screenshot Creator (formerly Connect Support). No credentials, purchases, network access, or dependencies are required. All information is fictional. English and German are included. Normal launches use the same fixed sample data; screenshot launch arguments also prepare the requested state and disable transition animations.

## Open and run

Open `Screenshot Sample.xcodeproj` in Xcode. Choose the **Screenshot Sample iOS** scheme for iPhone/iPad or **Screenshot Sample macOS** for Mac. Minimum versions: iOS 17 and macOS 14. Synchronized folders require Xcode 16 or later. To run on a physical iOS device, select your own Development Team and change the bundle identifier if necessary.

Devices contains iPhone, iPad, and Mac. Selecting an entry opens its detail view with a segmented picker and Create Incident button. In the toolbar, the sparkles button opens the overlay and the bell opens the native popover. Apps is the second tab. Create Incident presents a sheet over the current detail view. Done and Cancel dismiss it; no data is sent or saved. On iPhone, `presentationCompactAdaptation(.popover)` keeps the presentation as a popover. On macOS, the sheet is attached to the window.

## Screenshot targets

Under **Product → Scheme → Edit Scheme → Run → Arguments**, add two launch arguments, such as `-screenshotScreen` and `create-incident`. Optionally add `-AppleLanguages` and `(de)`, plus `-AppleLocale` and `de_DE`. AbbzThor supplies language and region automatically; do not include these Apple arguments in the screen configuration.

| Argument value | Prepared state |
|---|---|
| `main` | Devices with Main view and three devices |
| `device-detail` | Mac → Overview |
| `device-specifications` | Mac → Specifications |
| `create-incident` | Mac detail view → prefilled sheet |
| `main-overlay` | Devices → welcome overlay |
| `apps` | Apps tab |
| `incident-popover` | Devices → popover anchored to the bell |
| `settings` (macOS) | Separate Settings window → General; optionally choose a page with `-screenshotSettingsPage` |

`Core/Models/SampleState.swift` reads the arguments and sets the tab, navigation path, and selected segment before the first render. RootView presents the sheet, overlay, or popover in `.task`, after a brief 300 ms startup delay to allow the native presentation host its first layout pass. This is not a general readiness signal for asynchronous data. Unknown targets are reported in the console and open the normal main view. The app does not load data asynchronously or use time-dependent data. The CLI currently has no readiness handshake; the example configuration waits eight seconds. Always inspect the resulting images visually.

## Find the screenshot integration in code

Use Xcode's **Find in Workspace** (Shift-Command-F) and search for `MARK: - Screenshot Integration`. Every screenshot-specific addition starts with this marker, followed by a description. The comments distinguish the integration from the app's normal navigation and presentation code. No separate screenshot views are used.

| File | Marked addition compared with a standard app |
|---|---|
| `Core/Models/SampleState.swift` | Target identifiers: the names accepted by `-screenshotScreen`. |
| `Core/Models/SampleState.swift` | Launch state: the optional target and screenshot-mode flag. |
| `Core/Models/SampleState.swift` | Argument parsing and initial navigation: select an existing tab, device detail, and segment before rendering. |
| `Core/Models/SampleState.swift` | Automatic presentation: open the requested sheet, overlay, or popover using the same flags as normal user actions. |
| `iOS/Views/RootView.swift` and `macOS/Views/RootView.swift` | Presentation after initial layout: call the screenshot presentation hook from `.task`. |
| `iOS/Views/RootView.swift` and `macOS/Views/RootView.swift` | Stable captures: disable transition animations only in screenshot mode. |

The `TabView`, `NavigationStack`, navigation destinations, segmented picker, toolbar buttons, `.sheet`, `.overlay`, and `.popover` are standard app implementation. Their bindings are also used by the screenshot integration. Keep this normal UI when adapting the example to your app; add the marked launch handling around your own navigation state.

The fixed data in `Device.examples` and the prefilled incident are sample content used during both normal and screenshot launches. They are not a screenshot-only data override. In a production app, provide deterministic screenshot fixtures instead of live data when screenshot mode is enabled, and mark that additional branch with the same comment marker. Language and region are supplied through Apple's launch arguments; no custom screenshot-specific localization code is needed in the views.

## Custom images

Add your images to the four prepared image sets in `Core/Assets.xcassets`:

- `DeviceiPhone`
- `DeviceiPad`
- `DeviceMac`
- `MainOverlay`

Empty sets are intentional placeholders. Until images are added, SF Symbols appear on a light background. Images with an opaque background cover the underlying symbol; for transparent images, remove the fallback in `AssetPicture` if needed. No external image files are required.

## Screenshot Creator CLI

`Configuration/screenshots.example.json` contains seven targets and two languages (14 images per simulator). Before running:

1. Set `projectPath` to the project's actual absolute path.
2. Use `atsc devices` to find a simulator UUID and replace the placeholder in `devices[0].id`.
3. Set `outputDirectory` and `logDirectory`. To view reports in AbbzThor, use its actual log folder. The `/absolute/path/to/…` entries are placeholders; replace them with real absolute paths on your Mac.
4. Run `atsc capture /absolute/path/screenshots.example.json`.

Alternatively, import the JSON in AbbzThor under Screenshot Creator, choose the simulator and folders, and export it again. The `atsc` CLI captures iOS simulators; native macOS captures run directly inside AbbzThor as described below. `cssc` is the compatibility alias for the earlier CLI name. Existing images remain protected when `overwriteExisting` is `false`.

## Platform structure

Core contains models, views shared without platform-specific changes, images, and translations, and belongs to both targets. iOS and macOS contain separate app entry points and RootViews, and belong exclusively to their respective targets. Target membership uses synchronized Xcode folders. There are no conditional platform checks.

Repository: [connect-support-sample](https://github.com/ipinky77/connect-support-sample). The PDF integration guide will follow separately.


## Capture a macOS app in AbbzThor

Native Mac screenshots run directly in AbbzThor. They use a separate app instance for each screen and language, with a cooperative adapter inside the target app. The `atsc` simulator command does not run this workflow.

1. Build the **Screenshot Sample macOS** scheme. Locate the newly built **Screenshot Sample macOS.app** in Xcode's Products folder and reveal it in Finder. Rebuild and select the updated app after changing the adapter or screenshot destinations.
2. Select the app in AbbzThor, open **Screenshot Creator**, and import `Configuration/screenshots.macos.example.json`.
3. Enable **Capture macOS**, select the built app and choose a **Screenshot Size** that fits the available display workspace. Select an **Assets Folder**. The JSON has no simulator devices; its output/log paths are placeholders. Configure actual folders in AbbzThor.
4. Review **Languages** and **Screens**. The example includes the seven main-window destinations and three Settings pages, in English and German.
5. Use **Test Window** on an individual screen, especially Settings, to check that the intended window opens at the requested size. **Test Dimensions** uses the first screen and first selected language. These actions open a test instance without saving a screenshot.
6. Grant AbbzThor Screen Recording permission when requested, then use **Create macOS Screenshots**. The capture includes the title bar, without a shadow, and is saved at the selected pixel dimensions under `language/Mac` in the Assets Folder.
7. Inspect the images. Existing images are retained; remove the images you want to recreate in Manage Assets or Finder, then run the capture again. Close a dimensions-test instance when finished, or let AbbzThor close it when ending/replacing the test.

The app must accommodate the requested complete window size, including its title bar. Minimum sizes and the menu bar/Dock can limit the available workspace. If the window cannot reach the selected dimensions, AbbzThor rejects the reported size instead of capturing another window. The readiness reply identifies and sizes the window; the configured per-screen wait still allows the content and presentations to settle before capture.

## Separate Settings windows

The sample implements a normal SwiftUI `Settings` scene in `macOS/SampleApp.swift`, opened through the app menu or `SettingsLink`. `SampleSettingsView` has General, Notifications and Privacy pages with fixed, nonpersistent sample values.

For a direct Xcode launch, add these separate enabled arguments:

```text
-screenshotScreen
settings
-screenshotSettingsPage
notifications
```

Supported pages are `general` (default), `notifications`, and `privacy`. The screenshot hook calls `openSettings()` after the main view has mounted. The Settings view reads the page from the same argument array used by the screenshot session.

Settings owns a separate native window. Attach the adapter to the content of that scene, not only to the main view:

```swift
Settings {
    SampleSettingsView(arguments: screenshots.arguments)
        .background(
            SampleScreenshotWindow(session: screenshots, target: .settings)
                .frame(width: 0, height: 0)
        )
        .id(screenshots.configuration?.session ?? "normal-settings")
        .environment(\.locale, screenshots.locale)
}
```

The main window uses the default `.main` role. `captureTarget` selects `.settings` for the Settings destination, so only the Settings window sizes itself and reports readiness. The main window may remain open. No window title, manually entered window ID, toolbar-button lookup or foreground-window guess is needed in AbbzThor.

### Important: attach the adapter before the session identity

Keep `.background(SampleScreenshotWindow(...).frame(width: 0, height: 0))` **before** `.id(screenshots.configuration?.session ?? ...)`, as shown above, in both the main and Settings scenes. SwiftUI modifiers wrap the preceding view: this order places the native window adapter inside the view subtree that is recreated for each capture session.

The adapter remembers the session for which it has already applied window sizing. If the adapter is placed after `.id(...)`, it is outside that recreated subtree and can retain stale sizing/window state while the content is replaced. The requested screen may open correctly, yet AbbzThor can time out with **“The app did not confirm a screenshot window ID.”** A fresh adapter inside the session identity reconnects to the actual window, applies its size and sends the `capture.ready.<session>` reply.

The zero-sized frame keeps this helper from affecting the SwiftUI layout; it is not the requested capture-window size. That size comes from the session configuration and is applied to the native `NSWindow`.

## Adapting this pattern to a separate Help window

A separate Help window is an extension pattern; this sample currently implements Settings, not a Help destination. To add Help to your own app:

1. Add `help` to `ScreenshotTarget` and to `SampleScreenshotSession.Target`. Extend `captureTarget` to return `.help` for that destination.
2. Define a normal macOS `Window("Help", id: "help")` scene containing your existing Help view. Attach `SampleScreenshotWindow(session: screenshots, target: .help)` to that scene's content and apply the session identity and locale as in Settings above.
3. In the main view, obtain `@Environment(\.openWindow) private var openWindow`. In the screenshot presentation hook, call `openWindow(id: "help")` when the destination is `.help`, after the view has mounted.
4. Add a screen to the capture configuration with arguments `["-screenshotScreen", "help"]`. Use **Test Window** to verify that the Help window, rather than the still-open main window, confirms its ID and dimensions.

Use the same window and opening action during normal use and screenshot preparation. A Help sheet attached to the main window is a different presentation: keep it driven by its normal SwiftUI binding, and report the intended capture window accordingly. The separate-window pattern does not require converting existing sheets into windows.

## Native session protocol and closing the capture instance

`macOS/Services/SampleScreenshotSession.swift` contains the native adapter. Keep it in the macOS target. The protocol names retain `ConnectSupport` for compatibility with AbbzThor; do not rename them to match the product name.

| Direction | Distributed notification name | JSON string in `object` |
|---|---|---|
| AbbzThor → app | `ch.inmood.ConnectSupport.capture.configure.<processID>` | `session` (UUID), `width`, `height`, `language`, `locale`, `arguments` |
| App → AbbzThor | `ch.inmood.ConnectSupport.capture.ready.<session>` | `session`, `processID`, `windowID`, actual `width`, actual `height` |
| AbbzThor → app | `ch.inmood.ConnectSupport.capture.stop.<session>` | No payload |

The configuration travels as a JSON string in `object`, without `userInfo`, to support the sandboxed caller. This also supplies arguments when launch arguments are unavailable through NSWorkspace. The app feeds them into its existing `SampleState` parser, applies the locale, recreates the view for the new session and opens the requested destination. `SampleScreenshotWindow` obtains the actual `NSWindow`, sizes and centers it on a fitting display, and returns its window number. AbbzThor matches both the process ID and window ID before capture.

The stop request ends the dedicated screenshot instance, including its separate Settings or Help windows. It does not press a view's Done button. This sample first clears the SwiftUI presentation bindings (`showIncident`, `showPopover`, `showOverlay`), allows dismissal to run, ends any remaining attached sheets, aborts an active modal loop and then calls `NSApplication.shared.terminate(nil)`. Clearing the bindings matters: ending a sheet only through AppKit can leave SwiftUI's presentation state active and cause the sheet to appear again. Extend this cleanup for additional presentation state in your app. Register the stop observer only for an accepted screenshot session; a normal launch has no such session.

Search for **MARK: - Screenshot Integration** to find the target names, argument parser, Settings launch hook, native session listener, per-window sizing, window-ID response and shutdown handling. The adapter is shared by the app's macOS scenes through one `SampleScreenshotSession`; each scene reports only for its own role. Core remains shared, and native adapters and platform-specific views stay in their respective synchronized Xcode folders.
