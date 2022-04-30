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
    
    var profile: Profile!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if profile == nil {
            profile = Profile()
        }
        
        updateUserInterface()
    }
    
    func updateUserInterface() {
        nameTextField.text = profile.name
        venmoTextField.text = profile.venmo
    }
    
    func updateFromUserInterface() {
        profile.name = nameTextField.text ?? ""
        profile.venmo = venmoTextField.text ?? ""
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
    
}
