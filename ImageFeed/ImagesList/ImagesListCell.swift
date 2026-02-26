import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    //MARK: - IBOutlets
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var likeButton: UIButton!
    
    //MARK: - Delegate
    
    weak var delegate: ImageListCellDelegate?
    
    //MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellImage.kf.cancelDownloadTask()
        cellImage.image = nil
    }
    
    //MARK: - Config
    
    func setIsLiked(_ isLiked: Bool) {
        let likeImage = isLiked
        ? UIImage(resource: .likeButtonOn)
        : UIImage(resource: .likeButtonOff)
        
        likeButton.setImage(likeImage, for: .normal)
        
        likeButton.accessibilityIdentifier = "likeButton"
        /*
        likeButton.accessibilityIdentifier = isLiked
                ? "likeButtonOn"
                : "likeButtonOff"
         */
    }
    
    //MARK: - IBActions
    
    @IBAction func likeButtonClicked(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
}
