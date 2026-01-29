import UIKit

final class SplashViewController: UIViewController {
    
    //MARK: - Dependencies
    
    private let storage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    
    //MARK: - Navigation
    
    private let showAuthScreenSegueId = "ShowAuthScreen"
    
    //MARK: - UI Elements
    
    private let splashScreenLogo = UIImageView()
    
    //MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupImageView()
        checkAuthenticationState()
        //ТОЛЬКО ДЛЯ ТЕСТА: очистка токена
        //OAuth2TokenStorage.shared.token = nil
    }
    
    //MARK: - Setup Views
    
    private func setupImageView() {
        let image = UIImage(resource: .vector)
        splashScreenLogo.image = image
        splashScreenLogo.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(splashScreenLogo)
        
        NSLayoutConstraint.activate([
            splashScreenLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            splashScreenLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    //MARK: - Navigation
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarController")
        window.rootViewController = tabBarController
    }
    
    private func presentAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            assertionFailure("Не удалось найти AuthViewController по идентификатору")
            return
        }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }
    
    //MARK: - Auth Flow
    
    private func checkAuthenticationState() {
        if let token = storage.token {
            //
            switchToTabBarController()
            fetchProfile(token: token)
        } else {
            presentAuthViewController()
        }
    }
    
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self else { return }
        
            switch result {
            case let .success(profile):
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) {_ in
                    switch result {
                    case .success(let url):
                        print("[SplashViewController]: ProfileImageService success - URL: \(url)")
                    case .failure(let error):
                        print("[SplashViewController]: ProfileImageService failure - \(error.localizedDescription)")
                    }}
                self.switchToTabBarController()
            case let .failure(error):
                print(print("[SplashViewController]: ProfileService failure - \(error.localizedDescription)"))
                break
            }
        }
    }
}
    
    //MARK: - AuthViewControllerDelegate

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        //
        guard let token = storage.token else { return }
        fetchProfile(token: token)
    }
}
