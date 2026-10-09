import SwiftUI

struct ServerEditView: View {
    @Environment(ServerStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var server: ServerProfile
    @State private var secret = ""
    @State private var passphrase = ""

    init(server: ServerProfile) {
        _server = State(initialValue: server)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("基本") {
                    TextField("名称（如 猫窝）", text: $server.name)
                    TextField("地址 / 域名", text: $server.host)
                        .autocorrectionDisabled()
                        #if os(iOS)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                        #endif
                    TextField("端口", value: $server.port, format: .number.grouping(.never))
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif
                    TextField("用户名", text: $server.username)
                        .autocorrectionDisabled()
                        #if os(iOS)
                        .textInputAutocapitalization(.never)
                        #endif
                }
                Section("认证") {
                    Picker("方式", selection: $server.authKind.animation(Theme.spring)) {
                        ForEach(ServerProfile.AuthKind.allCases) { Text($0.rawValue) }
                    }
                    .pickerStyle(.segmented)

                    if server.authKind == .password {
                        SecureField("密码", text: $secret)
                    } else {
                        TextField("粘贴 OpenSSH 私钥（-----BEGIN OPENSSH PRIVATE KEY-----）", text: $secret, axis: .vertical)
                            .font(.system(.caption, design: .monospaced))
                            .lineLimit(6...)
                            .autocorrectionDisabled()
                            #if os(iOS)
                            .textInputAutocapitalization(.never)
                            #endif
                        SecureField("私钥密码（没有就留空）", text: $passphrase)
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle(server.name.isEmpty ? "添加服务器" : server.name)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存", action: save)
                        .disabled(server.host.isEmpty || server.username.isEmpty)
                }
            }
            .task { loadSecrets() }
        }
        #if os(macOS)
        .frame(minWidth: 460, minHeight: 440)
        #endif
    }

    private func loadSecrets() {
        secret = store.secret(for: server)
        passphrase = store.passphrase(for: server) ?? ""
    }

    private func save() {
        withAnimation(Theme.spring) { store.save(server, secret: secret, passphrase: passphrase) }
        dismiss()
    }
}
