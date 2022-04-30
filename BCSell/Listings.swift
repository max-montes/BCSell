//
//  Listings.swift
//  BCSell
//
//  Created by Max Montes on 4/28/22.
//

import Foundation
import Firebase
import FirebaseFirestore

class Listings {
    var listingsArray: [Listing] = []
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    // Can be reused. Only thing that may change for new apps are
    //   - # of parameters in loadData (if it is being called by a
    //     value that helps find a document location),
    //   - you'll need to create a convenience initializer in the singular class (Spot, below) that accepts
    //     a dictionary and returns an instance of the singular class,
    //   - and change anything that begins with the word "spot"/"Spot" to the new class names
    func loadData(completed: @escaping () -> ())  {
        db.collection("listings").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("*** ERROR: adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.listingsArray = []
            // there are querySnapshot!.documents.count documents in teh spots snapshot
            for document in querySnapshot!.documents {
              // You'll have to be sure you've created an initializer in the singular class (Listing, below) that acepts a dictionary.
                let listing = Listing(dictionary: document.data())
                listing.documentID = document.documentID
                self.listingsArray.append(listing)
            }
            completed()
        }
    }
    
//    func deleteData(listing: Listing, completion: @escaping (Bool) -> ()) {
//        let db = Firestore.firestore()
//        db.collection("listings").document(listing.documentID).collection("photos").document(documentID).delete { error in
//            if let error = error {
//                print("ERROR: deleting review documentID \(self.documentID). \(error.localizedDescription)")
//                completion(false)
//            } else {
//                self.deleteListing(listing: listing)
//                print("successfully deleted document ")
//                completion(true)
//            }
//        }
//    }
//
//    private func deleteListing(listing: Listing) {
//        guard listing.documentID != "" else {
//            print("ERROR: Did not pass in a valid spot")
//            return
//        }
//        let storage = Storage.storage()
//        let storageRef = storage.reference().child(listing.documentID).child(documentID)
//        storageRef.delete { error in
//            if let error = error {
//                print("ERROR: Could not delete photo")
//            } else {
//                print("Photo successfully deleted")
//            }
//        }
//    }
}
