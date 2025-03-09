import SwiftUI

struct TabBarView: View {
    @State private var selectedTab = 0
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Label("ホーム", systemImage: "house")
                }
                .tag(0)
            
            ContactsListView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Label("連絡先", systemImage: "person.crop.circle")
                }
                .tag(1)
            
            CalendarView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Label("カレンダー", systemImage: "calendar")
                }
                .tag(2)
            
            GroupsView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Label("グループ", systemImage: "person.3")
                }
                .tag(3)
        }
        .accentColor(AppColors.primary)
    }
}

#Preview {
    TabBarView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
