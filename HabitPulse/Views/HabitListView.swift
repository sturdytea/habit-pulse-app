import SwiftUI

struct HabitListView: View {
    @EnvironmentObject private var store: HabitStore
    @State private var showAdd = false

    var body: some View {
        List {
            if store.habits.isEmpty {
                Text("Нажмите «+», чтобы создать привычку.")
                    .foregroundColor(.secondary)
                    .listRowBackground(Color.clear)
            } else {
                ForEach(store.habits) { habit in
                    NavigationLink {
                        HabitDetailView(habitId: habit.id)
                    } label: {
                        HStack(spacing: 12) {
                            Text(habit.emoji)
                                .font(.title2)
                                .frame(width: 40, alignment: .center)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(habit.name)
                                    .font(.body.weight(.semibold))
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.85)
                                Text("Цель: \(habit.targetPerWeek)× в неделю")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete(perform: store.delete)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Привычки")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showAdd = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(AppTheme.teal)
                }
            }
        }
        .sheet(isPresented: $showAdd) {
            NavigationView {
                AddEditHabitView(mode: .add)
            }
            .navigationViewStyle(.stack)
        }
    }
}
