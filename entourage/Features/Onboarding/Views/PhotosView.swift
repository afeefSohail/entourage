import SwiftUI
import PhotosUI

struct PhotosView: View {
    @Environment(OnboardingCoordinator.self) private var coordinator

    @State private var photos: [UIImage?] = Array(repeating: nil, count: 6)
    @State private var selectedIndex = 0
    @State private var pickerItem: PhotosPickerItem?
    @State private var showPicker = false
    @State private var isLoading = false
    @State private var isUploading = false
    @State private var errorMessage: String?

    private var uploadedCount: Int { photos.filter { $0 != nil }.count }
    private var canContinue: Bool { uploadedCount > 0 }

    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Add your\nbest photos")
                .font(.system(size: 28, weight: .bold))
                .padding(.top, 32)
                .padding(.horizontal, 24)
                .padding(.bottom, 8)

            Text("Add at least 1 photo to continue.")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(0..<6, id: \.self) { i in
                    photoCell(index: i)
                }
            }
            .padding(.horizontal, 24)

            if let error = errorMessage {
                Text(error)
                    .font(.system(size: 13))
                    .foregroundStyle(.red)
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
            }

            Spacer()

            Button {
                Task { await saveContinue() }
            } label: {
                ZStack {
                    Text("Continue")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .opacity(isLoading ? 0 : 1)
                    if isLoading { ProgressView().tint(.white) }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(canContinue ? Color("themeColor") : Color(.systemGray4))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!canContinue || isLoading)
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Add Profile Picture")
        .photosPicker(isPresented: $showPicker, selection: $pickerItem, matching: .images)
        .onChange(of: pickerItem) { _, new in
            guard let new else { return }
            Task { await loadImage(item: new, at: selectedIndex) }
        }
        .onAppear { loadExistingPhotos() }
    }

    @ViewBuilder
    private func photoCell(index: Int) -> some View {
        Button {
            selectedIndex = index
            showPicker = true
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray5))
                    .aspectRatio(1, contentMode: .fit)

                if let img = photos[index] {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Remove button
                    VStack {
                        HStack {
                            Spacer()
                            Button {
                                removePhoto(at: index)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(.white)
                                    .shadow(radius: 2)
                            }
                            .padding(6)
                        }
                        Spacer()
                    }
                } else {
                    Image(systemName: "plus")
                        .font(.system(size: 24))
                        .foregroundStyle(Color(.systemGray3))
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func loadExistingPhotos() {
        let existing = EntourageManager.shared.photos
        for (i, photo) in existing.prefix(6).enumerated() {
            guard let urlStr = photo.medium, let url = URL(string: urlStr) else { continue }
            Task {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let img = UIImage(data: data) {
                    await MainActor.run { photos[i] = img }
                }
            }
        }
    }

    private func loadImage(item: PhotosPickerItem, at index: Int) async {
        guard let data = try? await item.loadTransferable(type: Data.self),
              let img = UIImage(data: data) else { return }

        photos[index] = img
        pickerItem = nil

        await uploadPhoto(img, at: index)
    }

    private func uploadPhoto(_ image: UIImage, at index: Int) async {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        await withCheckedContinuation { cont in
            WebServicesManager.shared.uploadPhoto(image: data, isPrimary: index == 0, order: index) { _, _ in
                cont.resume()
            }
        }
    }

    private func removePhoto(at index: Int) {
        photos[index] = nil
    }

    private func saveContinue() async {
        isLoading = true
        defer { isLoading = false }
        coordinator.push(.username)
    }
}
