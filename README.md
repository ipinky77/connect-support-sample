# Connect Support Screenshot Sample

A standalone SwiftUI sample app for Screenshot Creator. No credentials, purchases, network access, or dependencies are required. All information is fictional. English and German are included. Normal launches use the same fixed sample data; screenshot launch arguments also prepare the requested state and disable transition animations.

## Open and run

Open `Screenshot Sample.xcodeproj` in Xcode. Choose the **Screenshot Sample iOS** scheme for iPhone/iPad or **Screenshot Sample macOS** for Mac. Minimum versions: iOS 17 and macOS 14. Synchronized folders require Xcode 16 or later. To run on a physical iOS device, select your own Development Team and change the bundle identifier if necessary.

Devices contains iPhone, iPad, and Mac. Selecting an entry opens its detail view with a segmented picker and Create Incident button. In the toolbar, the sparkles button opens the overlay and the bell opens the native popover. Apps is the second tab. Create Incident presents a sheet over the current detail view. Done and Cancel dismiss it; no data is sent or saved. On iPhone, `presentationCompactAdaptation(.popover)` keeps the presentation as a popover. On macOS, the sheet is attached to the window.

## Screenshot targets

Under **Product → Scheme → Edit Scheme → Run → Arguments**, add two launch arguments, such as `-screenshotScreen` and `create-incident`. Optionally add `-AppleLanguages` and `(de)`, plus `-AppleLocale` and `de_DE`. Screenshot Creator supplies language and region automatically; do not include these Apple arguments in the screen configuration.

| Argument value | Prepared state |
|---|---|
| `main` | Devices with Main view and three devices |
| `device-detail` | Mac → Overview |
| `device-specifications` | Mac → Specifications |
| `create-incident` | Mac detail view → prefilled sheet |
| `main-overlay` | Devices → welcome overlay |
| `apps` | Apps tab |
| `incident-popover` | Devices → popover anchored to the bell |

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
2. Use `cssc devices` to find a simulator UUID and replace the placeholder in `devices[0].id`.
3. Set `outputDirectory` and `logDirectory`. To view reports in Connect Support, use its actual log folder. The `/absolute/path/to/…` entries are placeholders; replace them with real absolute paths on your Mac.
4. Run `cssc capture /absolute/path/screenshots.example.json`.

Alternatively, import the JSON in Connect Support under Create Screenshots, choose the simulator and folders, and export it again. The current CLI supports only iOS simulators. The macOS target demonstrates the same navigation but cannot yet be captured with this CLI. Existing images remain protected when `overwriteExisting` is `false`.

## Platform structure

Core contains models, views shared without platform-specific changes, images, and translations, and belongs to both targets. iOS and macOS contain separate app entry points and RootViews, and belong exclusively to their respective targets. Target membership uses synchronized Xcode folders. There are no conditional platform checks.

Repository: [connect-support-sample](https://github.com/ipinky77/connect-support-sample). The PDF integration guide will follow separately.
