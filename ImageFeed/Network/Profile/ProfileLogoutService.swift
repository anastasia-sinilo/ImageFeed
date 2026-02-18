import Foundation
import WebKit

final class ProfileLogoutService {
    
    //MARK: - Singleton
    
    static let shared = ProfileLogoutService()
    private init() { }
    
    //MARK: - API
    
    func logout() {
        cleanCookies()
        cleanToken()
        cleanServicesData()
    }
    
    //MARK: - Cleanup Methods
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func cleanToken() {
        OAuth2TokenStorage.shared.token = nil
    }
    
    private func cleanServicesData() {
        ProfileService.shared.clean()
        ProfileImageService.shared.clean()
        ImagesListService.shared.clean()
    }
}
