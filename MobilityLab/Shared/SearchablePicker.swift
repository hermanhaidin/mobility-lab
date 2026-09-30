import SwiftUI

/// A settings row that opens a searchable list of options, like Region in Settings › General › Language & Region.
/// Stands in for a `Picker` with `.pickerStyle(.navigationLink)`, which has no search field. Picking an option pops back.
struct SearchablePicker: View {
    let title: String
    let systemImage: String
    let options: [Option]
    @Binding var selection: String

    var body: some View {
        NavigationLink {
            OptionList(title: title, options: options, selection: $selection)
        } label: {
            LabeledContent {
                Text(options.first { $0.id == selection }?.title ?? selection)
            } label: {
                Label(title, systemImage: systemImage)
            }
        }
    }

    /// One option: the code it's saved as, and the text it shows.
    struct Option: Identifiable {
        let id: String
        let title: String
    }
}

/// The pushed list. Its own view, so `dismiss` pops it rather than the row's screen, and the query starts empty every time.
private struct OptionList: View {
    let title: String
    let options: [SearchablePicker.Option]
    @Binding var selection: String

    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        List(matchingOptions) { option in
            Button {
                selection = option.id
                dismiss()
            } label: {
                HStack {
                    Text(option.title)
                    Spacer()
                    if option.id == selection {
                        Image(systemName: "checkmark")
                    }
                }
            }
            // The settings list's `.tint(.primary)` doesn't reach a pushed view: rows came out orange, and so did
            // a checkmark in `.tint`. Black, like the checkmark of the stock Appearance picker next door.
            .foregroundStyle(.primary)
        }
        .overlay {
            if matchingOptions.isEmpty {
                ContentUnavailableView.search(text: query)
            }
        }
        .searchable(text: $query)
        // Typing starts right away, like in the station picker. The title and back button stay while the keyboard is up.
        .searchFocused($isSearchFocused)
        .searchPresentationToolbarBehavior(.avoidHidingContent)
        .onAppear {
            isSearchFocused = true
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }

    /// Matches the shown text or the code, so "USD" finds "US Dollar".
    private var matchingOptions: [SearchablePicker.Option] {
        guard !query.isEmpty else { return options }
        return options.filter { $0.title.localizedStandardContains(query) || $0.id.localizedStandardContains(query) }
    }
}

#Preview {
    @Previewable @State var selection = "USD"
    NavigationStack {
        List {
            SearchablePicker(
                title: "Preferred currency",
                systemImage: "creditcard.fill",
                options: MockData.currencies.map { .init(id: $0.code, title: $0.code) },
                selection: $selection
            )
        }
    }
}
