import Foundation

struct Habit: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var emoji: String
    var notes: String
    /// Target completions per week (1...7)
    var targetPerWeek: Int
    var createdAt: Date
    /// Stored as yyyy-MM-dd strings for stable Codable
    var completedDayKeys: Set<String>

    init(
        id: UUID = UUID(),
        name: String,
        emoji: String = "✨",
        notes: String = "",
        targetPerWeek: Int = 5,
        createdAt: Date = Date(),
        completedDayKeys: Set<String> = []
    ) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.notes = notes
        self.targetPerWeek = max(1, min(7, targetPerWeek))
        self.createdAt = createdAt
        self.completedDayKeys = completedDayKeys
    }

    static func dayKey(for date: Date, calendar: Calendar = .current) -> String {
        let c = calendar
        let y = c.component(.year, from: date)
        let m = c.component(.month, from: date)
        let d = c.component(.day, from: date)
        return String(format: "%04d-%02d-%02d", y, m, d)
    }

    func isCompleted(on date: Date, calendar: Calendar = .current) -> Bool {
        completedDayKeys.contains(Self.dayKey(for: date, calendar: calendar))
    }

    mutating func toggleCompletion(on date: Date, calendar: Calendar = .current) {
        let key = Self.dayKey(for: date, calendar: calendar)
        if completedDayKeys.contains(key) {
            completedDayKeys.remove(key)
        } else {
            completedDayKeys.insert(key)
        }
    }

    func completions(inWeekOf date: Date, calendar: Calendar = .current) -> Int {
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: date) else { return 0 }
        var count = 0
        var d = interval.start
        while d < interval.end {
            if isCompleted(on: d, calendar: calendar) { count += 1 }
            d = calendar.date(byAdding: .day, value: 1, to: d) ?? interval.end
        }
        return count
    }

    func streak(asOf date: Date, calendar: Calendar = .current) -> Int {
        var streak = 0
        var d = calendar.startOfDay(for: date)
        while isCompleted(on: d, calendar: calendar) {
            streak += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: d) else { break }
            d = prev
        }
        return streak
    }
}
