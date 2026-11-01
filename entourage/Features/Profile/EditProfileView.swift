// EditProfileView.swift — SwiftUI edit profile screen
import SwiftUI
import PhotosUI

struct EditProfileView: View {

    @Environment(AppCoordinator.self) private var coordinator
    @State private var vm = EditProfileViewModel()
    @State private var photosPickerItem: PhotosPickerItem?
    @State private var showDeleteConfirm = false
    @State private var photoToDelete: Photo?

    var body: some View {
        List {
            Section("Photos") {
                photoGrid
            }

            Section("About") {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Bio").font(.caption).foregroundStyle(.secondary)
                    TextEditor(text: $vm.bio)
                        .frame(minHeight: 80)
                        .overlay(alignment: .topLeading) {
                            if vm.bio.isEmpty {
                                Text("Tell people about yourself…")
                                    .foregroundStyle(.tertiary)
                                    .padding(.top, 8).padding(.leading, 4)
                                    .allowsHitTesting(false)
                            }
                        }
                }
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                if vm.isSaving {
                    ProgressView()
                } else {
                    Button("Save") {
                        Task { await vm.save(); coordinator.pop() }
                    }
                    .fontWeight(.medium)
                }
            }
        }
        .alert("Delete Photo?", isPresented: $showDeleteConfirm, presenting: photoToDelete) { photo in
            Button("Delete", role: .destructive) {
                Task { await vm.deletePhoto(photo) }
            }
            Button("Cancel", role: .cancel) {}
        }
        .alert("Error", isPresented: .constant(vm.errorMessage != nil)) {
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

    @ViewBuilder
    private var photoGrid: some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(Array(vm.photos.enumerated()), id: \.element.id) { idx, photo in
                photoCell(photo: photo, isPrimary: idx == 0)
            }

            if vm.photos.count < 6 {
                PhotosPicker(selection: $photosPickerItem, matching: .images) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.secondarySystemBackground))
                            .aspectRatio(1, contentMode: .fit)
                        if vm.isUploading {
                            ProgressView()
                        } else {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .disabled(vm.isUploading)
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private func photoCell(photo: Photo, isPrimary: Bool) -> some View {
        ZStack(alignment: .topTrailing) {
            if let urlStr = photo.medium, let url = URL(string: urlStr) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let img): img.resizable().scaledToFill()
                    default: Color(.tertiarySystemBackground)
                    }
                }
                .aspectRatio(1, contentMode: .fill)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            Button {
                photoToDelete = photo
                showDeleteConfirm = true
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.white, .black.opacity(0.6))
                    .font(.title3)
            }
            .padding(4)

            if isPrimary {
                Text("Primary")
                    .font(.caption2.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6).padding(.vertical, 2)
                    .background(Color.accentColor)
                    .clipShape(Capsule())
                    .padding(6)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
