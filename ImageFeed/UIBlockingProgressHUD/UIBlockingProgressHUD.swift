import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }
    
    static func show() {
        window?.isUserInteractionEnabled = false
        configureProgressHUDAppearance()
        ProgressHUD.animate()
    }
    
    static func dismiss() {
        window?.isUserInteractionEnabled = true
        configureProgressHUDAppearance()
        ProgressHUD.dismiss()
    }
    
    private static func configureProgressHUDAppearance() {
        ProgressHUD.animationType = .activityIndicator
        ProgressHUD.mediaSize = 40
        ProgressHUD.marginSize = 20
        ProgressHUD.colorHUD = .white
        ProgressHUD.colorAnimation = .black
    }
}
