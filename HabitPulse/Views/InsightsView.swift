import SwiftUI

struct InsightsView: View {
    @EnvironmentObject private var store: HabitStore

    private var today: Date { Date() }

    private var totalCompletions: Int {
        store.habits.reduce(0) { $0 + $1.completedDayKeys.count }
    }

    private var bestHabit: Habit? {
        store.habits.max(by: { $0.completedDayKeys.count < $1.completedDayKeys.count })
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                summaryCard
                weekOverview
                leaderboard
            }
            .padding(16)
            .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Инсайты")
        .navigationBarTitleDisplayMode(.large)
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Общая картина", systemImage: "sparkles")
                .font(.headline)
                .foregroundStyle(AppTheme.accentGradient)
            HStack(spacing: 16) {
                metric(title: "Привычек", value: "\(store.habits.count)")
                metric(title: "Сегодня", value: "\(store.todayCompletedCount)")
                metric(title: "Всего отметок", value: "\(totalCompletions)")
            }
        }
        .habitCardStyle()
    }

    private func metric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundColor(.secondary)
            Text(value)
                .font(.title3.weight(.bold))
                .minimumScaleFactor(0.75)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var weekOverview: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Недельный прогресс")
                .font(.headline)
            if store.habits.isEmpty {
                Text("Добавьте привычки, чтобы увидеть графики.")
                    .foregroundColor(.secondary)
            } else {
                let slice = Array(store.habits.prefix(6))
                ForEach(Array(slice.enumerated()), id: \.element.id) { index, habit in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(habit.emoji)
                            Text(habit.name)
                                .font(.subheadline.weight(.semibold))
                                .lineLimit(1)
                                .minimumScaleFactor(0.85)
                            Spacer()
                            Text("\(habit.completions(inWeekOf: today))/\(habit.targetPerWeek)")
                                .font(.caption.monospacedDigit())
                                .foregroundColor(.secondary)
                        }
                        ProgressView(value: store.weekProgress(for: habit, date: today))
                            .tint(AppTheme.teal)
                    }
                    .padding(.vertical, 6)
                    if index < slice.count - 1 {
                        Divider()
                    }
                }
            }
        }
        .habitCardStyle()
    }

    private var leaderboard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Лидер по отметкам")
                .font(.headline)
            if let h = bestHabit, !store.habits.isEmpty {
                HStack(spacing: 14) {
                    Text(h.emoji)
                        .font(.system(size: 40))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(h.name)
                            .font(.body.weight(.semibold))
                            .lineLimit(2)
                            .minimumScaleFactor(0.9)
                        Text("\(h.completedDayKeys.count) дней с отметкой")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Image(systemName: "trophy.fill")
                        .foregroundStyle(AppTheme.accentGradient)
                        .font(.title2)
                }
            } else {
                Text("Пока нет данных для сравнения.")
                    .foregroundColor(.secondary)
            }
        }
        .habitCardStyle()
    }
}
