import SwiftUI

/// The driver's age of a search, as a menu row with the pop-up glyph (⌃⌄) like Figma. Shared by the Rent tab and
/// the search editor.
struct DriverAgeRow: View {
    @Bindable var search: RentSearch

    var body: some View {
        Picker(selection: $search.driverAge) {
            ForEach(RentSearch.driverAges, id: \.self) { age in
                Text(RentSearch.ageLabel(age)).tag(age)
            }
        } label: {
            Label("Driver age", systemImage: "person.text.rectangle")
                .foregroundStyle(.primary)
        }
        .pickerStyle(.menu)
        .tint(.secondary)
    }
}

#Preview {
    List {
        DriverAgeRow(search: RentSearch())
    }
}
