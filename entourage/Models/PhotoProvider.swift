import Foundation

enum PhotoSize {
    case thumbnail
    case medium
    case original
}

protocol PhotoProvider {
    var photos: [Photo] { get }
}

extension PhotoProvider {

    var primaryPhoto: Photo? {
        photos.first(where: { $0.is_primary == true }) ?? photos.first
    }

    func photoURL(size: PhotoSize) -> String {
        guard let photo = primaryPhoto else { return "" }
        switch size {
        case .thumbnail: return photo.thumb ?? ""
        case .medium:    return photo.medium ?? ""
        case .original:  return photo.original ?? ""
        }
    }

    var thumbnailURL: String   { photoURL(size: .thumbnail) }
    var mediumPhotoURL: String { photoURL(size: .medium) }
    var originalPhotoURL: String { photoURL(size: .original) }
    var hasPhotos: Bool        { !photos.isEmpty }
}

extension User: PhotoProvider {}
