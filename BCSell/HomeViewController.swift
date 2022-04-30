//
//  ViewController.swift
//  BCSell
//
//  Created by Max Montes on 4/27/22.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseGoogleAuthUI
import FirebaseAuthUI
import GoogleSignIn

class HomeViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var authUI: FUIAuth!
    var listings: Listings!
    var profiles: Profiles!
    var currentProfile: Profile!

    override func viewDidLoad() {
        super.viewDidLoad()

        if listings == nil {
            listings = Listings()
        }
        
        if profiles == nil {
            profiles = Profiles()
        }
        
        authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        listings.loadData {
            self.tableView.reloadData()
        }
        setProfile()
    }
    
    // Be sure to call this from viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        signIn()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowListing" {
            let destination = segue.destination as! ListingTableViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow!
            destination.listing = listings.listingsArray[selectedIndexPath.row]
        } else if segue.identifier == "AddListing" {
            let navigationController = segue.destination as! UINavigationController
            let destination = navigationController.viewControllers.first as! ListingTableViewController
            destination.profile = self.currentProfile
        } else if segue.identifier == "ShowProfile" {
            let destination = segue.destination as! ProfileViewController
            destination.profile = self.currentProfile
        }
    }

    func setProfile() {
        profiles.loadData {
            guard let postingUserID = (Auth.auth().currentUser?.uid) else {
                print("*** ERROR: Could not save data because we don't have a valid postingUserID")
                return
            }
            self.currentProfile = self.profiles.getProfile(postingUserID: postingUserID)
        }
    }

    // VITAL: This gist includes key changes to make sure "cancel" works with iOS 13.
    func signIn() {
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth(authUI: authUI!),
        ]
        if authUI.auth?.currentUser == nil {
            self.authUI?.providers = providers
            let loginViewController = authUI.authViewController()
            loginViewController.modalPresentationStyle = .fullScreen
            present(loginViewController, animated: true, completion: nil)
        } else {
            tableView.isHidden = false
        }
    }
    
    @IBAction func signOutPressed(_ sender: UIBarButtonItem) {
        do {
            try authUI!.signOut()
            print("^^^ Successfully signed out!")
            tableView.isHidden = true
            signIn()
        } catch {
            tableView.isHidden = true
            print("*** ERROR: Couldn't sign out")
        }
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listings.listingsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = listings.listingsArray[indexPath.row].listingItemName
        cell.detailTextLabel?.text = listings.listingsArray[indexPath.row].author
        return cell
    }
}

extension HomeViewController: FUIAuthDelegate {
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        // other URL handling goes here.
        return false
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if let user = user {
            // Assumes data will be isplayed in a tableView that was hidden until login was verified so unauthorized users can't see data.
            tableView.isHidden = false
            print("^^^ We signed in with the user \(user.email ?? "unknown e-mail")")
        }
    }
    
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        
        // Create an instance of the FirebaseAuth login view controller
        let loginViewController = FUIAuthPickerViewController(authUI: authUI)
        
        // Set background color to white
        loginViewController.view.backgroundColor = UIColor(named: "PrimaryColor")
        
        // Create a frame for a UIImageView to hold our logo
        let marginInsets: CGFloat = 16 // logo will be 16 points from L and R margins
        let imageHeight: CGFloat = 225 // the height of our logo
        let imageY = self.view.center.y - imageHeight // places bottom of UIImageView in the center of the login screen
        let logoFrame = CGRect(x: self.view.frame.origin.x + marginInsets, y: imageY, width: self.view.frame.width - (marginInsets*2), height: imageHeight)
        
        // Create the UIImageView using the frame created above & add the "logo" image
        let logoImageView = UIImageView(frame: logoFrame)
        logoImageView.image = UIImage(named: "logo")
        logoImageView.contentMode = .scaleAspectFit // Set imageView to Aspect Fit
        loginViewController.view.addSubview(logoImageView) // Add ImageView to the login controller's main view
        return loginViewController
    }
}
