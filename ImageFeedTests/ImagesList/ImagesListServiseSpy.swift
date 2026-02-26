@testable import ImageFeed
import Foundation

final class ImagesListServiceSpy: ImagesListServiceProtocol {
    
    var fetchNextPageCalled = false
    var changeLikeCalled = false
    
    var stubPhotos: [Photo] = []
    
    var photos: [Photo] {
        stubPhotos
    }
    
    func fetchPhotosNextPage() {
        fetchNextPageCalled = true
    }
    
    func changeLike(
        photoId: String,
        isLike: Bool,
        _ completion: @escaping (Result<Void, Error>) -> Void
    ) {
        changeLikeCalled = true
        completion(.success(()))
    }
}
