//
//  UIProfileViewController.swift
//  BCSell
//
//  Created by Max Montes on 4/30/22.
//

import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var venmoTextField: UITextField!
    @IBOutlet weak var profilePicture: UIImageView!
    
    var profile: Profile!
    var profilePhoto: Photo! {
        didSet {
//            if let url = URL(string: self.profilePhoto.photoURL) {
//                self.profilePicture.sd_imageTransition = .fade
//                self.profilePicture.sd_imageTransition?.duration = 0.2
//                self.profilePicture.sd_setImage(with: url)
//            } else {
//                print("URL Didn't work \(self.profilePhoto.photoURL)")
//                self.profilePhoto.loadImage(profile: self.profile) { (success) in
//                    self.profilePhoto.saveData(profile: self.profile) { (success) in
//                        print("image updated with URL \(self.profilePhoto.photoURL)")
//                    }
//                }
//            }
        }
    }
    
    var imagePickerController = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if profilePhoto == nil {
            profilePhoto = Photo()
        }
        
        imagePickerController.delegate = self
        
        updateUserInterface()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func updateUserInterface() {
        nameTextField.text = profile.name
        venmoTextField.text = profile.venmo
    }
    
    func updateFromUserInterface() {
        profile.name = nameTextField.text ?? ""
        profile.venmo = venmoTextField.text ?? ""
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true)
    }
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        updateFromUserInterface()
        profile.saveData { success in
            
        }
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addProfilePicturePressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { _ in
            self.accessPhotoLibrary()
        }
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            self.accessCamera()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        alertController.addAction(photoLibraryAction)
        alertController.addAction(cameraAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
                
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            profilePicture.image = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profilePicture.image = originalImage
        }
        
        profilePhoto.image = profilePicture.image!
        
        if let url = URL(string: profilePhoto.photoURL) {
            profilePicture.sd_imageTransition = .fade
            profilePicture.sd_imageTransition?.duration = 0.2
            profilePicture.sd_setImage(with: url)
        } else {
            print("URL Didn't work \(profilePhoto.photoURL)")
            profilePhoto.loadImage(profile: profile) { (success) in
                self.profilePhoto.saveData(profile: self.profile) { (success) in
                    print("image updated with URL \(self.profilePhoto.photoURL)")
                }
            }
        }
        
//        profilePhoto.saveData(profile: profile) { success in
//            if success {
//                self.profilePicture.image = self.profilePhoto.image
//            } else {
//                print("😡 ERROR: while uploading profile picture to firebase")
//            }
//        }
        
        dismiss(animated: true)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    func accessPhotoLibrary() {
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true)
    }
    
    func accessCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePickerController.sourceType = .camera
            present(imagePickerController, animated: true)
        } else {
            showAlert(title: "Camera Not Available", message: "There is no camera available on this device.")
        }
    }
    
}
