import SwiftUI

struct EventListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var eventViewModel: EventViewModel
    
    var contact: ContactEntity?
    var group: GroupEntity?
    var title: String
    
    init(contact: ContactEntity? = nil, group: GroupEntity? = nil) {
        self.contact = contact
        self.group = group
        
        if let contact = contact {
            self.title = "\(contact.fullName)の予定"
            _eventViewModel = StateObject(wrappedValue: EventViewModel(
                context: PersistenceController.shared.container.viewContext,
                contact: contact
            ))
        } else if let group = group {
            self.title = "\(group.name ?? "")の予定"
            _eventViewModel = StateObject(wrappedValue: EventViewModel(
                context: PersistenceController.shared.container.viewContext,
                group: group
            ))
        } else {
            self.title = "すべての予定"
            _eventViewModel = StateObject(wrappedValue: EventViewModel(
                context: PersistenceController.shared.container.viewContext
            ))
        }
    }
    
    var body: some View {
        List {
            if eventViewModel.events.isEmpty {
                Text("予定はありません")
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(eventViewModel.events) { event in
                    NavigationLink(destination: EventDetailView(event: event)) {
                        EventRowView(event: event)
                    }
                }
                .onDelete(perform: deleteEvents)
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    eventViewModel.fetchEvents()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(AppColors.primary)
                }
            }
        }
        .onAppear {
            eventViewModel.fetchEvents()
        }
    }
    
    private func deleteEvents(at offsets: IndexSet) {
        let eventsToDelete = offsets.map { eventViewModel.events[$0] }
        for event in eventsToDelete {
            eventViewModel.deleteEvent(event)
        }
    }
}

#Preview {
    NavigationView {
        EventListView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
