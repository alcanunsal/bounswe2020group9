//
//  MyAccountViewController.swift
//  Bazaar-iOS
//
//  Created by Muhsin Etki on 13.12.2020.
//

import UIKit
import GoogleSignIn

class MyAccountViewController: UIViewController {
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var frameView: UIView!
    @IBOutlet weak var passwordUpdateView: UIView!
    @IBOutlet weak var currentPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordAgainTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newPasswordTextField.textContentType = .oneTimeCode
        currentPasswordTextField.textContentType = .oneTimeCode
        newPasswordAgainTextField.textContentType = .oneTimeCode
        frameView.layer.borderColor = #colorLiteral(red: 1, green: 0.6235294118, blue: 0, alpha: 1)
        passwordUpdateView.layer.borderColor = #colorLiteral(red: 1, green: 0.6235294118, blue: 0, alpha: 1)
        if let firstName = UserDefaults.standard.value(forKey: K.userFirstNameKey) as? String{
            firstNameTextField.text = firstName
        }
        if let lastName = UserDefaults.standard.value(forKey: K.userLastNameKey) as? String{
            lastNameTextField.text = lastName
        }
        if let email = UserDefaults.standard.value(forKey: K.usernameKey) as? String{
            emailLabel.text = email
        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Alert!", message: "Message", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        if let firstName = firstNameTextField.text {
            if !firstName.isName {
                alertController.message = "Your First Name is invalid. Please enter a valid First Name."
                self.present(alertController, animated: true, completion: nil)
                return
            }
            UserDefaults.standard.setValue(firstName, forKey: K.userFirstNameKey)
        }
        if let lastName = lastNameTextField.text{
            if !lastName.isName {
                alertController.message = "Your Last Name is invalid. Please enter a valid Last Name."
                self.present(alertController, animated: true, completion: nil)
                return
            }
            UserDefaults.standard.setValue(lastName, forKey: K.userLastNameKey)
        }
        if let authorization = UserDefaults.standard.value(forKey: K.token) as? String,let firstName = UserDefaults.standard.value(forKey: K.userFirstNameKey) as? String,let lastName = UserDefaults.standard.value(forKey: K.userLastNameKey) as? String{
            APIManager().setProfileInfo(authorization: authorization, firstName: firstName, lastName: lastName) { (result) in
                switch result {
                case .success(_):
                    alertController.message = "Your profile information has been successfully updated!"
                    self.present(alertController, animated: true, completion: nil)
                case .failure(_):
                    alertController.message = "Your profile information could not be updated!"
                    self.present(alertController, animated: true, completion: nil)
                }
            }
            
        }
    }
    
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        UserDefaults.standard.setValue(nil, forKey: K.isGoogleSignedInKey)
        UserDefaults.standard.set(nil, forKey: K.userFirstNameKey)
        UserDefaults.standard.set(nil, forKey: K.userLastNameKey)
        UserDefaults.standard.set(nil, forKey: K.usernameKey)
        UserDefaults.standard.set(nil, forKey: K.userAddressKey)
        UserDefaults.standard.set(nil, forKey: K.userPhoneNumKey)
        UserDefaults.standard.set(false, forKey: K.isLoggedinKey)
        GIDSignIn.sharedInstance().signOut()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func updatePasswordButtonPressed(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "Alert!", message: "Message", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        if let currentPassword = currentPasswordTextField.text {
            if currentPassword.count != 0 {
            if let newPassword = newPasswordTextField.text {
                if newPassword.count != 0 {
                if newPassword.count < 8 || newPassword.count > 20 {
                    alertController.message = "New password must be at least 8 , at most 20 characters in length"
                    self.present(alertController, animated: true, completion: nil)
                    return
                }else if let newPasswordAgain = newPasswordAgainTextField.text{
                    if newPasswordAgain.count != 0 {
                    if newPassword != newPasswordAgain {
                        alertController.message = "Your passwords do not match!"
                        self.present(alertController, animated: true, completion: nil)
                        return
                    }else {
                        
                    }
                }else {
                    alertController.message = "Enter new password again"
                    self.present(alertController, animated: true, completion: nil)
                }
                }
            }else{
                alertController.message = "Enter new password"
                self.present(alertController, animated: true, completion: nil)
            }
            }
        }else {
            alertController.message = "Enter current password"
            self.present(alertController, animated: true, completion: nil)
        }
        }
        
//        if password.count < 8 || password.count > 20 {
//            alertController.message = "Password must be at least 8 , at most 20 characters in length"
//            self.present(alertController, animated: true, completion: nil)
//        }
        
    }
    
    @IBAction func resetPasswordButtonPressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Alert!", message: "Message", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        if let username = UserDefaults.standard.value(forKey: K.usernameKey) as? String{
            if let _ = UserDefaults.standard.value(forKey: K.isGoogleSignedInKey) as? Bool {
                alertController.message = "You cannot reset your password because you are logged in with a Google account!"
                self.present(alertController, animated: true, completion: nil)
            }else {
                APIManager().resetPasswordEmail(username: username) { (result) in
                    switch result{
                    case .success(_):
                        alertController.message = "A mail has been sent to your email, please check it!"
                        self.present(alertController, animated: true, completion: nil)
                    case .failure(_):
                        alertController.message = "There was a problem resetting your password!"
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}

