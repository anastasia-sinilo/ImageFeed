import Foundation

//MARK: - Network Models

struct UserResult: Codable {
    let profileImage: ProfileImage

    private enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

struct ProfileImage: Codable {
    let small: String
}

final class ProfileImageService {
    
    //MARK: - Singleton
    
    static let shared = ProfileImageService()
    private init() {}
    
    //MARK: - Properties
    
    private(set) var avatarURL: String?
    private var task: URLSessionTask?
    private let storage = OAuth2TokenStorage.shared
    
    //MARK: - Notifications
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
        
    //MARK: - API

    func fetchProfileImageURL(username: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        task?.cancel()

        guard let token = storage.token else {
            completion(.failure(URLError(.userAuthenticationRequired)))
            return
        }

        guard let request = makeProfileImageRequest(username: username, token: token) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self else { return }
            switch result {
            case .success(let userResult):
                let profileImageURL = userResult.profileImage.small
                self.avatarURL = profileImageURL
                completion(.success(profileImageURL))
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": profileImageURL])
            case .failure(let error):
                print("[ProfileImageService.fetchProfileImageURL]: \(error.localizedDescription), username: \(username)")
                completion(.failure(error))
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
    
    //MARK: - Request Builder
    
    private func makeProfileImageRequest(username: String, token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
