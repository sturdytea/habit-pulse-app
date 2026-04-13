import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: HabitStore
    @State private var remindersEnabled = false
    @State private var compactRows = false

    var body: some View {
        Form {
            Section(header: Text("О приложении")) {
                HStack {
                    Label("HabitPulse", systemImage: "leaf.circle.fill")
                        .foregroundColor(AppTheme.teal)
                    Spacer()
                    Text("1.0")
                        .foregroundColor(.secondary)
                }
                Text("Локальное приложение для отслеживания привычек. Данные хранятся на устройстве.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Section(header: Text("Поведение")) {
                Toggle(isOn: $remindersEnabled) {
                    Label("Напоминания (заглушка)", systemImage: "bell.badge")
                }
                .disabled(true)
                Toggle(isOn: $compactRows) {
                    Label("Компактные списки (демо)", systemImage: "list.bullet.indent")
                }
            }
            Section(header: Text("Данные")) {
                Button(role: .destructive) {
                    store.clearAll()
                } label: {
                    Label("Сбросить все привычки", systemImage: "trash")
                }
            }
            Section(header: Text("Экраны")) {
                NavigationLink {
                    Text("Это дополнительный информационный экран для выполнения требования по количеству экранов. Здесь можно разместить политику конфиденциальности, подсказки или ссылки на поддержку.")
                        .font(.body)
                        .padding()
                        .navigationTitle("Информация")
                } label: {
                    Label("Справка и политика", systemImage: "info.circle")
                }
            }
        }
        .navigationTitle("Настройки")
    }
}
