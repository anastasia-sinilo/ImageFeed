import Foundation

final class ImagesListService {
    
    //MARK: - Singleton
    static let shared = ImagesListService()
    private init() {}
    
    //MARK: - Notifications
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    //MARK: - Properties
    
    private(set) var photos: [Photo] = []
    
    private var currentPage = 1
    private var isFetching = false
    private var task: URLSessionTask?
    
    private var isChangingLike = false
    
    //MARK: - API and Request Builders
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        
        guard !isFetching else { return }
        
        guard let request = makePhotosRequest(page: currentPage) else { return }
        isFetching = true
        
        task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            self.task = nil
            self.isFetching = false
            
            switch result {
            case .success(let photoResults):
                let newPhotos = photoResults.map { Photo(from: $0) }
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    self.currentPage += 1
                    
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                }
            case .failure(let error):
                print("[ImagesListService.fetchPhotosNextPage]: \(error)")
            }
        }
        task?.resume()
    }
    
    private func makePhotosRequest(page: Int) -> URLRequest? {
        guard let baseURL = URL(string: AuthConfiguration.standard.defaultBaseURLString) else { return nil }
        
        var urlComponents = URLComponents(url: baseURL.appendingPathComponent("photos"), resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "10")
        ]
        
        guard let url = urlComponents?.url else { return nil }
        
        guard let token = OAuth2TokenStorage.shared.token else {
            print("[ImagesListService.makePhotosRequest]: no token")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

extension ImagesListService {
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard !isChangingLike else { return }
            isChangingLike = true
        
        guard let request = makeLikeRequest(photoId: photoId, isLike: isLike) else {
            isChangingLike = false
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<LikePhotoResult, Error>) in
            guard let self else { return }
            
            DispatchQueue.main.async {
                self.isChangingLike = false
                
                switch result {
                case .success:
                    if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                        let photo = self.photos[index]
                        
                        let newPhoto = Photo(
                            id: photo.id,
                            size: photo.size,
                            createdAt: photo.createdAt,
                            welcomeDescription: photo.welcomeDescription,
                            thumbImageURL: photo.thumbImageURL,
                            largeImageURL: photo.largeImageURL,
                            smallImageURL: photo.smallImageURL,
                            
                            isLiked: !photo.isLiked
                        )
                        self.photos[index] = newPhoto
                        
                        NotificationCenter.default.post(
                            name: ImagesListService.didChangeNotification,
                            object: self
                        )
                    }
                    completion(.success(()))
                    
                case .failure(let error):
                        completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    private func makeLikeRequest(photoId: String, isLike: Bool) -> URLRequest? {
        guard let baseURL = URL(string: AuthConfiguration.standard.defaultBaseURLString) else { return nil }
        
        let url = baseURL
            .appendingPathComponent("photos")
            .appendingPathComponent(photoId)
            .appendingPathComponent("like")
        
        guard let token = OAuth2TokenStorage.shared.token else {
            print("[ImagesListService.makeLikeRequest]: no token")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }

    func clean() {
        photos = []
        currentPage = 1
        task?.cancel()
        task = nil
        isFetching = false
    }
}

private struct LikePhotoResult: Decodable {
    let photo: PhotoResult
}
