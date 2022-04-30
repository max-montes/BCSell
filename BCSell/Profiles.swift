//
//  Profiles.swift
//  BCSell
//
//  Created by Max Montes on 4/30/22.
//

import Foundation
import Firebase
import FirebaseFirestore

class Profiles {
    var profilesArray: [Profile] = []
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
        db.collection("profiles").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("*** ERROR: adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.profilesArray = []
            // there are querySnapshot!.documents.count documents in teh spots snapshot
            for document in querySnapshot!.documents {
              // You'll have to be sure you've created an initializer in the singular class (Listing, below) that acepts a dictionary.
                let profile = Profile(dictionary: document.data())
                profile.documentID = document.documentID
                self.profilesArray.append(profile)
            }
            completed()
        }
    }
    
    func getProfile(postingUserID: String) -> Profile {
        for profile in profilesArray {
            if profile.postingUserID == postingUserID {
                return profile
            }
        }
        print("ERROR: postingUserID did not match a profile. Created new profile")
        return Profile()
    }
}
