@testable import ImageFeed
import Foundation

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    
    weak var view: ImagesListViewControllerProtocol?
    
    var viewDidLoadCalled = false
    var didTapLikeCalled = false
    var willDisplayCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func numberOfRows() -> Int { 0 }
    
    func photo(at indexPath: IndexPath) -> Photo {
        fatalError("Not needed for this test")
    }
    
    func didTapLike(at indexPath: IndexPath) {
        didTapLikeCalled = true
    }
    
    func willDisplayRow(at indexPath: IndexPath) {
        willDisplayCalled = true
    }
    
    func heightForRow(at indexPath: IndexPath, tableViewWidth: CGFloat) -> CGFloat {
        0
    }
}
