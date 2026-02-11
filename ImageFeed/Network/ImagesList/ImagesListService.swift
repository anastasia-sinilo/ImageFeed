import Foundation


final class ImagesListService {
    static let shared = ImagesListService()
    private init() {}
    
    private(set) var photos: [Photo] = []
    
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    // ...
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        
        if task != nil {
            return
        }
        
        let nextPage = (lastLoadedPage/*?.number*/ ?? 0) + 1
        guard let request = makePhotosRequest(page: nextPage) else {
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            self.task = nil
            
            switch result {
            case .success(let photoResults):
                let newPhotos = photoResults.map { Photo(from: $0) }
                
                self.photos.append(contentsOf: newPhotos)
                self.lastLoadedPage = nextPage
                
                NotificationCenter.default.post(
                    name: ImagesListService.didChangeNotification,
                    object: self
                )
                
            case .failure(let error):
                print("[ImagesListService.fetchPhotosNextPage]: \(error)")
            }
        }
        
        self.task = task
        task.resume()
        
    }
    private func makePhotosRequest(page: Int) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "\(Constants.defaultBaseURL)/photos") else {
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "10")
        ]
        
        guard let url = urlComponents.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        guard let token = OAuth2TokenStorage.shared.token else {
            print("[ImagesListService.makePhotosRequest]: no token")
            return nil
        }
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

