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
        return ["image": image, "photoUserID": photoUserID, "photoUserEmail": photoUserEmail, "photoURL": photoURL, "documentID": documentID]
    }
    
    init(image: UIImage, description: String, photoUserID: String, photoUserEmail: String, date: Date, photoURL: String, documentID: String) {
        self.image = image
        self.photoUserID = photoUserID
        self.photoUserEmail = photoUserEmail
        self.photoURL = photoURL
        self.documentID = documentID
    }
    
    convenience init() {
        let photoUserID = Auth.auth().currentUser?.uid ?? ""
        let photoUserEmail = Auth.auth().currentUser?.email ?? "unknown email"
        self.init(image: UIImage(), description: "", photoUserID: photoUserID, photoUserEmail: photoUserEmail, date: Date(), photoURL: "", documentID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let description = dictionary["description"] as! String? ?? ""
        let photoUserID = dictionary["photoUserID"] as! String? ?? ""
        let photoUserEmail = dictionary["photoUserEmail"] as! String? ?? ""
        let timeIntervalDate = dictionary["date"] as! TimeInterval? ?? TimeInterval()
        let date = Date(timeIntervalSince1970: timeIntervalDate)
        let photoURL = dictionary["photoURL"] as! String? ?? ""
        
        self.init(image: UIImage(), description: description, photoUserID: photoUserID, photoUserEmail: photoUserEmail, date: date, photoURL: photoURL, documentID: "")
    }
    
    func saveData(listing: Listing, completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        let storage = Storage.storage()
        
        guard let photoData = self.image.jpegData(compressionQuality: 0.5) else {
            print("ERROR: Could not convert photo.photo to Data")
            return
        }
        //create metadata so that we can see images in Firebase Storage Console
        let uploadMetaData = StorageMetadata()
        uploadMetaData.contentType = "image/jpeg"
        
        //create file name if necessary
        if documentID == "" {
            documentID = UUID().uuidString
        }
        
        //create a storage reference to upload this image file to the listing's folder
        let storageRef = storage.reference().child(listing.documentID).child(documentID)
        
        //create upload task
        let uploadTask = storageRef.putData(photoData, metadata: uploadMetaData) { metadata, error in
            if let error = error {
                print("\(error.localizedDescription)")
            }
        }
        
        uploadTask.observe(.success) { snapshot in
            print("Upload to Firebase Storage was successful")
            
            storageRef.downloadURL { url, error in
                guard url != nil else {
                    print("ERROR: couldn't create a download URL")
                    return completion(false)
                }
                guard let url = url else {
                    print("ERROR: url was nil and this should not have happened because we've already shown there was no error")
                    return completion(false)
                }
                self.photoURL = "\(url)"
                
                let dataToSave: [String: Any] = self.dictionary
                let ref = db.collection("listings").document(listing.documentID).collection("photos").document(self.documentID)
                ref.setData(dataToSave) { (error) in guard error == nil else {
                    print("ERROR: error updating document \(error!.localizedDescription)")
                    return completion(false)
                }
                print("Updated document: \(self.documentID)")
                completion(true)
                }
            }
        }
        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error {
                print("\(error.localizedDescription)")
            }
            completion(false)
        }
    }
}
