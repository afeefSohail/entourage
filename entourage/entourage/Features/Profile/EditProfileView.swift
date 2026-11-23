// EditProfileView.swift — SwiftUI edit profile screen
import SwiftUI
import PhotosUI

struct EditProfileView: View {

    @Environment(AppCoordinator.self) private var coordinator
    @State private var vm = EditProfileViewModel()
    @State private var photosPickerItem: PhotosPickerItem?
    @State private var showDeleteConfirm = false
    @State private var photoToDelete: Photo?
    @FocusState private var focusedField: Field?

    private enum Field { case name, username, bio }
    private let maxPhotos = 6

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                section("Photos", footer: "Your first photo is your primary photo. Up to \(maxPhotos) photos.") {
                    photoGrid
                }

                section("Basic Info") {
                    VStack(spacing: 0) {
                        fieldRow(label: "First Name") {
                            TextField("Your first name", text: $vm.firstName)
                                .textContentType(.givenName)
                                .focused($focusedField, equals: .name)
                                .submitLabel(.next)
                                .onSubmit { focusedField = .username }
                        }
                        Divider().padding(.leading, 16)
                        fieldRow(label: "Username") {
                            HStack(spacing: 2) {
                                Text("@").foregroundStyle(.secondary)
                                TextField("username", text: $vm.userName)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .focused($focusedField, equals: .username)
                                    .submitLabel(.next)
                                    .onSubmit { focusedField = .bio }
                                usernameStatusIcon
                            }
                        }
                    }
                    .background(cardBackground)
                    usernameMessage
                }

                section("About") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Bio").font(.caption).foregroundStyle(.secondary)
                        TextEditor(text: $vm.bio)
                            .focused($focusedField, equals: .bio)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 140)
                            .overlay(alignment: .topLeading) {
                                if vm.bio.isEmpty {
                                    Text("Tell people about yourself…")
                                        .foregroundStyle(.tertiary)
                                        .padding(.top, 8).padding(.leading, 5)
                                        .allowsHitTesting(false)
                                }
                            }
                            .onChange(of: vm.bio) { _, new in
                                if new.count > EditProfileViewModel.bioLimit {
                                    vm.bio = String(new.prefix(EditProfileViewModel.bioLimit))
                                }
                            }
                        Text("\(vm.bio.count)/\(EditProfileViewModel.bioLimit)")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .padding(16)
                    .background(cardBackground)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            // Keeps the bio clear of the floating tab bar.
            .padding(.bottom, 110)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                if vm.isSaving {
                    ProgressView()
                } else {
                    Button("Save") {
                        focusedField = nil
                        Task { if await vm.save() { coordinator.pop() } }
                    }
                    .fontWeight(.semibold)
                    .disabled(!vm.canSave)
                }
            }
        }
        .alert("Delete Photo?", isPresented: $showDeleteConfirm, presenting: photoToDelete) { photo in
            Button("Delete", role: .destructive) {
                Task { await vm.deletePhoto(photo) }
            }
            Button("Cancel", role: .cancel) {}
        }
        .alert("Couldn't Save", isPresented: Binding(
            get: { vm.errorMessage != nil },
            set: { if !$0 { vm.errorMessage = nil } }
        )) {
            Button("OK") { vm.errorMessage = nil }
        } message: {
            Text(vm.errorMessage ?? "")
        }
        .onChange(of: photosPickerItem) { _, item in
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    await vm.uploadPhoto(data)
                }
                photosPickerItem = nil
            }
        }
    }

    // MARK: - Layout helpers

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemGroupedBackground))
    }

    @ViewBuilder
    private func section<Content: View>(_ title: String, footer: String? = nil, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.leading, 4)
            content()
            if let footer {
                Text(footer).font(.caption).foregroundStyle(.secondary).padding(.horizontal, 4)
            }
        }
    }

    @ViewBuilder
    private func fieldRow<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 12) {
            Text(label)
                .foregroundStyle(.secondary)
                .frame(width: 96, alignment: .leading)
            content()
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 50)
    }

    // MARK: - Username status

    @ViewBuilder
    private var usernameStatusIcon: some View {
        switch vm.usernameStatus {
        case .checking: ProgressView().scaleEffect(0.8)
        case .available: Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
        case .taken, .tooShort: Image(systemName: "xmark.circle.fill").foregroundStyle(.red)
        case .unchanged: EmptyView()
        }
    }

    @ViewBuilder
    private var usernameMessage: some View {
        let message: (String, Color)? = switch vm.usernameStatus {
        case .tooShort: ("Use at least 3 characters.", .red)
        case .taken: ("That username is taken.", .red)
        case .available: ("Username is available.", .green)
        case .checking, .unchanged: nil
        }
        if let message {
            Text(message.0).font(.caption).foregroundStyle(message.1).padding(.horizontal, 4)
        } else if vm.trimmedName.count < 2 {
            Text("First name needs at least 2 characters.").font(.caption).foregroundStyle(.red).padding(.horizontal, 4)
        }
    }

    // MARK: - Photos

    @ViewBuilder
    private var photoGrid: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(Array(vm.photos.enumerated()), id: \.element.id) { idx, photo in
                photoCell(photo: photo, isPrimary: idx == 0)
            }

            if vm.photos.count < maxPhotos {
                PhotosPicker(selection: $photosPickerItem, matching: .images) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.tertiarySystemFill))
                        .aspectRatio(3.0 / 4.0, contentMode: .fit)
                        .overlay {
                            if vm.isUploading {
                                ProgressView()
                            } else {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(Color("themeColor"))
                            }
                        }
                }
                .disabled(vm.isUploading)
            }
        }
        .padding(12)
        .background(cardBackground)
    }

    // The tile owns its size; the photo is an overlay, so a scaledToFill image can never widen the cell.
    @ViewBuilder
    private func photoCell(photo: Photo, isPrimary: Bool) -> some View {
        Color(.tertiarySystemFill)
            .aspectRatio(3.0 / 4.0, contentMode: .fit)
            .overlay {
                if let urlStr = photo.medium, let url = URL(string: urlStr) {
                    AsyncImage(url: url) { phase in
                        if case .success(let img) = phase { img.resizable().scaledToFill() }
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(alignment: .bottomLeading) {
                if isPrimary {
                    Text("Primary")
                        .font(.caption2.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 7).padding(.vertical, 3)
                        .background(Color("themeColor"), in: Capsule())
                        .padding(6)
                }
            }
            .overlay(alignment: .topTrailing) {
                Button {
                    photoToDelete = photo
                    showDeleteConfirm = true
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.white, .black.opacity(0.55))
                }
                .padding(5)
            }
    }
}
