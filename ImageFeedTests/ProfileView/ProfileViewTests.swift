import XCTest
@testable import ImageFeed

final class ProfileTests: XCTestCase {
    
    // MARK: - View - Presenter
    
    @MainActor
    func testViewControllerCallsPresenterViewDidLoad() {
        // given
        let presenter = ProfilePresenterSpy()
        let viewController = ProfileViewController(presenter: presenter)
        presenter.view = viewController
        
        // when
        _ = viewController.view
        
        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    //MARK: - Update Profile
    
    func testPresenterCallsUpdateProfile() {
        let presenter = ProfileViewPresenter()
        let viewSpy = ProfileViewControllerSpy()
        presenter.view = viewSpy
        
        presenter.viewDidLoad()
        
        XCTAssertTrue(viewSpy.updateProfileCalled)
    }
    
    //MARK: - Update Avatar
    
    func testPresenterCallsUpdateAvatar() {
        let presenter = ProfileViewPresenter()
        let viewSpy = ProfileViewControllerSpy()
        presenter.view = viewSpy
        
        presenter.viewDidLoad()
        
        XCTAssertTrue(viewSpy.updateAvatarCalled)
    }
    
    //MARK: - Logout Alert
    
    func testPresenterCallsShowLogoutAlert() {
        let presenter = ProfileViewPresenter()
        let viewSpy = ProfileViewControllerSpy()
        presenter.view = viewSpy
        
        presenter.didTapLogout()
        
        XCTAssertTrue(viewSpy.showLogoutAlertCalled)
    }
}
