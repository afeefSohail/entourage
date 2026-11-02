// PhotoViewModel.swift — presentation wrapper for a single Photo model
import Foundation

struct PhotoViewModel {

    let photo: Photo

    init(_ photo: Photo) {
        self.photo = photo
    }

    var thumbnailURL: URL? { photo.thumb.flatMap { URL(string: $0) } }
    var mediumURL: URL?    { photo.medium.flatMap { URL(string: $0) } }
    var originalURL: URL?  { photo.original.flatMap { URL(string: $0) } }

    var isPrimary: Bool { photo.is_primary ?? false }
    var order: Int      { photo.order ?? 0 }

    var bestAvailableURL: URL? { mediumURL ?? thumbnailURL ?? originalURL }
}
