import Foundation
import SwiftUI

final class HabitStore: ObservableObject {
    @Published private(set) var habits: [Habit] = []

    private let storageKey = "habitpulse.habits.v1"
    private let defaults = UserDefaults.standard

    init() {
        if defaults.data(forKey: storageKey) == nil {
            habits = []
            seedIfNeeded()
        } else {
            load()
        }
    }

    func clearAll() {
        habits = []
        persist()
    }

    func load() {
        guard let data = defaults.data(forKey: storageKey) else {
            habits = []
            return
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let decoded = try? decoder.decode([Habit].self, from: data) {
            habits = decoded
        }
    }

    private func persist() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(habits) {
            defaults.set(data, forKey: storageKey)
        }
    }

    func add(_ habit: Habit) {
        habits.insert(habit, at: 0)
        persist()
    }

    func update(_ habit: Habit) {
        guard let i = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        habits[i] = habit
        persist()
    }

    func delete(at offsets: IndexSet) {
        habits.remove(atOffsets: offsets)
        persist()
    }

    func delete(id: UUID) {
        habits.removeAll { $0.id == id }
        persist()
    }

    func toggle(habitID: UUID, on date: Date = Date()) {
        guard let i = habits.firstIndex(where: { $0.id == habitID }) else { return }
        habits[i].toggleCompletion(on: date)
        persist()
    }

    private func seedIfNeeded() {
        let samples = [
            Habit(name: "Утренняя зарядка", emoji: "🏃", notes: "10–15 минут лёгкой активности", targetPerWeek: 5),
            Habit(name: "Стакан воды", emoji: "💧", notes: "Сразу после пробуждения", targetPerWeek: 7),
            Habit(name: "Чтение", emoji: "📚", notes: "20 страниц или 15 минут", targetPerWeek: 4)
        ]
        habits = samples
        persist()
    }

    var todayCompletedCount: Int {
        let today = Date()
        return habits.filter { $0.isCompleted(on: today) }.count
    }

    func weekProgress(for habit: Habit, date: Date = Date()) -> Double {
        guard habit.targetPerWeek > 0 else { return 0 }
        return min(1, Double(habit.completions(inWeekOf: date)) / Double(habit.targetPerWeek))
    }
}
