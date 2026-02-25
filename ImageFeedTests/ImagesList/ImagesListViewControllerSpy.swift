import XCTest
@testable import ImageFeed

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    
    var insertRowsCalled = false
    var reloadRowCalled = false
    var showLoadingCalled = false
    var hideLoadingCalled = false
    
    var insertedFrom: Int?
    var insertedTo: Int?
    
    func insertRows(from oldCount: Int, to newCount: Int) {
        insertRowsCalled = true
        insertedFrom = oldCount
        insertedTo = newCount
    }
    
    func reloadRow(at indexPath: IndexPath) {
        reloadRowCalled = true
    }
    
    func showLoading() {
        showLoadingCalled = true
    }
    
    func hideLoading() {
        hideLoadingCalled = true
    }
}
