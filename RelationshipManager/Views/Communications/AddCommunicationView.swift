
import SwiftUI

struct AddCommunicationView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    
    @StateObject private var viewModel: CommunicationViewModel
    
    @State private var type = AppConstants.CommunicationType.call.rawValue
    @State private var content = ""
    @State private var date = Date()
    
    var contact: ContactEntity
    
    init(contact: ContactEntity) {
        self.contact = contact
        _viewModel = StateObject(wrappedValue: CommunicationViewModel(
            context: PersistenceController.shared.container.viewContext,
            contact: contact
        ))
    }
    
    var body: some View {
        NavigationView {
            Form {
                // コミュニケーションタイプ
                Section(header: Text("コミュニケーションタイプ")) {
                    Picker("タイプ", selection: $type) {
                        ForEach(AppConstants.CommunicationType.allCases) { type in
                            Text(type.displayName).tag(type.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // 日時
                Section(header: Text("日時")) {
                    DatePicker(
                        "日時",
                        selection: $date,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }
                
                // 内容
                Section(header: Text("内容")) {
                    ZStack(alignment: .topLeading) {
                        if content.isEmpty {
                            Text("メモ")
                                .foregroundColor(AppColors.textTertiary)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        
                        TextEditor(text: $content)
                            .frame(minHeight: 100)
                    }
                }
                
                // 連絡先情報
                Section(header: Text("連絡先情報")) {
                    HStack {
                        AvatarView(
                            imageData: contact.profileImageData,
                            initials: "\((contact.firstName ?? "").prefix(1))\((contact.lastName ?? "").prefix(1))",
                            size: 40,
                            backgroundColor: contact.category == AppConstants.Category.business.rawValue ? AppColors.businessCategory : AppColors.privateCategory
                        )
                        
                        VStack(alignment: .leading) {
                            Text("\(contact.firstName) \(contact.lastName)")
                                .font(AppFonts.headline)
                            
                            if let phoneNumber = contact.phoneNumber, !phoneNumber.isEmpty {
                                Text(phoneNumber)
                                    .font(AppFonts.caption1)
                                    .foregroundColor(AppColors.textSecondary)
                            } else if let email = contact.email, !email.isEmpty {
                                Text(email)
                                    .font(AppFonts.caption1)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                        
                        Spacer()
                        
                        Text("\(contact.firstName ?? "") \(contact.lastName ?? "")")
                            .font(AppFonts.headline)
                    }
                }
            }
            .navigationTitle("コミュニケーション追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveCommunication()
                    }
                    .disabled(content.isEmpty)
                }
            }
        }
    }
    
    // コミュニケーションを保存
    private func saveCommunication() {
        viewModel.addCommunication(
            type: type,
            content: content,
            date: date,
            contact: contact
        )
        
        presentationMode.wrappedValue.dismiss()
    }
}

struct AddCommunicationView_Previews: PreviewProvider {
    static var previews: some View {
        let previewContext = PersistenceController.preview.container.viewContext
        let contact = previewContext.registeredObjects.first { $0 is ContactEntity } as! ContactEntity
        
        return AddCommunicationView(contact: contact)
            .environment(\.managedObjectContext, previewContext)
    }
}
