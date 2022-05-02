//
//  ListingTableViewController.swift
//  BCSell
//
//  Created by Max Montes on 4/27/22.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseGoogleAuthUI
import FirebaseAuthUI
import GoogleSignIn

private let dateFormatter: DateFormatter =  {
    let dateFormatter = DateFormatter()
    dateFormatter.setLocalizedDateFormatFromTemplate("EEE, MMM d, h:mm a")
    //dateFormatter.dateStyle = .medium
    //dateFormatter.timeStyle = .none
    return dateFormatter
}()

class ListingTableViewController: UITableViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var itemNameTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var venmoTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    @IBOutlet weak var datePostedTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextView!
    @IBOutlet weak var addImagesButton: UIButton!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var listing: Listing!
    var photos: Photos!
    var photo: Photo!
    var profile: Profile!
    
    var imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        imagePickerController.delegate = self
        
        if listing == nil {
            listing = Listing()
        }
        
        if photos == nil {
            photos = Photos()
        }
        
        updateUserInterface()
        if itemNameTextField.text == "" {
            itemNameTextField.text = "Enter item name"
        }
    }
    
    func removeBordersForTextFields() {
        priceTextField.noBorder()
        venmoTextField.noBorder()
        authorTextField.noBorder()
        datePostedTextField.noBorder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        photos.loadData(listing: listing) {
            self.collectionView.reloadData()
        }
    }
    
    func updateUserInterface() {
        //Set listing author, venmo, and date fields to profile fields
        authorTextField.isEnabled = false
        venmoTextField.isEnabled = false
        datePostedTextField.isEnabled = false
        if authorTextField.text == "" {
            //Do not listen to warning
            authorTextField.text = (profile != nil ? profile.name : "")
        } else {
            authorTextField.text = listing.author
        }
        if venmoTextField.text == "" {
            venmoTextField.text = profile.venmo
        } else {
            venmoTextField.text = listing.venmo
        }
        itemNameTextField.text = listing.listingItemName
        priceTextField.text = String(format: "%.2f", listing.price)
        datePostedTextField.text = dateFormatter.string(from: listing.postedOn)
        descriptionTextField.text = listing.description
        if listing.documentID == "" { // This is a new review
            addBordersToEditableObjects()
        } else {
            if listing.postingUserID == Auth.auth().currentUser?.uid { // Review posted by current user
                enableEditing()
            } else { // Review posted by different user
                disableEditing()
            }
        }
    }
    
    func enableEditing() {
        self.navigationItem.leftItemsSupplementBackButton = false
        saveButton.title = "Update"
        cancelButton.title = "Cancel"
        addBordersToEditableObjects()
        //TODO: Add delete button
    }
    
    func updateFromUserInterface() {
        listing.listingItemName = itemNameTextField.text ?? ""
        listing.price = Double(priceTextField.text ?? "0.00") ?? 0.00
        listing.venmo = venmoTextField.text ?? ""
        listing.author = authorTextField.text ?? ""
        listing.postedOn = DateFormatter().date(from: datePostedTextField.text ?? "") ?? Date()
        listing.description = descriptionTextField.text ?? ""
    }
    
    func disableEditing() {
        saveButton.hide()
        saveButton.title = "Save"
        cancelButton.title = "Back"
        itemNameTextField.isEnabled = false
        priceTextField.isEnabled = false
        venmoTextField.isEnabled = false
        authorTextField.isEnabled = false
        datePostedTextField.isEnabled = false
        descriptionTextField.isEditable = false
        addImagesButton.isHidden = true
    }
    
    func addBordersToEditableObjects() {
        itemNameTextField.addBorder(width: 0.2, radius: 5.0, color: .black)
        priceTextField.addBorder(width: 0.2, radius: 5.0, color: .black)
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true)
    }
    
    func leaveViewController() {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        updateFromUserInterface()
        listing.saveData { success in
            if success {
                self.leaveViewController()
            } else {
                self.oneButtonAlert(title: "Save Failed", message: "For some reason, the data would not save to the cloud.")
            }
        }
        leaveViewController()
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
    
    @IBAction func addImagesButtonPressed(_ sender: UIButton) {
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

extension ListingTableViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.photoArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! PhotosCollectionViewCell
        cell.listing = listing
        cell.photo = photos.photoArray[indexPath.row]
        return cell
    }
}

extension ListingTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //TODO: Add feature to delete images
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let photo = Photo()
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            photo.image = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            photo.image = originalImage
        }
        
        photo.saveData(listing: listing) { success in
            if success {
                self.photos.loadData(listing: self.listing) {
                    self.collectionView.reloadData()
                }
            }
        }
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
