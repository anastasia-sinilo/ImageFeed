import XCTest
@testable import ImageFeed

final class ImagesListTests: XCTestCase {
    
   //MARK: - View - Presenter
    
    @MainActor
    func testViewControllerCallsPresenterViewDidLoad() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let presenterSpy = ImagesListPresenterSpy()
        viewController.presenter = presenterSpy
        presenterSpy.view = viewController
        
        _ = viewController.view
        
        XCTAssertTrue(presenterSpy.viewDidLoadCalled)
    }
    
    //MARK: - Fetch
    
    func testPresenterCallsFetchOnViewDidLoad() {
        let serviceSpy = ImagesListServiceSpy()
        let presenter = ImagesListPresenter(imagesListService: serviceSpy)
        
        presenter.viewDidLoad()
        
        XCTAssertTrue(serviceSpy.fetchNextPageCalled)
    }
    
    //MARK: - InsertsRows
    
    func testPresenterInsertsRowsAfterNotification() {
        let serviceSpy = ImagesListServiceSpy()
        let viewSpy = ImagesListViewControllerSpy()
        
        let presenter = ImagesListPresenter(imagesListService: serviceSpy)
        presenter.view = viewSpy
        
        presenter.viewDidLoad()
        
        serviceSpy.stubPhotos = [makePhoto(id: "1")]
        
        NotificationCenter.default.post(
            name: ImagesListService.didChangeNotification,
            object: nil
        )
        
        XCTAssertTrue(viewSpy.insertRowsCalled)
        XCTAssertEqual(viewSpy.insertedFrom, 0)
        XCTAssertEqual(viewSpy.insertedTo, 1)
    }
    
    //MARK: - ChangeLike
    
    func testDidTapLikeCallsChangeLike() {
        let serviceSpy = ImagesListServiceSpy()
        serviceSpy.stubPhotos = [makePhoto(id: "1")]
        
        let presenter = ImagesListPresenter(imagesListService: serviceSpy)
        presenter.view = ImagesListViewControllerSpy()
        
        presenter.viewDidLoad()
        
        NotificationCenter.default.post(
                name: ImagesListService.didChangeNotification,
                object: serviceSpy
            )
        
        presenter.didTapLike(at: IndexPath(row: 0, section: 0))
        
        XCTAssertTrue(serviceSpy.changeLikeCalled)
    }
    
    //MARK: - Пагинация
    
    func testWillDisplayLastRowFetchesNextPage() {
        let serviceSpy = ImagesListServiceSpy()
        serviceSpy.stubPhotos = [
            makePhoto(id: "1"),
            makePhoto(id: "2")
        ]
        
        let presenter = ImagesListPresenter(imagesListService: serviceSpy)
        
        presenter.viewDidLoad()
        presenter.willDisplayRow(at: IndexPath(row: 1, section: 0))
        
        XCTAssertTrue(serviceSpy.fetchNextPageCalled)
    }
    
    private func makePhoto(id: String) -> Photo {
        Photo(
            id: id,
            size: CGSize(width: 100, height: 100),
            createdAt: nil,
            welcomeDescription: nil,
            thumbImageURL: "",
            largeImageURL: "",
            smallImageURL: "",
            isLiked: false
        )
    }
}
