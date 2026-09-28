import SwiftUI

extension Binding where Value == Bool {
    /// Whether a set contains an element, for a toggle: turning it on inserts the element, turning it off removes it.
    init<Element: Hashable & Sendable>(_ set: Binding<Set<Element>>, contains element: Element) {
        self.init {
            set.wrappedValue.contains(element)
        } set: { isOn in
            if isOn {
                set.wrappedValue.insert(element)
            } else {
                set.wrappedValue.remove(element)
            }
        }
    }
}
