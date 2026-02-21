import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController, UIScrollViewDelegate {
    
    //MARK: - IBOutlets and Actions
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet var scrollView: UIScrollView!
    
    @IBAction func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
        guard let image = imageView.image else { return }
        let share = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present (share, animated: true, completion: nil)
    }
    
    //MARK: - Properties
    
    var imageURL: URL?
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScrollView()
        loadImage()
    }
    
    //MARK: - Setup Views
    
    func setupScrollView() {
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
    }
    
    //MARK: - Image Loading
    
    private func loadImage() {
        guard let imageURL else { return }
        
        UIBlockingProgressHUD.show()
        
        imageView.kf.setImage(with: imageURL) { [weak self] result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                
                guard let self else { return }
                
                switch result {
                case .success(let imageResult):
                    let image = imageResult.image
                    
                    self.imageView.image = image
                    self.imageView.frame = CGRect(origin: .zero, size: image.size)
                    self.scrollView.contentSize = image.size
                    
                    self.rescaleAndCenterImageInScrollView(image: imageResult.image)
                    
                case .failure(let error):
                    print("[SingleImageViewController.loadImage]: \(error)")
                    self.showError()
                }
            }
        }
    }
    
    //MARK: - Alerts
    
    private func showError() {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Попробовать ещё раз?",
            preferredStyle: .alert
        )
        
        let noAction = UIAlertAction(title: "Не надо", style: .cancel)
        let retryAction = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.loadImage()
        }
        
        alert.addAction(noAction)
        alert.addAction(retryAction)
        
        present(alert, animated: true)
    }
    
    //MARK: - UIScrollViewDelegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    //MARK: - Image Layout
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}
