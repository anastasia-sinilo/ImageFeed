import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet private var tableView: UITableView!
    
    //MARK: - Dependencies
    
    var presenter: ImagesListPresenterProtocol?
    
    //MARK: - Properties
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let placeholder = UIImage(resource: .photoPlaceholder)
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    } ()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if presenter == nil {
            presenter = ImagesListPresenter()
            presenter?.view = self
        }
        
        setupTableView()
        presenter?.viewDidLoad()
    }
    
    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath,
                let photo = presenter?.photo(at: indexPath)
            else {
                print("[ImagesListViewController]: invalid segue destination")
                return
            }
            viewController.imageURL = URL(string: photo.largeImageURL)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    //MARK: - Setup
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
}

//MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        presenter?.heightForRow(at: indexPath, tableViewWidth: tableView.bounds.width) ?? 0
    }
}

//MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.numberOfRows() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ImagesListCell.reuseIdentifier,
                for: indexPath
            )

        guard
            let imageListCell = cell as? ImagesListCell,
            let photo = presenter?.photo(at: indexPath)
        else {
            return UITableViewCell()
        }
        
            imageListCell.delegate = self

            if let createdAt = photo.createdAt {
                imageListCell.dateLabel.text = dateFormatter.string(from: createdAt)
            } else {
                imageListCell.dateLabel.text = ""
            }

            imageListCell.cellImage.kf.indicatorType = .activity

            if let url = URL(string: photo.smallImageURL) {
                imageListCell.cellImage.kf.setImage(with: url, placeholder: placeholder)
            } else {
                imageListCell.cellImage.image = placeholder
            }

            imageListCell.setIsLiked(photo.isLiked)
            return imageListCell
        }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter?.willDisplayRow(at: indexPath)
    }
}

//MARK: - ImageListCellDelegate

extension ImagesListViewController: ImageListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter?.didTapLike(at: indexPath)
    }
}

extension ImagesListViewController: ImagesListViewControllerProtocol {

    func insertRows(from oldCount: Int, to newCount: Int) {
        tableView.performBatchUpdates {
            let indexPaths = (oldCount..<newCount).map {
                IndexPath(row: $0, section: 0)
            }
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }

    func reloadRow(at indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    func showLoading() {
        UIBlockingProgressHUD.show()
    }

    func hideLoading() {
        UIBlockingProgressHUD.dismiss()
    }
}
