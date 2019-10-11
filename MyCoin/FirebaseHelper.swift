//
//  FirebaseHelper.swift
//  MyCoin
//
//  Created by jeff on 9/14/19.
//  Copyright © 2019 jeff. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import FirebaseStorage

class FirebaseHelper {
    
    static let sharedInstance = FirebaseHelper()
    
    fileprivate let loadingIndicator: UIAlertController = {
        let alertController = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        
        alertController.view.addSubview(loadingIndicator)
        return alertController
    }()
    
    fileprivate init(){}
    
    func userIsLoggedIn(viewController: UIViewController) {
        if Auth.auth().currentUser == nil {
            // user is not signed in, present sign in page
            let authUI = FUIAuth.defaultAuthUI()
            let phoneAuth = FUIPhoneAuth(authUI:authUI!)
            authUI?.providers = [phoneAuth]
            phoneAuth.signIn(withPresenting: viewController, phoneNumber: "")
        }
    }
    
    func uploadCoinToDatabase(name: String, viewController: UIViewController, completion: @escaping (_ coinId: String) -> Void) {
        guard let userUID = Auth.auth().currentUser?.uid else {
            return
        }
        
        let coinRef = Database.database().reference().child("coins").childByAutoId()
        coinRef.updateChildValues(["createdBy": userUID, "name": name]) { _,_ in
            guard let coinId = coinRef.key else { return }
            let userCoinRef = Database.database().reference().child("users").child(userUID)
                .child("coins").child("created").child(coinId)
            userCoinRef.updateChildValues(["name": name]) { _,_ in
                completion(coinId)
            }
        }
    }
    
    func uploadCoinToDatabase(name: String? = nil, image: UIImage, viewController: UIViewController, completion: @escaping (_ imageURL: String,_ coinId: String, _ error: Error?) -> Void) {
        self.userIsLoggedIn(viewController: viewController)
        let storageRef = Storage.storage().reference().child("CoinImages").child(NSUUID().uuidString)
        
        guard let uploadData = image.jpegData(compressionQuality: 0.5) else { return }
        
        viewController.present(loadingIndicator, animated: true) {
            let metadata = StorageMetadata()
            metadata.contentType = "image/png"
            
            storageRef.putData(uploadData, metadata: metadata, completion: {
                (metadata, error) in
                
                if error != nil {
                    print(error ?? "")
                    viewController.dismiss(animated: true) {
                        completion("", "", error)
                    }
                    return
                }
                
                storageRef.downloadURL { (url, error) in
                    guard let downloadURL = url, let userUID = Auth.auth().currentUser?.uid else {
                        self.deleteFileInStorage(storageRef: storageRef)
                        viewController.dismiss(animated: true) {
                            completion("", "", error)
                        }
                        return
                    }
                    
                    let coinRef = Database.database().reference().child("coins").childByAutoId()
                    var values = ["createdBy": userUID,"image": downloadURL.absoluteString]
                    if let name = name, !name.isEmpty {
                        values["name"] = name
                    }
                    coinRef.updateChildValues(values) { _,_ in
                        guard let coinId = coinRef.key else { return }
                        let userCoinRef = Database.database().reference().child("users").child(userUID)
                            .child("coins").child("created").child(coinId)
                        values.removeValue(forKey: "createdBy")
                        userCoinRef.updateChildValues(values) { _,_ in
                            viewController.dismiss(animated: true) {
                                completion(downloadURL.absoluteString, coinId, nil)
                            }
                            
                        }
                    }
                }
            })
        }
    }
    
    func createUserProfile(firstName: String, lastName: String, viewController: UIViewController, completion: @escaping () -> Void) {
        guard let currUser = Auth.auth().currentUser else { return }
        
        let userUID = currUser.uid
        let userPhoneNum = currUser.phoneNumber ?? ""
        
        let message = loadingIndicator.message
        loadingIndicator.message = "Creating Profile..."
        viewController.present(loadingIndicator, animated: true) {
            let ref = Database.database().reference().child("users")
                .child(userUID).child("profile")
            
            let values = ["firstName": firstName, "lastName": lastName, "phoneNumber": userPhoneNum]
            ref.updateChildValues(values) { _,_ in
                viewController.dismiss(animated: true) {
                    self.loadingIndicator.message = message
                    completion()
                }
            }
        }
    }
    
    func createUserProfileWithImage(firstName: String, lastName: String, image: UIImage, viewController: UIViewController, completion: @escaping ()-> Void) {
        self.userIsLoggedIn(viewController: viewController)
        let storageRef = Storage.storage().reference().child("ProfileImages").child(NSUUID().uuidString)
        
        guard let uploadData = image.jpegData(compressionQuality: 0.5) else { return }
        
        let message = loadingIndicator.message
        loadingIndicator.message = "Creating Profile..."
        viewController.present(loadingIndicator, animated: true) {
            let metadata = StorageMetadata()
            metadata.contentType = "image/png"
            
            storageRef.putData(uploadData, metadata: metadata, completion: {
                (metadata, error) in
                
                if error != nil {
                    print(error ?? "")
                    viewController.dismiss(animated: true) {
                        self.loadingIndicator.message = message
                        completion()
                    }
                    return
                }
                
                storageRef.downloadURL { (url, error) in
                    guard let downloadURL = url, let currUser = Auth.auth().currentUser else {
                        self.deleteFileInStorage(storageRef: storageRef)
                        viewController.dismiss(animated: true) {
                            self.loadingIndicator.message = message
                            completion()
                        }
                        return
                    }
                    let userUID = currUser.uid
                    let userPhoneNum = currUser.phoneNumber ?? ""
                    
                    let ref = Database.database().reference().child("users")
                        .child(userUID).child("profile")
                    
                    let values = ["firstName": firstName, "lastName": lastName, "image": downloadURL.absoluteString, "phoneNumber": userPhoneNum]
                    
                    ref.updateChildValues(values) { _,_ in
                        viewController.dismiss(animated: true) {
                            self.loadingIndicator.message = message
                            completion()
                        }
                    }
                }
            })
        }
    }
    
    func fetchUserProfile(viewController: UIViewController, completion: @escaping (DataSnapshot, String) -> Void) {
        guard let userUID = Auth.auth().currentUser?.uid else {
            return
        }
        let message = loadingIndicator.message
        loadingIndicator.message = "Loading Profile..."
        viewController.present(loadingIndicator, animated: true) {
            let ref = Database.database().reference().child("users")
                .child(userUID).child("profile")
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                viewController.dismiss(animated: true) {
                    self.loadingIndicator.message = message
                    completion(snapshot, userUID)
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    func fetchUserCoins(viewController: UIViewController, completion: @escaping (_ createdCoinSnapshot: [DataSnapshot], _ ownedByCoinSnapshot: [DataSnapshot]) -> Void) {
        guard let _ = Auth.auth().currentUser?.uid else {
            return
        }
        let message = loadingIndicator.message
        loadingIndicator.message = "Loading Your Coins..."
        viewController.present(loadingIndicator, animated: true) {
            self.fetchUserCreatedCoins(completion: { (createdCoinsData) in
                self.fetchUserOwnedByCoins(completion: { (ownedByCoinsData) in
                    viewController.dismiss(animated: true) {
                        self.loadingIndicator.message = message
                        completion(createdCoinsData, ownedByCoinsData)
                    }
                })
            })
            /*
            let ref = Database.database().reference().child("users")
                .child(userUID).child("coins").child("created")
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    
                    
                    viewController.dismiss(animated: true) {
                        self.loadingIndicator.message = message
                        //completion(snapshot)
                    }
                }
            }) { (error) in
                print(error.localizedDescription)
            }
            */
        }
    }
    
    fileprivate func fetchUserCreatedCoins(completion: @escaping ([DataSnapshot]) -> Void) {
        guard let userUID = Auth.auth().currentUser?.uid else {
            return
        }
        let ref = Database.database().reference().child("users")
            .child(userUID).child("coins").child("created")
            
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                completion(snapshot)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    fileprivate func fetchUserOwnedByCoins(completion: @escaping ([DataSnapshot]) -> Void) {
        guard let userUID = Auth.auth().currentUser?.uid else {
            return
        }
        let ref = Database.database().reference().child("users")
            .child(userUID).child("coins").child("ownedBy")
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                completion(snapshot)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func fetchTransactions(viewController: UIViewController, completion: @escaping ([DataSnapshot]) -> Void) {
        let message = loadingIndicator.message
        loadingIndicator.message = "Loading..."
        viewController.present(loadingIndicator, animated: true) {
            let ref = Database.database().reference().child("trans")
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    viewController.dismiss(animated: true) {
                        self.loadingIndicator.message = message
                        completion(snapshot)
                    }
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    func payUser(withPhoneNumber: String, message: String, user: User, selectedCoin: Coin, amount: String, viewController: UIViewController, completion: @escaping () -> Void) {
        guard let _ = Auth.auth().currentUser?.uid else {
            return
        }
        let loadingIndicatorMessage = loadingIndicator.message
        loadingIndicator.message = "Processing..."
        viewController.present(loadingIndicator, animated: true) {
        
            self.getUserProfile(withPhoneNumber: withPhoneNumber) { (recipientUser) in
                
                let recipientFullname = self.getPrettyName(firstName: recipientUser.firstName, lastName: recipientUser.lastName)
                
                let values = ["from": self.getPrettyName(firstName: user.firstName, lastName: user.lastName),
                              "fromImage": user.profileImage,
                              "to": recipientFullname, "message": message, "coinName": selectedCoin.name, "coinImage": selectedCoin.imageURL, "amount": amount]
                
                let ref = Database.database().reference().child("trans").childByAutoId()
                ref.updateChildValues(values) { _,_ in
                    
                    let coinRef = Database.database().reference().child("coins")
                        .child(selectedCoin.id).child("ownedBy").child(user.id)
                    
                    coinRef.updateChildValues(["name": recipientFullname]) { _,_ in
                            
                        let userCoinRef = Database.database().reference().child("users")
                            .child(recipientUser.id).child("coins").child("ownedBy").child(selectedCoin.id)
                            
                        let values = ["name": selectedCoin.name, "image": selectedCoin.imageURL, "amount": amount]
                    
                        userCoinRef.updateChildValues(values) { _,_ in
                            
                            viewController.dismiss(animated: true) {
                                self.loadingIndicator.message = loadingIndicatorMessage
                                completion()
                            }
                            
                        }
                    }
                    
                }
            }
        }
    }
    
    fileprivate func getPrettyName(firstName: String, lastName: String) -> String {
        let firstName = firstName.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let lastName = lastName.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        return firstName + " " + lastName
    }
    
    fileprivate func getUserProfile(withPhoneNumber: String, completion: @escaping (User) -> Void) {
        guard let _ = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = Database.database().reference().child("users").queryOrdered(byChild: "profile/phoneNumber").queryEqual(toValue: withPhoneNumber)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            for snap in snapshot.children {
                let userSnapshot = snap as! DataSnapshot
                let dict = userSnapshot.value as! [String: NSDictionary]
                let user = User(firstName: dict["profile"]?["firstName"] as? String ?? "", lastName: dict["profile"]?["lastName"] as? String ?? "", profileImage: dict["profile"]?["image"] as? String ?? "", id: userSnapshot.key)
                completion(user)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    fileprivate func deleteFileInStorage(storageRef: StorageReference) {
        storageRef.delete(completion: { (error) in
            if let error = error {
                print(error)
                // Uh-oh, an error occurred!
            } else {
                // File deleted successfully
            }
        })
    }
    
}
