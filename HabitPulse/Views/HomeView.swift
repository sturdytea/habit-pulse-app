import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: HabitStore
    @State private var showAdd = false

    private var today: Date { Date() }
    private var formatter: DateFormatter {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ru_RU")
        f.dateFormat = "EEEE, d MMMM"
        return f
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                todayCard
                quickList
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Главная")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showAdd = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(AppTheme.accentGradient)
                }
                .accessibilityLabel("Добавить привычку")
            }
        }
        .sheet(isPresented: $showAdd) {
            NavigationView {
                AddEditHabitView(mode: .add)
            }
            .navigationViewStyle(.stack)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(formatter.string(from: today).capitalized)
                .font(.subheadline.weight(.medium))
                .foregroundColor(.secondary)
            Text("С возвращением")
                .font(.title2.weight(.bold))
                .foregroundColor(.primary)
                .minimumScaleFactor(0.85)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }

    private var todayCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Прогресс дня", systemImage: "checkmark.seal.fill")
                    .font(.headline)
                    .foregroundStyle(AppTheme.accentGradient)
                Spacer()
                Text("\(store.todayCompletedCount)/\(max(store.habits.count, 1))")
                    .font(.headline.monospacedDigit())
            }
            ProgressView(
                value: Double(store.todayCompletedCount),
                total: Double(max(store.habits.count, 1))
            )
            .tint(AppTheme.teal)
            Text(store.habits.isEmpty ? "Добавьте первую привычку — кнопка «+» справа." : "Отметьте сегодняшние шаги в списке ниже.")
                .font(.footnote)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .habitCardStyle()
    }

    private var quickList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Сегодня")
                .font(.headline)
            if store.habits.isEmpty {
                Text("Пока пусто")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 28)
            } else {
                ForEach(store.habits) { habit in
                    NavigationLink {
                        HabitDetailView(habitId: habit.id)
                    } label: {
                        HabitRow(
                            habit: habit,
                            isDoneToday: habit.isCompleted(on: today),
                            weekProgress: store.weekProgress(for: habit, date: today)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct HabitRow: View {
    let habit: Habit
    let isDoneToday: Bool
    let weekProgress: Double

    var body: some View {
        HStack(spacing: 14) {
            Text(habit.emoji)
                .font(.title2)
                .frame(width: 44, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.tertiarySystemGroupedBackground))
                )
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.body.weight(.semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.9)
                ProgressView(value: weekProgress)
                    .tint(AppTheme.emerald)
                Text(isDoneToday ? "Сегодня выполнено" : "Ещё не отмечено")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer(minLength: 8)
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundColor(.secondary)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(AppTheme.subtleBorder, lineWidth: 1)
        )
    }
}
