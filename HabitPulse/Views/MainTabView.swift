import SwiftUI

struct MainTabView: View {
    @StateObject private var store = HabitStore()

    var body: some View {
        TabView {
            NavigationView {
                HomeView()
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("Сегодня", systemImage: "sun.max.fill")
            }

            NavigationView {
                HabitListView()
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("Привычки", systemImage: "list.bullet.rectangle")
            }

            NavigationView {
                InsightsView()
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("Инсайты", systemImage: "chart.bar.fill")
            }

            NavigationView {
                SettingsView()
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("Настройки", systemImage: "gearshape.fill")
            }
        }
        .accentColor(AppTheme.teal)
        .environmentObject(store)
    }
}
