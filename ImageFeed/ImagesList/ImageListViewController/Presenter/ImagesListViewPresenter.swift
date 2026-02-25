import Foundation
import UIKit

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    
    private let imagesListService: ImagesListServiceProtocol
    private var imagesListServiceObserver: NSObjectProtocol?
    
    private var photos: [Photo] = []
    
    init(imagesListService: ImagesListServiceProtocol = ImagesListService.shared) {
            self.imagesListService = imagesListService
        }
        
        deinit {
            if let observer = imagesListServiceObserver {
                NotificationCenter.default.removeObserver(observer)
            }
        }
    
    func viewDidLoad() {
        addObserver()
        imagesListService.fetchPhotosNextPage()
    }
    
    private func addObserver() {
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handlePhotosUpdate()
        }
    }
    
    private func handlePhotosUpdate() {
            let oldCount = photos.count
            let newPhotos = imagesListService.photos
            let newCount = newPhotos.count
            
            photos = newPhotos
            
            if oldCount != newCount {
                view?.insertRows(from: oldCount, to: newCount)
            }
        }
    
    func numberOfRows() -> Int {
        photos.count
    }
    
    /*
    func photo(at indexPath: IndexPath) -> Photo {
        photos[indexPath.row]
    }
    */
    func photo(at indexPath: IndexPath) -> Photo {
        guard indexPath.row < photos.count
        else {
            assertionFailure("Index out of range in photo(at:)")
            return photos.last!
        }
        return photos[indexPath.row]
    }
    
    func didTapLike(at indexPath: IndexPath) {
        guard indexPath.row < photos.count else { return }
            
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                
                guard let self else { return }
                
                switch result {
                case .success:
                    self.photos = self.imagesListService.photos
                    self.view?.reloadRow(at: indexPath)
                case .failure(let error):
                    print("[ImagesListViewController.imageListCellDidTapLike]: \(error)")
                }
            }
        }
    }
    
    func willDisplayRow(at indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            imagesListService.fetchPhotosNextPage()
        }
    }
    
    func heightForRow(at indexPath: IndexPath, tableViewWidth: CGFloat) -> CGFloat {
        let photo = photos[indexPath.row]
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableViewWidth - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / photo.size.width
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        
        return cellHeight
    }
}
