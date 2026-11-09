// FiltersView.swift — gender filter screen for discovery
import SwiftUI

struct FiltersView: View {

    @Environment(AppCoordinator.self) private var coordinator
    @State private var everyone: Bool
    @State private var maleOnly: Bool
    @State private var femaleOnly: Bool
    @State private var isSaving = false

    init() {
        let s = EntourageManager.shared.setting ?? Setting()
        _everyone  = State(initialValue: s.everyone   ?? false)
        _maleOnly  = State(initialValue: s.male_only  ?? false)
        _femaleOnly = State(initialValue: s.female_only ?? false)
    }

    var body: some View {
        List {
            Section("Show Me") {
                filterRow(title: "Everyone", selected: everyone) {
                    everyone = true; maleOnly = false; femaleOnly = false
                }
                filterRow(title: "Males", selected: maleOnly) {
                    everyone = false; maleOnly = true; femaleOnly = false
                }
                filterRow(title: "Females", selected: femaleOnly) {
                    everyone = false; maleOnly = false; femaleOnly = true
                }
            }
        }
        .navigationTitle("Filters")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                if isSaving {
                    ProgressView()
                } else {
                    Button("Done") {
                        Task { await save() }
                    }
                    .fontWeight(.medium)
                }
            }
        }
    }

    private func filterRow(title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundStyle(.primary)
                Spacer()
                if selected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color("themeColor"))
                }
            }
        }
    }

    private func save() async {
        guard var setting = EntourageManager.shared.setting else {
            coordinator.pop(); return
        }
        setting.everyone    = everyone
        setting.male_only   = maleOnly
        setting.female_only = femaleOnly
        EntourageManager.shared.setting = setting
        isSaving = true
        _ = try? await UserRepository.shared.updateSettings()
        isSaving = false
        coordinator.pop()
    }
}
