import SwiftUI

enum HabitEditorMode {
    case add
    case edit(Habit)
}

struct AddEditHabitView: View {
    let mode: HabitEditorMode

    @EnvironmentObject private var store: HabitStore
    @Environment(\.presentationMode) private var presentationMode

    @State private var name: String = ""
    @State private var emoji: String = "✨"
    @State private var notes: String = ""
    @State private var targetPerWeek: Double = 5

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private let emojiOptions = ["✨", "🏃", "💧", "📚", "🧘", "🍎", "😴", "🎯", "📝", "🎸"]

    var body: some View {
        Form {
            Section(header: Text("Название")) {
                TextField("Например: Утренняя прогулка", text: $name)
            }
            Section(header: Text("Эмодзи")) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(emojiOptions, id: \.self) { e in
                            Button {
                                emoji = e
                            } label: {
                                Text(e)
                                    .font(.title)
                                    .padding(10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(emoji == e ? AppTheme.teal.opacity(0.2) : Color(.tertiarySystemGroupedBackground))
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            Section(header: Text("Цель на неделю"), footer: Text("Сколько дней в неделю вы хотите выполнять привычку.")) {
                Stepper(value: $targetPerWeek, in: 1...7, step: 1) {
                    Text("\(Int(targetPerWeek)) дн.")
                }
            }
            Section(header: Text("Заметка")) {
                TextEditor(text: $notes)
                    .frame(minHeight: 100)
            }
        }
        .navigationTitle(isEditing ? "Редактирование" : "Новая привычка")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Закрыть") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Сохранить") {
                    save()
                }
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .onAppear {
            if case .edit(let h) = mode {
                name = h.name
                emoji = h.emoji
                notes = h.notes
                targetPerWeek = Double(h.targetPerWeek)
            }
        }
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let t = Int(targetPerWeek)
        switch mode {
        case .add:
            let h = Habit(name: trimmed, emoji: emoji, notes: notes, targetPerWeek: t)
            store.add(h)
        case .edit(let original):
            var h = original
            h.name = trimmed
            h.emoji = emoji
            h.notes = notes
            h.targetPerWeek = t
            store.update(h)
        }
        presentationMode.wrappedValue.dismiss()
    }
}
