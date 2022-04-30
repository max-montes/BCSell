//
//  Listing.swift
//  BCSell
//
//  Created by Max Montes on 4/27/22.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestore

class Listing {
    var author: String
    var listingItemName: String
    //TODO: format into dollar format
    var price: Double
    var venmo: String
    var postedOn: Date
    var photos: [UIImage]
    var photosUUID: [String]
    var description: String
    var postingUserID: String
    var documentID: String
    
    var dictionary: [String: Any] {
        let timeIntervalDate = postedOn.timeIntervalSince1970
        return ["author": author, "listingItemName": listingItemName, "price": price, "venmo": venmo, "postedOn": timeIntervalDate, "description": description, "photosUUID": photosUUID, "postingUserID": postingUserID, "documentID": documentID]
    }
    
    init(author: String, listingItemName: String, price: Double, venmo: String, postedOn: Date, photos: [UIImage], photosUUID: [String], description: String, postingUserID: String, documentID: String) {
        self.author = author
        self.listingItemName = listingItemName
        self.price = price
        self.venmo = venmo
        self.postedOn = postedOn
        self.photos = photos
        self.photosUUID = photosUUID
        self.description = description
        self.postingUserID = postingUserID
        self.documentID = documentID
    }
    
    convenience init() {
        self.init(author: "", listingItemName: "", price: 0.00, venmo: "", postedOn: Date(), photos: [], photosUUID: [], description: "", postingUserID: "", documentID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let author = dictionary["author"] as! String? ?? ""
        let listingItemName = dictionary["listingItemName"] as! String? ?? ""
        let price = dictionary["price"] as! Double? ?? 0.0
        let venmo = dictionary["venmo"] as! String? ?? ""
        let timeIntervalDate = dictionary["postedOn"] as! TimeInterval? ?? TimeInterval()
        let postedOn = Date(timeIntervalSince1970: timeIntervalDate)
        let photos = dictionary["photos"] as! [UIImage]? ?? []
        let photosUUID = dictionary["photosUUID"] as! [String]? ?? []
        let description = dictionary["description"] as! String? ?? ""
        let postingUserID = dictionary["postingUserID"] as! String? ?? ""

        self.init(author: author, listingItemName: listingItemName, price: price, venmo: venmo, postedOn: postedOn, photos: photos, photosUUID: photosUUID, description: description, postingUserID: postingUserID, documentID: "")
    }
    
    // NOTE: If you keep the same programming conventions (e.g. a calculated property .dictionary that converts class properties to String: Any pairs, the name of the document stored in the class as .documentID) then the only thing you'll need to change is the document path (i.e. the lines containing "spots" below.
    func saveData(completion: @escaping (Bool) -> ())  {
        let db = Firestore.firestore()
        // Grab the user ID
        guard let postingUserID = (Auth.auth().currentUser?.uid) else {
            print("*** ERROR: Could not save data because we don't have a valid postingUserID")
            return completion(false)
        }
        self.postingUserID = postingUserID
        // Create the dictionary representing data we want to save
        let dataToSave: [String: Any] = self.dictionary
        // if we HAVE saved a record, we'll have an ID
        if self.documentID != "" {
            let ref = db.collection("listings").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                if let error = error {
                    print("ERROR: updating document \(error.localizedDescription)")
                    completion(false)
                } else { // It worked!
                    completion(true)
                }
            }
        } else { // Otherwise create a new document via .addDocument
            var ref: DocumentReference? = nil // Firestore will creat a new ID for us
            ref = db.collection("listings").addDocument(data: dataToSave) { (error) in
                if let error = error {
                    print("ERROR: adding document \(error.localizedDescription)")
                    completion(false)
                } else { // It worked! Save the documentID in Spot’s documentID property
                    self.documentID = ref!.documentID
                    completion(true)
                }
            }
        }
    }
    

    
//    func saveImages(completed: @escaping (Bool) -> ()) {
//        let db = Firestore.firestore()
//        let storage = Storage.storage()
//        //Convert appImage to Data type so it can be saved by Firebase Storage
//        if photos.count == 0 {
//            return
//        }
//
//        for i in 0...photos.count-1 {
//            let photo = photos[i]
//            //var photoUUID = photosUUID[i]
//            guard let imageToSave = photo.jpegData(compressionQuality: 0.7) else {
//                print("Could not convert image to data format")
//                return completed(false)
//            }
//            let uploadMetaData = StorageMetadata()
//            uploadMetaData.contentType = "image/jpeg"
//            while photosUUID.count - 1 < i {
//                photosUUID.append("")
//            }
//            var photoUUID = photosUUID[i]
//            if photoUUID != "" {
//                //If there's no UUID, create one, and add it to array
//                photoUUID = UUID().uuidString
//                photosUUID[i] = photoUUID
//            }
//            //Create ref to upload storage with UUID we created
//            let storageRef = storage.reference().child(documentID).child(photoUUID)
//            let uploadTask = storageRef.putData(imageToSave, metadata: uploadMetaData) { metadata, error in
//                guard error == nil else {
//                    print("ERROR: during .putData storage upload for reference \(storageRef). Error = \(error?.localizedDescription ?? "<Unknown Error>")")
//                    return completed(false)
//                }
//                print("😎 Upload worked: metadata is \(metadata)")
//            }
//            uploadTask.observe(.success) { snapshot in
//                //Create the dictionary representing the data we want to save
//                let dataToSave = self.dictionary
//                let ref = db.collection("listings").document(self.documentID)
//                ref.setData(dataToSave) { error in
//                    if let error = error {
//                        print("ERROR: saving document \(self.documentID) in success observer. Error = \(error.localizedDescription)")
//                        completed(false)
//                    } else {
//                        print("Document updated with ref ID \(ref.documentID)")
//                        completed(true)
//                    }
//                }
//            }
//
//            uploadTask.observe(.failure) { snapshot in
//                if let error = snapshot.error {
//                    print("ERROR: \(error.localizedDescription) upload task for file \(photoUUID)")
//                    return completed(false)
//                }
//            }
//        }
//    }
//}
}
