import SwiftUI

struct DeviceList: View {
    var body: some View {
        List {
            Text("Main view").font(.title2.bold())
            ForEach(Device.examples) { device in
                NavigationLink(value: device) { Label(device.id, systemImage: device.symbol) }
            }
        }.navigationTitle("Devices")
    }
}
struct AppsList: View {
    var body: some View {
        List {
            Label("Notes", systemImage: "note.text")
            Label("Calendar", systemImage: "calendar")
            Label("Photos", systemImage: "photo.on.rectangle")
        }.navigationTitle("Apps")
    }
}
struct AssetPicture: View {
    let name: String
    let fallback: String
    var body: some View {
        // Empty image sets are intentional: add your pictures in Assets.xcassets.
        ZStack {
            RoundedRectangle(cornerRadius: 20).fill(.blue.opacity(0.08))
            Image(systemName: fallback).font(.system(size: 72)).foregroundStyle(.blue)
            Image(name).resizable().scaledToFit().padding(16)
        }.frame(height: 180).accessibilityLabel(Text(name))
    }
}
struct DeviceDetail: View {
    let device: Device
    @Bindable var state: SampleState
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                AssetPicture(name: device.asset, fallback: device.symbol)
                Picker("Information", selection: $state.section) {
                    Text("Overview").tag(DetailSection.overview)
                    Text("Specifications").tag(DetailSection.specifications)
                }.pickerStyle(.segmented)
                if state.section == .overview {
                    Text("Device overview").font(.headline)
                    Text("A sample device with fixed information.")
                    LabeledContent("Device ID", value: "DEV-00\(Device.examples.firstIndex(of: device)! + 1)")
                    LabeledContent("Status") { Text("Available") }
                } else {
                    LabeledContent("CPU", value: device.cpu)
                    LabeledContent("Memory", value: device.memory)
                    LabeledContent("Storage", value: device.storage)
                    LabeledContent("Input / Output", value: device.ports)
                }
                Button("Create Incident", systemImage: "plus.bubble") { state.showIncident = true }
                    .buttonStyle(.borderedProminent)
            }.padding()
        }.navigationTitle(device.id)
    }
}
struct IncidentForm: View {
    @Environment(\.dismiss) private var dismiss
    @State private var subject = String(localized: "HDMI display unavailable")
    @State private var message = String(localized: "My external display stays black when connected to HDMI.")
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Create Incident").font(.title2.bold())
            Text("Demo only. No incident is sent.").foregroundStyle(.secondary)
            Form {
                TextField("Subject", text: $subject)
                LabeledContent("Creator", value: "Alex Morgan")
                LabeledContent("Device ID", value: "DEV-003")
                TextField("Message", text: $message, axis: .vertical).lineLimit(3...6)
            }
            HStack {
                Button("Cancel") { dismiss() }
                Spacer()
                Button("Done") { dismiss() }.buttonStyle(.borderedProminent)
            }
        }.padding().frame(minWidth: 300, minHeight: 360)
    }
}
struct IncidentPopover: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("New incident arrived", systemImage: "bell.badge").font(.headline)
            Text("HDMI display unavailable").font(.subheadline.bold())
            LabeledContent("Creator", value: "Alex Morgan")
            LabeledContent("Device ID", value: "DEV-003")
            Text("My external display stays black when connected to HDMI.")
        }.padding().frame(width: 280)
    }
}
struct MainOverlay: View {
    let close: () -> Void
    var body: some View {
        ZStack {
            Color.black.opacity(0.25).ignoresSafeArea()
            VStack(spacing: 16) {
                AssetPicture(name: "MainOverlay", fallback: "sparkles")
                Text("Welcome").font(.title2.bold())
                Text("Explore your devices and apps.")
                Button("Continue", action: close).buttonStyle(.borderedProminent)
            }.padding(24).frame(maxWidth: 330)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24))
                .padding()
        }.accessibilityAddTraits(.isModal)
    }
}
