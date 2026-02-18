import Foundation

final class OAuth2Service {
    
    //MARK: - Singleton
    
    static let shared = OAuth2Service()
    private init() { }
    
    //MARK: - Properties
    
    private var task: URLSessionTask?
    private var lastCode: String?
    
    //MARK: - API
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if let task, lastCode == code {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        if task != nil, lastCode != code {
            task?.cancel()
        }
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("OAuth2Service: Failed to build OAuth token request")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self else { return }
            self.task = nil
            self.lastCode = nil
            switch result {
            case .success(let response):
                let token = response.accessToken
                OAuth2TokenStorage.shared.token = token
                completion(.success(token))
            case .failure(let error):
                print("[OAuth2Service.fetchOAuthToken]: \(error.localizedDescription), code: \(code)")
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
    
    //MARK: - Request Builder
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else {
            return nil
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
        ]
        
        guard let authTokenUrl = urlComponents.url else { return nil }
        
        var request = URLRequest(url: authTokenUrl)
        request.httpMethod = "POST"
        return request
    }
}
