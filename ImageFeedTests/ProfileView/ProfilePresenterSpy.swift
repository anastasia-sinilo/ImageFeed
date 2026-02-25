import XCTest
@testable import ImageFeed

final class ProfilePresenterSpy: ProfileViewPresenterProtocol {

    weak var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled = false
    var didTapLogoutCalled = false
    var didConfirmLogoutCalled = false

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func didTapLogout() {
        didTapLogoutCalled = true
    }

    func didConfirmLogout() {
        didConfirmLogoutCalled = true
    }
}
