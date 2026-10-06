import SwiftUI

/// The dates of a search: one summary row, like a new event in Calendar, until it's tapped. Then the Pick-up and
/// Drop-off pickers take its place, with times in 30-minute steps (set in `MobilityLabApp`). Shared by the Rent tab
/// and the search editor.
struct DateRows: View {
    @Bindable var search: RentSearch

    @State private var isEditing = false

    var body: some View {
        if isEditing {
            DatePicker("Pick-up", selection: $search.pickUpDate, in: Date.now...)
            DatePicker("Drop-off", selection: $search.dropOffDate, in: search.pickUpDate...)
        } else {
            Button(
                (search.pickUpDate..<search.dropOffDate)
                    .formatted(.interval.day().month(.abbreviated).hour().minute()),
                systemImage: "calendar"
            ) {
                withAnimation {
                    isEditing = true
                }
            }
            .foregroundStyle(.primary)
        }
    }
}

#Preview {
    List {
        DateRows(search: RentSearch())
    }
}
