//
//  MainViewController.swift
//  WebAuthn_iOS_Demo
//
//  Created by Leo Ho on 2022/5/30.
//

import UIKit
import Auth0

class MainViewController: BaseViewController {
    
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordlessButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    var passwordLessCode: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func registerBtnClicked(_ sender: UIButton) {
        Task {
            await startRegisterWithAuth0()
        }
    }
    
    @IBAction func loginBtnClicked(_ sender: UIButton) {
        Task {
            await startLoginWithAuth0()
        }
    }
    
    @IBAction func passwordlessBtnClicked(_ sender: UIButton) {
        Task {
            await startPasswordLessWithAuth0(finish: {
                self.showAlertWithOneTextField(vc: self) { textField in
                    textField.keyboardType = .numberPad
                    textField.placeholder = "Please Input Verify Code in Your Email"
                } completionHandler: { textField in
                    Task {
                        await self.startPasswordLessLoginWithAuth0(passwordLessCode: textField.text!)
                    }
                }
            })
        }
    }
    
    @IBAction func logOutBtnClicked(_ sender: UIButton) {
        Task {
            await startLogOutWithAuth0()
        }
    }
    
    func startRegisterWithAuth0() async {
        do {
            let credentials = try await Auth0
                .webAuth()
                .parameters(["screen_hint": "signup"])
                .start({ result in
                    switch result {
                    case .success(let credentials):
                        print("Register Obtained credentials: \(credentials)")
                    case .failure(let error):
                        print("Failed with: \(error)")
                    }
                })
        } catch {
            print("Register Failed with: \(error)")
        }
    }
    
    func startLoginWithAuth0() async {
        do {
            let credentials = try await Auth0
                .webAuth()
                .start()
            print("Login Obtained credentials: \(credentials)")
        } catch {
            print("Login Failed with: \(error)")
        }
    }
    
    func startPasswordLessWithAuth0(finish: @escaping(() -> Void)) async {
        do {
            try await Auth0
                .authentication()
                .startPasswordless(email: "leo160918@gmail.com", type: .code, connection: "email")
                .start()
            print("Code Sent")
            finish()
        } catch {
            print("Failed with: \(error)")
        }
    }
    
    func startPasswordLessLoginWithAuth0(passwordLessCode verifyCode: String) async {
        do {
            let credentials = try await Auth0
                .authentication()
                .login(email: "leo160918@gmail.com", code: verifyCode)
                .start()
            print("Passwordless Login Obtained credentials: \(credentials)")
        } catch {
            print("Passwordless Login Failed with: \(error)")
        }
    }
    
    func startLogOutWithAuth0() async {
        do {
           try await Auth0
                .webAuth()
                .clearSession(federated: true)
            print("Session cookie cleared")
            // Delete credentials
        } catch {
            print("LogOut Failed with: \(error)")
        }
    }
    
    func showAlertWithOneTextField(vc: UIViewController, textFieldSet: ((UITextField) -> Void)?, completionHandler: ((UITextField) -> Void)?) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Input Verify Code", message: nil, preferredStyle: .alert)
            alertController.addTextField { textField in
                textFieldSet?(textField)
            }
            let confirmAction = UIAlertAction(title: "Confirm", style: .default) { action in
                let textField = (alertController.textFields?.first)! as UITextField
                completionHandler?(textField)
            }
            alertController.addAction(confirmAction)
            vc.present(alertController, animated: true, completion: nil)
        }
    }

}
