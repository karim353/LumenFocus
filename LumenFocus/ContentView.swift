import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            FocusView()
                .tabItem {
                    Image(systemName: "timer")
                    Text("Focus")
                }
            
            TasksView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Tasks")
                }
            
            GardenView()
                .tabItem {
                    Image(systemName: "leaf")
                    Text("Garden")
                }
            
            StatisticsView()
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Statistics")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .accentColor(.accentColor)
    }
}

#Preview {
    ContentView()
}
