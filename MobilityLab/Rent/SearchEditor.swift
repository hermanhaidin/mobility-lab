import SwiftUI

/// The rent search, opened from the offer list to change it. The checkmark applies the changes and turns on once
/// there are some; closing the sheet throws them away. Laid out like a new event in the Calendar app.
struct SearchEditor: View {
    let search: RentSearch

    @Environment(\.dismiss) private var dismiss
    @State private var draft: RentSearch
    @State private var isShowingLogin = false
    @State private var sheetWidth = 0.0

    init(search: RentSearch) {
        self.search = search
        _draft = State(initialValue: search.copy())
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Location") {
                    StationRows(search: draft)
                }

                Section("Dates") {
                    DateRows(search: draft)
                }

                Section("Details") {
                    DriverAgeRow(search: draft)
                }

                Section {
                    Button("Login or register", systemImage: "person") {
                        isShowingLogin = true
                    }
                }
            }
            .listSectionSpacing(.compact)
            .onGeometryChange(for: Double.self) { $0.size.width } action: { sheetWidth = $0 }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .principal) {
                    Picker("Vehicle type", selection: $draft.vehicleType) {
                        ForEach(VehicleType.allCases) { type in
                            Text(type.title).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    // Toolbars give a title item only the width it asks for, even with `.buttonSizing(.flexible)`.
                    // Like in Calendar, the picker asks for the space between the buttons: 44 points each,
                    // 20 from the edges, 12 on either side.
                    .frame(width: sheetWidth > 0 ? sheetWidth - 2 * (20 + 44 + 12) : nil)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        search.update(from: draft)
                        dismiss()
                    }
                    .disabled(draft.isSameSearch(as: search))
                }
            }
            .sheet(isPresented: $isShowingLogin) {
                LoginView()
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
        // Opaque, like Figma's IBE sheet, instead of the glass a medium sheet gets by default.
        .presentationBackground(Color(.systemGroupedBackground))
    }
}

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            SearchEditor(search: RentSearch())
        }
}
