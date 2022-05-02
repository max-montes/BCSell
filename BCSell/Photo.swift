//
//  Photo.swift
//  BCSell
//
//  Created by Max Montes on 4/29/22.
//

import UIKit
import Firebase
import FirebaseFirestore

class Photo {
    var image: UIImage
    var photoUserID: String
    var photoUserEmail: String
    var photoURL: String
    var documentID: String
    
    var dictionary: [String: Any] {
        return ["image": image, "photoUserID": photoUserID, "photoUserEmail": photoUserEmail, "photoURL": photoURL]
    }
    
    init(image: UIImage, photoUserID: String, photoUserEmail: String, date: Date, photoURL: String, documentID: String) {
        self.image = image
        self.photoUserID = photoUserID
        self.photoUserEmail = photoUserEmail
        self.photoURL = photoURL
        self.documentID = documentID
    }
    
    convenience init() {
        let photoUserID = Auth.auth().currentUser?.uid ?? ""
        let photoUserEmail = Auth.auth().currentUser?.email ?? "unknown email"
        self.init(image: UIImage(), photoUserID: photoUserID, photoUserEmail: photoUserEmail, date: Date(), photoURL: "", documentID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let photoUserID = dictionary["photoUserID"] as! String? ?? ""
        let photoUserEmail = dictionary["photoUserEmail"] as! String? ?? ""
        let timeIntervalDate = dictionary["date"] as! TimeInterval? ?? TimeInterval()
        let date = Date(timeIntervalSince1970: timeIntervalDate)
        let photoURL = dictionary["photoURL"] as! String? ?? ""
        let image = dictionary["image"] as! UIImage? ?? UIImage()
        
        self.init(image: image, photoUserID: photoUserID, photoUserEmail: photoUserEmail, date: date, photoURL: photoURL, documentID: "")
    }
    
    func saveData(listing: Listing, completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        let storage = Storage.storage()
        
        // convert photo.image to a Data type so that it can be saved in Firebase Storage
        guard let photoData = self.image.jpegData(compressionQuality: 0.5) else {
            print("😡 ERROR: Could not convert photo.image to Data.")
            return
        }
        
        // create metadata so that we can see images in the Firebase Storage Console
        let uploadMetaData = StorageMetadata()
        uploadMetaData.contentType = "image/jpeg"
        
        // create filename if necessary
        if documentID == "" {
            documentID = UUID().uuidString
        }
        
        // create a storage reference to upload this image file to the listing's folder
        let storageRef = storage.reference().child(listing.documentID).child(documentID)
        
        // create an uplaodTask
        let uploadTask = storageRef.putData(photoData, metadata: uploadMetaData) { (metadata, error) in
            if let error = error {
                print("😡 ERROR: uplaod for ref \(uploadMetaData) failed. \(error.localizedDescription)")
            }
        }
        
        uploadTask.observe(.success) { (snapshot) in
            print("Upload to Firebase Storage was successful!")
            
            storageRef.downloadURL { (url, error) in
                guard error == nil else {
                    print("😡 ERROR: Couldn't create a download url \(error!.localizedDescription)")
                    return completion(false)
                }
                guard let url = url else {
                    print("😡 ERROR: url was nil and this should not have happened because we've already shown there was no error.")
                    return completion(false)
                }
                self.photoURL = "\(url)"
                
                // Create the dictionary representing data we want to save
                let dataToSave = self.dictionary
                let ref = db.collection("listings").document(listing.documentID).collection("photos").document(self.documentID)
                ref.setData(dataToSave) { (error) in
                    guard error == nil else {
                        print("😡 ERROR: updating document \(error!.localizedDescription)")
                        return completion(false)
                    }
                    print("💨 Updated document: \(self.documentID) in spot: \(listing.documentID)") // It worked!
                    completion(true)
                }
            }
        }
        
        uploadTask.observe(.failure) { (snapshot) in
            if let error = snapshot.error {
                print("ERROR: upload task for file \(self.documentID) failed, in spot \(listing.documentID), with error \(error.localizedDescription)")
            }
            completion(false)
        }
    }
    
    func saveData(profile: Profile, completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        let storage = Storage.storage()
        
        // convert photo.image to a Data type so that it can be saved in Firebase Storage
        guard let photoData = self.image.jpegData(compressionQuality: 0.5) else {
            print("😡 ERROR: Could not convert photo.image to Data.")
            return
        }
        
        // create metadata so that we can see images in the Firebase Storage Console
        let uploadMetaData = StorageMetadata()
        uploadMetaData.contentType = "image/jpeg"
        
        // create filename if necessary
        if documentID == "" {
            documentID = UUID().uuidString
        }
        
        // create a storage reference to upload this image file to the spot's folder
        let storageRef = storage.reference().child(profile.documentID).child(documentID)
        
        // create an uplaodTask
        let uploadTask = storageRef.putData(photoData, metadata: uploadMetaData) { (metadata, error) in
            if let error = error {
                print("😡 ERROR: uplaod for ref \(uploadMetaData) failed. \(error.localizedDescription)")
            }
        }
        
        uploadTask.observe(.success) { (snapshot) in
            print("Upload to Firebase Storage was successful!")
            
            storageRef.downloadURL { (url, error) in
                guard error == nil else {
                    print("😡 ERROR: Couldn't create a download url \(error!.localizedDescription)")
                    return completion(false)
                }
                guard let url = url else {
                    print("😡 ERROR: url was nil and this should not have happened because we've already shown there was no error.")
                    return completion(false)
                }
                self.photoURL = "\(url)"
                
                // Create the dictionary representing data we want to save
                let dataToSave = self.dictionary
                let ref = db.collection("profiles").document(profile.documentID).collection("photos").document(self.documentID)
                ref.setData(dataToSave) { (error) in
                    guard error == nil else {
                        print("😡 ERROR: updating document \(error!.localizedDescription)")
                        return completion(false)
                    }
                    print("💨 Updated document: \(self.documentID) in spot: \(profile.documentID)") // It worked!
                    completion(true)
                }
            }
        }
        
        uploadTask.observe(.failure) { (snapshot) in
            if let error = snapshot.error {
                print("ERROR: upload task for file \(self.documentID) failed, in spot \(profile.documentID), with error \(error.localizedDescription)")
            }
            completion(false)
        }
    }
    
    func loadImage(listing: Listing, completion: @escaping (Bool) -> ()) {
        guard listing.documentID != "" else {
            print("😡 ERROR: did not pass a valid listing into loadImage")
            return
        }
        let storage = Storage.storage()
        let storageRef = storage.reference().child(listing.documentID).child(documentID)
        storageRef.getData(maxSize: 25 * 1024 * 1024) { (data, error) in
            if let error = error {
                print("ERROR: an error occurred while reading data from file ref: \(storageRef) error = \(error.localizedDescription)")
                return completion(false)
            } else {
                self.image = UIImage(data: data!) ?? UIImage()
                return completion(true)
            }
        }
    }
    
    func loadImage(profile: Profile, completion: @escaping (Bool) -> ()) {
        guard profile.documentID != "" else {
            print("😡 ERROR: did not pass a valid profile into loadImage")
            return
        }
        let storage = Storage.storage()
        let storageRef = storage.reference().child(profile.documentID).child(documentID)
        storageRef.getData(maxSize: 25 * 1024 * 1024) { (data, error) in
            if let error = error {
                print("ERROR: an error occurred while reading data from file ref: \(storageRef) error = \(error.localizedDescription)")
                return completion(false)
            } else {
                self.image = UIImage(data: data!) ?? UIImage()
                return completion(true)
            }
        }
    }
}
