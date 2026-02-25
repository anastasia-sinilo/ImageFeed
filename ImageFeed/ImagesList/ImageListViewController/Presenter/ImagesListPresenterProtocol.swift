import Foundation

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    
    func viewDidLoad()
    func numberOfRows() -> Int
    func photo(at indexPath: IndexPath) -> Photo
    func didTapLike(at indexPath: IndexPath)
    func willDisplayRow(at indexPath: IndexPath)
    func heightForRow(at indexPath: IndexPath, tableViewWidth: CGFloat) -> CGFloat
}
