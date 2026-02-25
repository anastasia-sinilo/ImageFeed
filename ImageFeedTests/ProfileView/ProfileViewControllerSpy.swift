import XCTest
@testable import ImageFeed

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {

    var updateProfileCalled = false
    var updateAvatarCalled = false
    var showLogoutAlertCalled = false

    func updateProfile(name: String, login: String, description: String) {
        updateProfileCalled = true
    }

    func updateAvatar(with url: URL?) {
        updateAvatarCalled = true
    }

    func showLogoutAlert() {
        showLogoutAlertCalled = true
    }
}
