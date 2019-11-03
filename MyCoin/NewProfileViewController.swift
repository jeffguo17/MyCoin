//
//  NewProfileViewController.swift
//  MyCoin
//
//  Created by jeff on 9/25/19.
//  Copyright © 2019 jeff. All rights reserved.
//

import UIKit
import TextFieldEffects

class NewProfileViewController: UIViewController {

    var firstName: String?
    var lastName: String?
    
    fileprivate let firstNameTextField: HoshiTextField = {
        let textField = HoshiTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont.systemFont(ofSize: 24)
        textField.placeholder = "First Name"
        textField.placeholderFontScale = 0.75
        textField.placeholderColor = UIColor.darkGray
        textField.borderActiveColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
        textField.borderInactiveColor = UIColor.lightGray
        return textField
    }()
    
    fileprivate let lastNameTextField: HoshiTextField = {
        let textField = HoshiTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont.systemFont(ofSize: 24)
        textField.placeholder = "Last Name"
        textField.placeholderFontScale = 0.75
        textField.placeholderColor = UIColor.darkGray
        textField.borderActiveColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
        textField.borderInactiveColor = UIColor.lightGray
        return textField
    }()
    
    @objc func nextProfilePage() {
        guard var firstName = firstNameTextField.text, var lastName = lastNameTextField.text else { return }
        
        if firstName.count <= 0 {
            firstNameTextField.becomeFirstResponder()
            return
        } else if lastName.count <= 0 {
            lastNameTextField.becomeFirstResponder()
            return
        }
        
        firstName = firstName.trimLeadingAndTrailingSpaces()
        if firstName.isEmpty {
            firstNameTextField.text = nil
            firstNameTextField.becomeFirstResponder()
            showAlertMessage(title: "Please enter a valid first name.", message: "", actionMessage: "OK", navigationController: self.navigationController ?? nil)
            return
        }
        
        lastName = lastName.trimLeadingAndTrailingSpaces()
        if lastName.isEmpty {
            lastNameTextField.text = nil
            lastNameTextField.becomeFirstResponder()
            showAlertMessage(title: "Please enter a valid last name.", message: "", actionMessage: "OK", navigationController: self.navigationController ?? nil)
            return
        }
        
        lastNameTextField.selectedTextRange = nil
        
        let alertController = UIAlertController(title: "Profile Picture", message: "Would you like to add a profile picture right now?", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Yes", style: .default) { (action) in
            self.firstName = firstName
            self.lastName = lastName
            self.showImagePickerControllerActionSheet()
        }
        let action2 = UIAlertAction(title: "Maybe Later", style: .cancel) { (action) in
            FirebaseHelper.sharedInstance.createUserProfile(firstName: firstName, lastName: lastName, viewController: self) {
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
        
        alertController.addAction(action1)
        alertController.addAction(action2)
        
        self.navigationController?.present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.hidesBackButton = true
        view.backgroundColor = UIColor.white
        
        self.title = "New Profile"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(nextProfilePage))
        
        view.addSubview(firstNameTextField)
        view.addSubview(lastNameTextField)
        
        firstNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15).isActive = true
        firstNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
        firstNameTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        firstNameTextField.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        lastNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15).isActive = true
        lastNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
        lastNameTextField.topAnchor.constraint(equalTo: firstNameTextField.bottomAnchor, constant: 20).isActive = true
        lastNameTextField.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }

}

extension NewProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    fileprivate func showImagePickerControllerActionSheet() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let photoLibraryAction = UIAlertAction(title: "Choose from Library...", style: .default) {
            (action) in
            self.showImagePickerController(sourceType: .photoLibrary)
        }
        let cameraAction = UIAlertAction(title: "Take Photo...", style: .default) {
            (action) in
            self.showImagePickerController(sourceType: .camera)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(photoLibraryAction)
        alertController.addAction(cameraAction)
        alertController.addAction(cancelAction)
        
        //iPad popover presentation controller fixes
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.lastNameTextField
            popoverController.sourceRect = self.lastNameTextField.bounds
        }
        
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
        
        guard let firstName = self.firstName, let lastName = self.lastName else { return }
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.dismiss(animated: true) {
                FirebaseHelper.sharedInstance.createUserProfileWithImage(firstName: firstName, lastName: lastName, image: editedImage, viewController: self) {
                    self.navigationController?.dismiss(animated: true, completion: nil)
                }
            }
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.dismiss(animated: true) {
                FirebaseHelper.sharedInstance.createUserProfileWithImage(firstName: firstName, lastName: lastName, image: originalImage, viewController: self) {
                    self.navigationController?.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
}
