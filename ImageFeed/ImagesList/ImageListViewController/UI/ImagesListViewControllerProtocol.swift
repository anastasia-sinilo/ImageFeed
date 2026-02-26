import Foundation

protocol ImagesListViewControllerProtocol: AnyObject {
    func insertRows(from oldCount: Int, to newCount: Int)
    func reloadRow(at indexPath: IndexPath)
    func showLoading()
    func hideLoading()
}
