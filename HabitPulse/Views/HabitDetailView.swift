import SwiftUI

struct HabitDetailView: View {
    let habitId: UUID
    @EnvironmentObject private var store: HabitStore
    @Environment(\.presentationMode) private var presentationMode

    @State private var showEdit = false
    @State private var confirmDelete = false

    private var habit: Habit? {
        store.habits.first { $0.id == habitId }
    }

    private var today: Date { Date() }

    var body: some View {
        Group {
            if let habit = habit {
                content(habit: habit)
            } else {
                Text("Привычка не найдена")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        .navigationTitle(habit?.name ?? "Детали")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        showEdit = true
                    } label: {
                        Label("Изменить", systemImage: "pencil")
                    }
                    Button(role: .destructive) {
                        confirmDelete = true
                    } label: {
                        Label("Удалить", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showEdit) {
            if let h = habit {
                NavigationView {
                    AddEditHabitView(mode: .edit(h))
                }
                .navigationViewStyle(.stack)
            }
        }
        .alert("Удалить привычку?", isPresented: $confirmDelete) {
            Button("Отмена", role: .cancel) {}
            Button("Удалить", role: .destructive) {
                store.delete(id: habitId)
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Данные и история отметок для этой привычки будут удалены.")
        }
    }

    @ViewBuilder
    private func content(habit: Habit) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                hero(habit: habit)
                weekStrip(habit: habit)
                notesSection(habit: habit)
                stats(habit: habit)
            }
            .padding(16)
            .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }

    private func hero(habit: Habit) -> some View {
        VStack(spacing: 16) {
            Text(habit.emoji)
                .font(.system(size: 56))
            Button {
                store.toggle(habitID: habit.id, on: today)
            } label: {
                HStack {
                    Image(systemName: habit.isCompleted(on: today) ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                    Text(habit.isCompleted(on: today) ? "Выполнено сегодня" : "Отметить сегодня")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppTheme.teal.opacity(habit.isCompleted(on: today) ? 0.35 : 0.18))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(AppTheme.teal.opacity(0.4), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .habitCardStyle()
    }

    private func weekStrip(habit: Habit) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Эта неделя")
                .font(.headline)
            let days = weekDays()
            HStack(spacing: 0) {
                ForEach(days, id: \.self) { day in
                    VStack(spacing: 6) {
                        Text(shortWeekday(day))
                            .font(.caption2.weight(.semibold))
                            .foregroundColor(.secondary)
                        Circle()
                            .fill(habit.isCompleted(on: day) ? AppTheme.teal : Color(.tertiarySystemFill))
                            .frame(width: 12, height: 12)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 4)
            Text("Неделя: \(habit.completions(inWeekOf: today)) / \(habit.targetPerWeek)")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.secondary)
        }
        .habitCardStyle()
    }

    private func notesSection(habit: Habit) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Заметка")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(habit.notes.isEmpty ? "Нет заметки — добавьте в режиме редактирования." : habit.notes)
                .font(.body)
                .foregroundColor(habit.notes.isEmpty ? .secondary : .primary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .habitCardStyle()
    }

    private func stats(habit: Habit) -> some View {
        HStack(spacing: 12) {
            statTile(title: "Серия", value: "\(habit.streak(asOf: today))", icon: "flame.fill")
            statTile(title: "Всего дней", value: "\(habit.completedDayKeys.count)", icon: "calendar")
        }
    }

    private func statTile(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.caption.weight(.semibold))
                .foregroundColor(.secondary)
            Text(value)
                .font(.title2.weight(.bold))
                .minimumScaleFactor(0.8)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .habitCardStyle()
    }

    private func weekDays() -> [Date] {
        let cal = Calendar.current
        guard let interval = cal.dateInterval(of: .weekOfYear, for: today) else { return [] }
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: interval.start) }
    }

    private func shortWeekday(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ru_RU")
        f.dateFormat = "EEEEE"
        return f.string(from: date).uppercased()
    }
}
