//
//  Authorization.swift
//  authorization
//
//  Created by Николай Вольников on 20.04.2021.
//

import UIKit
import Firebase

public class Authorization: UIViewController {
    
    @IBOutlet private weak var buttonDescription: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var enterLogin: UITextField!
    @IBOutlet private weak var enterPassword: UITextField!
    @IBOutlet private weak var repeatPassword: UITextField!
    @IBOutlet private weak var button: UIButton!
    
    @IBAction func clickOnButton(_ sender: Any) {
        signUp = !signUp
    }
    
    @IBAction func signOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error)
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(patternImage: UIImage(named: Constants.backGroundImage) ?? UIImage())
        enterLogin.delegate = self
        enterPassword.delegate = self
        repeatPassword.delegate = self
        
        enterPassword.textContentType = .oneTimeCode
        repeatPassword.textContentType = .oneTimeCode
    }
    
    private var signUp: Bool = true {
        willSet {
            if newValue {
                titleLabel.text = Constants.registration
                repeatPassword.isHidden = false
                button.setTitle(Constants.enter, for: .normal)
                buttonDescription.isHidden = false

            } else {
                titleLabel.text = Constants.enter
                repeatPassword.isHidden = true
                button.setTitle(Constants.registration, for: .normal)
                buttonDescription.isHidden = true
            }
        }
    }
    
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Constants.titleAlertAction, style:  .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private enum Constants {
        static let backGroundImage = "backGround.pdf"
        static let titleAlertAction = "OK"
        static let registration = "Регистрация"
        static let enter = "Вход"
        static let alertMessage = "Извините, произошла ошибка"
        static let dataBaseGroup = "users"
        static let email = "email"
        static let password = "password"
        static let successAuthAlert = "Успешная авторизация!"
        static let failureAuthAlert = "Неверные данные"
    }
}

extension Authorization: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let login = enterLogin.text, let pass = enterPassword.text, let repeatPass = repeatPassword.text else {
            showAlert(Constants.alertMessage)
            return true
        }
        if signUp {
            if pass == repeatPass && !pass.isEmpty && !repeatPass.isEmpty && !login.isEmpty {
                Auth.auth().createUser(withEmail: login, password: pass) { (response, error) in
                    if error == nil {
                        if let result = response {
                            let ref = Database.database().reference().child(Constants.dataBaseGroup)
                            ref.child(result.user.uid).updateChildValues([Constants.email : login, Constants.password : pass])
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
        } else if !signUp {
            Auth.auth().signIn(withEmail: login, password: pass) { (response, error) in
                if error == nil {
                    self.dismiss(animated: true, completion: nil)
                    self.showAlert(Constants.successAuthAlert)
                } else {
                    self.showAlert(Constants.failureAuthAlert)
                }
            }
        }
        return true
    }
}
