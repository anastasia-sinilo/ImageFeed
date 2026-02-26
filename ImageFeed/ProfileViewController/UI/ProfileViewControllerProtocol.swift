import Foundation

protocol ProfileViewControllerProtocol: AnyObject {
    func updateProfile(name: String, login: String, description: String)
    func updateAvatar(with url: URL?)
    func showLogoutAlert()
}
