
// ContactRowView.swift
import SwiftUI

struct ContactRowView: View {
    var contact: ContactEntity
    var isSelected: Bool = false
    var isMultiSelectionMode: Bool = false
    
    var body: some View {
        HStack(spacing: 15) {
            if isMultiSelectionMode {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? AppColors.primary : AppColors.textTertiary)
                    .font(.system(size: 22))
            }
            
            AvatarView(
                imageData: contact.profileImageData,
                initials: "\(contact.firstName.prefix(1))\(contact.lastName.prefix(1))",
                size: 50,
                backgroundColor: contact.category == AppConstants.Category.business.rawValue ? AppColors.businessCategory : AppColors.privateCategory
            )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(contact.firstName) \(contact.lastName)")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
                
                if let phoneNumber = contact.phoneNumber, !phoneNumber.isEmpty {
                    Text(phoneNumber)
                        .font(AppFonts.bodySmall)
                        .foregroundColor(AppColors.textSecondary)
                } else if let email = contact.email, !email.isEmpty {
                    Text(email)
                        .font(AppFonts.bodySmall)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            
            Spacer()
            
            CategoryBadgeView(category: contact.category)
        }
        .padding(.vertical, 8)
    }
}

// CategoryFilterView.swift
import SwiftUI

struct CategoryFilterView: View {
    @Binding var selectedCategory: AppConstants.Category?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                CategoryFilterButton(
                    title: "すべて",
                    isSelected: selectedCategory == nil,
                    color: AppColors.primary
                ) {
                    selectedCategory = nil
                }
                
                ForEach(AppConstants.Category.allCases) { category in
                    CategoryFilterButton(
                        title: category.displayName,
                        isSelected: selectedCategory == category,
                        color: category == .business ? AppColors.businessCategory : AppColors.privateCategory
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct CategoryFilterButton: View {
    var title: String
    var isSelected: Bool
    var color: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFonts.subheadline)
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(isSelected ? color : Color.gray.opacity(0.1))
                .foregroundColor(isSelected ? .white : AppColors.textPrimary)
                .cornerRadius(20)
        }
    }
}

// AddContactView.swift
import SwiftUI
import UIKit

struct AddContactView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    
    @StateObject private var viewModel = ContactViewModel(context: PersistenceController.shared.container.viewContext)
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var phoneNumber = ""
    @State private var email = ""
    @State private var birthday: Date?
    @State private var notes = ""
    @State private var category = AppConstants.Category.private.rawValue
    @State private var profileImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingBirthdayPicker = false
    
    var body: some View {
        NavigationView {
            Form {
                // プロフィール画像セクション
                Section {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            showingImagePicker = true
                        }) {
                            if let profileImage = profileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 2)
                                    )
                                    .shadow(radius: 2)
                            } else {
                                ZStack {
                                    Circle()
                                        .fill(category == AppConstants.Category.business.rawValue ? AppColors.businessCategory : AppColors.privateCategory)
                                        .frame(width: 100, height: 100)
                                        .shadow(radius: 2)
                                    
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 10)
                }
                .listRowBackground(Color.clear)
                
                // 基本情報セクション
                Section(header: Text("基本情報")) {
                    TextField("姓", text: $lastName)
                    TextField("名", text: $firstName)
                    
                    Picker("カテゴリ", selection: $category) {
                        Text(AppConstants.Category.business.displayName)
                            .tag(AppConstants.Category.business.rawValue)
                        
                        Text(AppConstants.Category.private.displayName)
                            .tag(AppConstants.Category.private.rawValue)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // 連絡先情報セクション
                Section(header: Text("連絡先情報")) {
                    TextField("電話番号", text: $phoneNumber)
                        .keyboardType(.phonePad)
                    
                    TextField("メールアドレス", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                // 追加情報セクション
                Section(header: Text("追加情報")) {
                    HStack {
                        Text("誕生日")
                        Spacer()
                        
                        Button(action: {
                            showingBirthdayPicker.toggle()
                        }) {
                            Text(birthday != nil ? birthday!.formatted() : "設定なし")
                                .foregroundColor(birthday != nil ? AppColors.textPrimary : AppColors.textTertiary)
                        }
                    }
                    
                    if showingBirthdayPicker {
                        DatePicker(
                            "誕生日を選択",
                            selection: Binding(
                                get: { birthday ?? Date() },
                                set: { birthday = $0 }
                            ),
                            displayedComponents: .date
                        )
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .labelsHidden()
                    }
                    
                    ZStack(alignment: .topLeading) {
                        if notes.isEmpty {
                            Text("メモ")
                                .foregroundColor(AppColors.textTertiary)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        
                        TextEditor(text: $notes)
                            .frame(minHeight: 100)
                    }
                }
            }
            .navigationTitle("新規連絡先")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveContact()
                    }
                    .disabled(firstName.isEmpty || lastName.isEmpty)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $profileImage)
            }
        }
    }
    
    // 連絡先を保存
    private func saveContact() {
        viewModel.addContact(
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phoneNumber.isEmpty ? nil : phoneNumber,
            email: email.isEmpty ? nil : email,
            birthday: birthday,
            notes: notes.isEmpty ? nil : notes,
            category: category,
            profileImage: profileImage
        )
        
        presentationMode.wrappedValue.dismiss()
    }
}
