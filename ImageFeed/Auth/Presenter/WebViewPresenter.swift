import Foundation
import WebKit

final class WebViewPresenter: WebViewPresenterProtocol {
    weak var view: WebViewViewControllerProtocol?
    private var authHelper: AuthHelperProtocol
    
    init(authHelper: AuthHelperProtocol) {
            self.authHelper = authHelper
        }

    //MARK: - Lifecycle
    
    func viewDidLoad(){
        guard let request = authHelper.authRequest() else { return }
        
        //didUpdateProgressValue(0)
        view?.setProgressValue(0)
        view?.setProgressHidden(false)
        
        view?.load(request: request)
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        let progress = Float(newValue)
        view?.setProgressValue(progress)
        view?.setProgressHidden(shouldHideProgress(for: progress))
    }
    
    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
    
    func code(from url: URL) -> String? {
            authHelper.code(from: url)
        }
}
