import Foundation

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    
    private let profileService: ProfileService
    private let profileImageService: ProfileImageService
    private let logoutService: ProfileLogoutService
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    init(
        profileService: ProfileService = .shared,
        profileImageService: ProfileImageService = .shared,
        logoutService: ProfileLogoutService = .shared
    ) {
        self.profileService = profileService
        self.profileImageService = profileImageService
        self.logoutService = logoutService
    }
    
    deinit {
            if let observer = profileImageServiceObserver {
                NotificationCenter.default.removeObserver(observer)
            }
        }
    
    // MARK: - Lifecycle
    
    func viewDidLoad() {
        updateProfile()
        setupProfileImageObserver()
        updateAvatar()
    }
    
    //MARK: - Update profile and avatar
    
    private func updateProfile() {
            guard let profile = profileService.profile else { return }
            
            let name = profile.name.isEmpty ? "Имя не указано" : profile.name
            let login = profile.loginName.isEmpty ? "@неизвестный_пользователь" : profile.loginName
            
            let description: String
            if let bio = profile.bio, !bio.isEmpty {
                description = bio
            } else {
                description = "Профиль не заполнен"
            }
            
            view?.updateProfile(name: name, login: login, description: description)
        }
    
    private func updateAvatar() {
            guard
                let urlString = profileImageService.avatarURL,
                let url = URL(string: urlString)
            else {
                view?.updateAvatar(with: nil)
                return
            }
            view?.updateAvatar(with: url)
        }
    
    //MARK: - Observer
    
    private func setupProfileImageObserver() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAvatar()
        }
    }
    
    // MARK: - Logout
    
    func didTapLogout() {
            view?.showLogoutAlert()
        }
    
    func didConfirmLogout() {
            logoutService.logout()
        }
}
