import XCTest
@testable import ImageFeed

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {

    var updateProfileCalled = false
    var updateAvatarCalled = false
    var showLogoutAlertCalled = false

    var receivedName: String?
    var receivedLogin: String?
    var receivedDescription: String?
    
    func updateProfile(name: String, login: String, description: String) {
        updateProfileCalled = true
        receivedName = name
        receivedLogin = login
        receivedDescription = description
    }

    func updateAvatar(with url: URL?) {
        updateAvatarCalled = true
    }

    func showLogoutAlert() {
        showLogoutAlertCalled = true
    }
}
