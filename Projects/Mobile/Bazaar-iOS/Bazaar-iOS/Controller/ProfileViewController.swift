//
//  ProfileViewController.swift
//  Bazaar-iOS
//
//  Created by Beste Goger on 22.11.2020.
//

import UIKit
import GoogleSignIn

class ProfileViewController: UIViewController{
    
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet var menuView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        menuView.layer.borderColor = #colorLiteral(red: 1, green: 0.6235294118, blue: 0, alpha: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let isLoggedIn =  UserDefaults.standard.value(forKey: K.isLoggedinKey) as? Bool {
            if !isLoggedIn {
                self.view.isHidden = true
                performSegue(withIdentifier: "ProfileToLoginSegue", sender: self)
            }else {
                if let firstName = UserDefaults.standard.value(forKey: K.userFirstNameKey) as? String , let lastName = UserDefaults.standard.value(forKey: K.userLastNameKey) as? String  {
                    if firstName.count == 0 && lastName.count == 0 {
                        if let username = UserDefaults.standard.value(forKey: K.usernameKey) as? String  {
                            self.userEmailLabel.text = username
                        }
                    }else {
                        self.userEmailLabel.text = "\(firstName) \(lastName)"
                    }
                }else if let username = UserDefaults.standard.value(forKey: K.usernameKey) as? String  {
                    self.userEmailLabel.text = username
                }
                self.view.isHidden = false
            }
        }else{
            self.view.isHidden = true
            performSegue(withIdentifier: "ProfileToLoginSegue", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProfileToLoginSegue" {
            if let destinationVC = segue.destination as? LoginViewController {
                destinationVC.delegate = self
            }
        }else if segue.identifier == "ProfileToSignUpSegue" {
            if let destinationVC = segue.destination as? SignUpViewController {
                destinationVC.delegate = self
            }
        }
    }
}

//MARK: - Extension LoginViewControllerDelegate
extension ProfileViewController: LoginViewControllerDelegate{
    func loginViewControllerDidloggedIn() {
        self.tabBarController?.selectedViewController = self.tabBarController?.children[0]
    }
    
    func loginViewControllerDidPressSignUp() {
        performSegue(withIdentifier:"ProfileToSignUpSegue" , sender: nil)
    }
    
    func loginViewControllerDidPressContinueAsGuest() {
        self.tabBarController?.selectedViewController = self.tabBarController?.children[0]
    }
}
//MARK: - Extension SignUpViewControllerDelegate
extension ProfileViewController: SignUpViewControllerDelegate{
    func signUpViewControllerDidPressLoginHere() {
        performSegue(withIdentifier:"ProfileToLoginSegue" , sender: nil)
    }
}
