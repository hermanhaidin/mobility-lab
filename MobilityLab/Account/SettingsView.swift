import SwiftUI

/// App settings, opened from the login sheet. Rows without a design yet open a placeholder.
struct SettingsView: View {
    @AppStorage(SettingsKey.appearance) private var appearance = Appearance.system
    @AppStorage(SettingsKey.currencyCode) private var currencyCode = "USD"
    @AppStorage(SettingsKey.countryCode) private var countryCode = "US"
    @AppStorage(SettingsKey.showsAllServices) private var showsAllServices = true

    var body: some View {
        List {
            Section {
                NavigationLink {
                    PlaceholderView(title: "Help center", systemImage: "headphones")
                } label: {
                    Label("Help center", systemImage: "headphones")
                }

                Picker(selection: $appearance) {
                    ForEach(Appearance.allCases) { appearance in
                        Text(appearance.title).tag(appearance)
                    }
                } label: {
                    Label("Appearance", systemImage: "paintbrush.fill")
                }

                SearchablePicker(
                    title: "Preferred currency",
                    systemImage: "creditcard.fill",
                    options: currencies,
                    selection: $currencyCode
                )

                SearchablePicker(
                    title: "Country",
                    systemImage: "globe.europe.africa.fill",
                    options: countries,
                    selection: $countryCode
                )

                NavigationLink {
                    PlaceholderView(title: "About this App", systemImage: "info.circle")
                } label: {
                    Label("About this App", systemImage: "info.circle")
                }

                NavigationLink {
                    PlaceholderView(title: "Privacy settings", systemImage: "shield.lefthalf.filled")
                } label: {
                    Label("Privacy settings", systemImage: "shield.lefthalf.filled")
                }

                NavigationLink {
                    PlaceholderView(title: "Communication preferences", systemImage: "bubble.left")
                } label: {
                    Label("Communication preferences", systemImage: "bubble.left")
                }

                Toggle(isOn: $showsAllServices) {
                    Label("Show all SIXT services", systemImage: "plus.magnifyingglass")
                }
                .tint(Color(.accent))
            } footer: {
                Text(versionText)
            }
            // Black icons. `.tint(.primary)` on the list did it too, but reached the Appearance picker's list and
            // turned its checkmark black. A row trait, so it goes on the section, not the list.
            .listItemTint(.primary)
        }
        .pickerStyle(.navigationLink)
        .navigationTitle("Settings")
    }

    private var currencies: [SearchablePicker.Option] {
        MockData.currencies
            .map { .init(id: $0.code, title: Locale.current.localizedString(forCurrencyCode: $0.code) ?? $0.code) }
            .sorted { $0.title < $1.title }
    }

    private var countries: [SearchablePicker.Option] {
        MockData.countryCodes
            .map { (code: $0, name: Locale.current.localizedString(forRegionCode: $0) ?? $0) }
            .sorted { $0.name < $1.name }
            .map { .init(id: $0.code, title: "\(Locale.Region($0.code).flag) \($0.name)") }
    }

    private var versionText: String {
        let info = Bundle.main.infoDictionary ?? [:]
        let bundleID = Bundle.main.bundleIdentifier ?? ""
        let version = info["CFBundleShortVersionString"] as? String ?? ""
        let build = info["CFBundleVersion"] as? String ?? ""
        return "App version \(bundleID) | v\(version) (\(build))"
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
