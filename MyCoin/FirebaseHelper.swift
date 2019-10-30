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
    
    func uploadCoinToDatabase(currUser: User, name: String, viewController: UIViewController, completion: @escaping (_ coinId: String) -> Void) {
        guard let userUID = Auth.auth().currentUser?.uid else {
            return
        }
        
        viewController.present(loadingIndicator, animated: true) {
            let coinRef = Database.database().reference().child("coins").childByAutoId()
            
            let userFullName = self.getPrettyName(firstName: currUser.firstName, lastName: currUser.lastName)
            
            let values = ["name": userFullName, "image": currUser.profileImage, "phoneNumber": currUser.phoneNumber]
            
            coinRef.updateChildValues(["createdBy": [currUser.id : values], "name": name]) { _,_ in
                guard let coinId = coinRef.key else { return }
                let userCoinRef = Database.database().reference().child("users").child(userUID)
                    .child("coins").child("created").child(coinId)
                userCoinRef.updateChildValues(["name": name]) { _,_ in
                    viewController.dismiss(animated: true) {
                        completion(coinId)
                    }
                }
            }
        }
    }
    
    func uploadCoinToDatabase(currUser: User, name: String? = nil, image: UIImage, viewController: UIViewController, completion: @escaping (_ imageURL: String,_ coinId: String, _ error: Error?) -> Void) {
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
                    
                    let userFullName = self.getPrettyName(firstName: currUser.firstName, lastName: currUser.lastName)
                    let userValues = ["name": userFullName, "image": currUser.profileImage, "phoneNumber": currUser.phoneNumber]
                    
                    var values = ["createdBy": [currUser.id : userValues], "image": downloadURL.absoluteString] as [String : Any]
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
    
    func fetchRecentPeople(completion: @escaping ([DataSnapshot]) -> Void ) {
        guard let userUID = Auth.auth().currentUser?.uid else {
            return
        }
        let ref = Database.database().reference().child("users")
            .child(userUID).child("recentPeople")
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                completion(snapshot)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func fetchCoin(withId: String, completion : @escaping (DataSnapshot) -> Void) {
        guard let _ = Auth.auth().currentUser?.uid else {
            return
        }
        let ref = Database.database().reference().child("coins").child(withId)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            completion(snapshot)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    fileprivate func updateRecentPeople(userFullname: String, currUser: User, recipientFullname: String, recipientUser: User) {
        //update sender's recent people
        let userRef = Database.database().reference().child("users").child(currUser.id).child("recentPeople").child(recipientUser.id)
        
        userRef.updateChildValues(["name": recipientFullname, "image": recipientUser.profileImage, "phoneNumber": recipientUser.phoneNumber])
        
        //update recipient's recent people
        let recipRef = Database.database().reference().child("users").child(recipientUser.id).child("recentPeople").child(currUser.id)
        
        recipRef.updateChildValues(["name": userFullname, "image": currUser.profileImage, "phoneNumber": currUser.phoneNumber])
    }
    
    func fetchTransactions(withUserId: String, completion: @escaping (([Transaction]) -> Void)) {
        var transactionData = [Transaction]()
        
        let ref = (Database.database().reference().child("users").child(withUserId).child("recentTrans")).queryLimited(toLast: 15)
        ref.observeSingleEvent(of: .value, with: { (userSnapshot) in
            for snap in userSnapshot.children {
                let snap = snap as! DataSnapshot
                let transRef = Database.database().reference().child("trans").child(snap.key)
                
                transRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    if let value = snapshot.value as? NSDictionary {
                        transactionData.append(parseTransactionSnapshot(value: value, transId: snap.key))
                        
                        if userSnapshot.childrenCount == transactionData.count {
                            completion(transactionData.reversed())
                        }
                    }
                })
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func fetchReceivesTransactions(withUserId: String, viewController: UIViewController, completion: @escaping ([DataSnapshot]) -> Void) {
        let message = loadingIndicator.message
        loadingIndicator.message = "Loading..."
        viewController.present(loadingIndicator, animated: true) {
            let ref = Database.database().reference().child("trans").queryOrdered(byChild: "to/\(withUserId)").queryLimited(toLast: 20)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    viewController.dismiss(animated: true) {
                        self.loadingIndicator.message = message
                        completion(snapshot.reversed())
                    }
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    func fetchPurchasesTransactions(withUserId: String,viewController: UIViewController, completion: @escaping ([DataSnapshot]) -> Void) {
        let message = loadingIndicator.message
        loadingIndicator.message = "Loading..."
        viewController.present(loadingIndicator, animated: true) {
            let ref = Database.database().reference().child("trans").queryOrdered(byChild: "from/\(withUserId)").queryLimited(toLast: 20)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    viewController.dismiss(animated: true) {
                        self.loadingIndicator.message = message
                        completion(snapshot.reversed())
                    }
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    func fetchTransactions(viewController: UIViewController, completion: @escaping ([DataSnapshot]) -> Void) {
        let message = loadingIndicator.message
        loadingIndicator.message = "Loading..."
        viewController.present(loadingIndicator, animated: true) {
            let ref = Database.database().reference().child("trans").queryLimited(toLast: 20)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    viewController.dismiss(animated: true) {
                        self.loadingIndicator.message = message
                        completion(snapshot.reversed())
                    }
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    func payUser(withPhoneNumber: String, message: String, currUser: User, selectedCoin: Coin, amount: String, viewController: UIViewController, completion: @escaping () -> Void) {
        let loadingIndicatorMessage = loadingIndicator.message
        loadingIndicator.message = "Processing..."
        viewController.present(loadingIndicator, animated: true) {
        
            self.getUserProfile(withPhoneNumber: withPhoneNumber) { (recipientUser) in
                guard let recipientUser = recipientUser else { return }
                
                let recipientFullname = self.getPrettyName(firstName: recipientUser.firstName, lastName: recipientUser.lastName)
                let userFullname = self.getPrettyName(firstName: currUser.firstName, lastName: currUser.lastName)
                
                let values = ["fromImage": currUser.profileImage, "message": message, "coinName": selectedCoin.name, "coinImage": selectedCoin.imageURL, "amount": amount, "timeStamp": ServerValue.timestamp(), "coinId": selectedCoin.id] as [String : Any]
                
                let senderValues = ["name": userFullname, "image": currUser.profileImage, "phoneNumber": currUser.phoneNumber]
                let recipientValues = ["name": recipientFullname, "image": recipientUser.profileImage, "phoneNumber": recipientUser.phoneNumber]
                
                let ref = Database.database().reference().child("trans").childByAutoId()
                
                let senderRef = ref.child("from").child(currUser.id)
                senderRef.updateChildValues(senderValues)
                
                let recipientRef = ref.child("to").child(recipientUser.id)
                recipientRef.updateChildValues(recipientValues)
                
                ref.updateChildValues(values) { _,_ in
                    guard let transId = ref.key else { return }
                    
                    if selectedCoin.id.contains(currUser.id) {
                        let coinRef = Database.database().reference().child("coins")
                            .child(selectedCoin.id).child("createdBy").child(currUser.id)
                        
                        coinRef.updateChildValues(senderValues)
                        /*
                        let userRef = Database.database().reference().child("users")
                            .child(currUser.id).child("coins").child("created").child(selectedCoin.id)
                        
                        userRef.updateChildValues(["name": selectedCoin.name, "image": selectedCoin.imageURL])
                        */
                    }
                    
                    self.updateSenderCoinAmount(selectedCoin: selectedCoin, sender: currUser, amount: amount, transId: transId, completion: { (error) in
                        if let error = error {
                            
                            viewController.dismiss(animated: true) {
                                self.loadingIndicator.message = loadingIndicatorMessage
                                completion()
                            }
                            ref.removeValue()
                            showAlertMessage(title: error, message: "", actionMessage: "OK", navigationController: viewController.navigationController)
                            return
                        }
                        self.updateCoinPayments(selectedCoin: selectedCoin)
                        
                        self.updateRecipientCoinAmount(selectedCoin: selectedCoin, recipientUser: recipientUser, amount: amount, recipientFullname: recipientFullname, userFullname: userFullname, currUser: currUser, transId: transId) {
                            
                            viewController.dismiss(animated: true) {
                                self.loadingIndicator.message = loadingIndicatorMessage
                                completion()
                            }
                        }
                    })
                }
            }
        }
    }
    
    fileprivate func updateSenderCoinAmount(selectedCoin: Coin, sender: User, amount: String, transId: String, completion: @escaping (String?) -> Void) {
        if selectedCoin.amount == -1 {
            completion(nil)
            return
        }
        
        let coinRef = Database.database().reference().child("coins")
            .child(selectedCoin.id).child("ownedBy").child(sender.id)
        
        coinRef.observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            
            let amountDouble = Double(amount) ?? 0
            let dictAmount = Double(value?["amount"] as? String ?? "0") ?? 0
            
            let diffAmount = dictAmount - amountDouble
            if diffAmount < 0 {
                completion("Insufficent Balance!")
                return
            }
            let finalAmount = roundAmountNum(amount: diffAmount)
            let coinRefValue = ["amount": finalAmount]
            
            coinRef.updateChildValues(coinRefValue) { _,_ in
                let senderCoinRef = Database.database().reference().child("users")
                    .child(sender.id).child("coins").child("ownedBy").child(selectedCoin.id)
                
                senderCoinRef.updateChildValues(coinRefValue) { _,_ in
                    completion(nil)
                }
            }
            
            let senderRecentTransRef = Database.database().reference().child("users")
                .child(sender.id).child("recentTrans")
            
            senderRecentTransRef.updateChildValues([transId: true])
        }
    }
    
    fileprivate func updateRecipientCoinAmount(selectedCoin: Coin, recipientUser: User, amount: String, recipientFullname: String, userFullname: String, currUser: User, transId: String, completion: @escaping () -> Void) {
        let coinRef = Database.database().reference().child("coins")
            .child(selectedCoin.id).child("ownedBy").child(recipientUser.id)
        
        coinRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as? NSDictionary
            
            var coinRefAmount = Double(amount) ?? 0
            let dictAmount = Double(value?["amount"] as? String ?? "0") ?? 0
            coinRefAmount += dictAmount
            
            let finalAmount = roundAmountNum(amount: coinRefAmount)
        
            let coinRefValue = ["name": recipientFullname, "image": recipientUser.profileImage, "phoneNumber": recipientUser.phoneNumber, "amount": finalAmount]
            
            coinRef.updateChildValues(coinRefValue) { _,_ in
                
                let recipientCoinRef = Database.database().reference().child("users")
                    .child(recipientUser.id).child("coins").child("ownedBy").child(selectedCoin.id)
                
                let values = ["name": selectedCoin.name, "image": selectedCoin.imageURL, "amount": finalAmount]
                    
                recipientCoinRef.updateChildValues(values) { _,_ in
                        
                    self.updateRecentPeople(userFullname: userFullname, currUser: currUser, recipientFullname: recipientFullname, recipientUser: recipientUser)
                        
                    completion()
                }
                    
            }
            
            let recipientRecentTransRef = Database.database().reference().child("users")
                .child(recipientUser.id).child("recentTrans")
            
            recipientRecentTransRef.updateChildValues([transId: true])
            
        })
    }
    
    fileprivate func updateCoinPayments(selectedCoin: Coin) {
        let coinRef = Database.database().reference().child("coins")
            .child(selectedCoin.id).child("paymentNum")
        
        var paymentNum = 0
        coinRef.observeSingleEvent(of: .value) { (snapshot) in
            
            paymentNum = (snapshot.value as? Int) ?? 0
            
            paymentNum += 1
            coinRef.setValue(paymentNum)
        }
    }
    
    func getPrettyName(firstName: String, lastName: String) -> String {
        let firstName = firstName.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let lastName = lastName.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        return firstName + " " + lastName
    }
    
    func getUserProfile(withPhoneNumber: String, completion: @escaping (User?) -> Void) {
        guard let _ = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = Database.database().reference().child("users").queryOrdered(byChild: "profile/phoneNumber").queryEqual(toValue: withPhoneNumber)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            for snap in snapshot.children {
                let userSnapshot = snap as! DataSnapshot
                let dict = userSnapshot.value as! [String: NSDictionary]
                let user = User(firstName: dict["profile"]?["firstName"] as? String ?? "", lastName: dict["profile"]?["lastName"] as? String ?? "", profileImage: dict["profile"]?["image"] as? String ?? "", id: userSnapshot.key, phoneNumber: withPhoneNumber)
                completion(user)
                return
            }
            completion(nil)
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
    
    func addComment(transId: String, currUser: User, message: String) {
        let ref = Database.database().reference().child("trans").child(transId).child("comments").childByAutoId()
        
        let currUserFullname = self.getPrettyName(firstName: currUser.firstName, lastName: currUser.lastName)
        let values = ["name": currUserFullname, "id": currUser.id, "phoneNumber": currUser.phoneNumber, "image": currUser.profileImage, "message": message, "timeStamp": ServerValue.timestamp()] as [String : Any]
        
        ref.updateChildValues(values)
    }
}
