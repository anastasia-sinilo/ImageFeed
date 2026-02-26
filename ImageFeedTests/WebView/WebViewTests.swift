import XCTest
@testable import ImageFeed

final class WebViewTests: XCTestCase {
    
    private var presenter: WebViewPresenter!
    private var presenterSpy: WebViewPresenterSpy!
    private var viewControllerSpy: WebViewViewControllerSpy!
    private var authHelper: AuthHelper!
    
    override func setUp() {
         super.setUp()
         authHelper = AuthHelper()
     }
     
     override func tearDown() {
         presenter = nil
         presenterSpy = nil
         viewControllerSpy = nil
         authHelper = nil
         super.tearDown()
     }
    
    @MainActor
    func testViewControllerCallsViewDidLoad() {
        //given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        
        presenterSpy = WebViewPresenterSpy()
        viewController.presenter = presenterSpy
        presenterSpy.view = viewController
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenterSpy.viewDidLoadCalled)
    }
     
    @MainActor
    func testPresenterCallsLoadRequest() {
        //given

        viewControllerSpy = WebViewViewControllerSpy()
        presenter = WebViewPresenter(authHelper: authHelper)
        
        viewControllerSpy.presenter = presenter
        presenter.view = viewControllerSpy
        
        //when
        presenter.viewDidLoad()
        
        //then
        XCTAssertTrue(viewControllerSpy.loadRequestCalled)
    }
    
    @MainActor
    func testProgressVisibleWhenLessThenOne() {
        //given
        presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 0.6
        
        //when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        //then
        XCTAssertFalse(shouldHideProgress)
    }
    
    @MainActor
    func testProgressHiddenWhenOne() {
        //given
        presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 1.0
        
        //when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        //then
        XCTAssertTrue(shouldHideProgress)
    }
    
    func testAuthHelperAuthURL() {
        //given
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: configuration)
        
        //when
        let url = authHelper.authURL()
        guard let urlString = url?.absoluteString else {
            XCTFail("authURL returned nil")
            return
        }
        
        //then
        XCTAssertTrue(urlString.contains(configuration.authURLString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
    }
    
    func testCodeFromURL() {
        //given
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")!
        urlComponents.queryItems = [URLQueryItem(name: "code", value: "test code")]
        let url = urlComponents.url!
        let authHelper = AuthHelper()
        
        //when
        let code = authHelper.code(from: url)
        
        //then
        XCTAssertEqual(code, "test code")
    }
}
