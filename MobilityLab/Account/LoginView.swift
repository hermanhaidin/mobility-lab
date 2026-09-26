import SwiftUI

/// Sign in with an email address. The prototype has no accounts, so Continue just closes the sheet.
struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(.horizontal)
                    .frame(minHeight: 52)
                    .background(Color(.secondarySystemBackground), in: .capsule)

                Button {
                    dismiss()
                } label: {
                    Text("Continue")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glassProminent)
                .controlSize(.large)
                .disabled(email.isEmpty)

                HStack(spacing: 12) {
                    VStack { Divider() }
                    Text("Don’t have an account?")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .fixedSize()
                    VStack { Divider() }
                }

                NavigationLink {
                    PlaceholderView(title: "Create account", systemImage: "person.crop.circle.badge.plus")
                } label: {
                    Text("Create account")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .foregroundStyle(.primary)

                Spacer()

                Text(policies)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .tint(.primary)
            }
            .padding([.top, .horizontal])
            .navigationTitle("Welcome back")
            .navigationSubtitle("Enter your email to enjoy the best experience.")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink("Settings") {
                        SettingsView()
                    }
                }
            }
        }
    }

    /// Policy links, underlined like on the website. They open sixt.com.
    private var policies: AttributedString {
        let markdown = """
            See our policies for [Privacy](https://www.sixt.com), [Analytics](https://www.sixt.com), \
            and [Accessibility](https://www.sixt.com).
            [(Imprint)](https://www.sixt.com)
            """
        var text = (try? AttributedString(markdown: markdown, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace))) ?? AttributedString()
        for run in text.runs where run.link != nil {
            text[run.range].underlineStyle = .single
        }
        return text
    }
}

#Preview {
    LoginView()
}
