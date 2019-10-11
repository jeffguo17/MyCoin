//
//  AddCoinViewController.swift
//  MyCoin
//
//  Created by jeff on 9/11/19.
//  Copyright © 2019 jeff. All rights reserved.
//

import UIKit

class AddCoinViewController: UIViewController {

    fileprivate let defaultAddImage = #imageLiteral(resourceName: "add_coin_image")
    
    fileprivate let nameTextView: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.attributedPlaceholder = NSAttributedString(string: "Name (optional)", attributes: [
            .foregroundColor: UIColor.lightGray,
            .font: UIFont.systemFont(ofSize: 18.0)
            ])
        return textField
    }()
    
    fileprivate let coinImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    fileprivate let createButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIView().tintColor
        button.setTitle("Create", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 28)
        button.addTarget(self, action:#selector(createButtonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc fileprivate func createButtonTapped() {
        
        guard let name = nameTextView.text else {
            return
        }
        
        if name.isEmpty && coinImageView.image == defaultAddImage {
            self.showImagePickerControllerActionSheet()
            return
        }
        
        if coinImageView.image == defaultAddImage {
            FirebaseHelper.sharedInstance.uploadCoinToDatabase(name: name, viewController: self) { (coinId) in
                if let mainVC = self.navigationController?.viewControllers.first as? MainViewController {
                    mainVC.addNewCoin(coin: Coin(name: name, imageURL: "", id: coinId, amount: -1) )
                }
                self.navigationController?.popToRootViewController(animated: true)
                //self.dismiss(animated: true, completion: nil)
            }
        } else {
            guard let image = coinImageView.image else { return }
            FirebaseHelper.sharedInstance
                .uploadCoinToDatabase(name: name, image: image, viewController: self) { (imageURL, coinId, error) in
                    if error == nil, let mainVC = self.navigationController?.viewControllers.first as? MainViewController {
                        mainVC.addNewCoin(coin: Coin(name: name, imageURL: imageURL, id: coinId, amount: -1))
                    }
                    self.navigationController?.popToRootViewController(animated: true)
            }
        }
        
    }
    
    @objc fileprivate func coinImageViewTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        showImagePickerControllerActionSheet()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nameTextView.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        
        view.addSubview(nameTextView)
        view.addSubview(coinImageView)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(coinImageViewTapped(tapGestureRecognizer:)))
        coinImageView.addGestureRecognizer(tapGestureRecognizer)
        
        coinImageView.image = defaultAddImage
        coinImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        coinImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        coinImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        coinImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        nameTextView.topAnchor.constraint(equalTo: coinImageView.bottomAnchor).isActive = true
        nameTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15).isActive = true
        nameTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
        nameTextView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        nameTextView.textAlignment = .center
        
        createButton.sizeToFit()
        
        nameTextView.inputAccessoryView = createButton
        
    }

}

extension AddCoinViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    fileprivate func showImagePickerControllerActionSheet() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let photoLibraryAction = UIAlertAction(title: "Choose from Library...", style: .default) {
            (action) in self.showImagePickerController(sourceType: .photoLibrary)
        }
        let cameraAction = UIAlertAction(title: "Take Photo...", style: .default) {
            (action) in self.showImagePickerController(sourceType: .camera)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(photoLibraryAction)
        alertController.addAction(cameraAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func showImagePickerController(sourceType: UIImagePickerController.SourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = sourceType
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            coinImageView.image = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            coinImageView.image = originalImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
}
