import UIKit

final class ProfileViewController: UIViewController {
    
    private enum Constants {
        static let nameText = "Екатерина Новикова"
        static let loginText = "@ekaterina_nov"
        static let descriptionText = "Hello, world!"
    }
    
    //MARK: - UI Elements
    
    private let profileImage = UIImageView()
    private let nameLabel = UILabel()
    private let loginLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let logoutButton = UIButton(type: .system)
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupProfileImage()
        setupNameLabel()
        setupLoginLabel()
        setupDescriptionLabel()
        setupLogoutButton()
        
        setupConstraints()
    }
    
    //MARK: - Setup Views
    
    private func setupProfileImage() {
        let imageView = UIImage(resource: .profile)
        profileImage.image = imageView
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileImage)
    }
    
    private func setupNameLabel() {
        nameLabel.text = Constants.nameText
        nameLabel.textColor = UIColor(resource: .white)
        nameLabel.font = .systemFont(ofSize: 23, weight: .bold)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
    }
    
    private func setupLoginLabel() {
        loginLabel.text = Constants.loginText
        loginLabel.textColor = UIColor(resource: .gray)
        loginLabel.font = .systemFont(ofSize: 13, weight: .regular)
        loginLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginLabel)
    }
    
    private func setupDescriptionLabel() {
        descriptionLabel.text = Constants.descriptionText
        descriptionLabel.textColor = UIColor(resource: .white)
        descriptionLabel.font = .systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
    }
    
    private func setupLogoutButton() {
        let image = UIImage(resource: .logoutButton)
        logoutButton.setImage(image, for: .normal)
        logoutButton.tintColor = UIColor(resource: .red)
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
    }
    
    @objc
    private func didTapLogoutButton(){
        print("Logout Button tapped")
    }
    
    //MARK: - Setup Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            profileImage.heightAnchor.constraint(equalToConstant: 70),
            profileImage.widthAnchor.constraint(equalToConstant: 70),
            profileImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profileImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            nameLabel.heightAnchor.constraint(equalToConstant: 18),
            nameLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            
            loginLabel.heightAnchor.constraint(equalToConstant: 18),
            loginLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginLabel.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            
            descriptionLabel.heightAnchor.constraint(equalToConstant: 18),
            descriptionLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 45),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
}
