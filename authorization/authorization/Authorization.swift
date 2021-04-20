//
//  Authorization.swift
//  authorization
//
//  Created by Николай Вольников on 20.04.2021.
//

import UIKit
import Firebase

class Authorization: UIViewController {
    
    var signUp: Bool = true {
        willSet {
            if newValue {
                titleLabel.text = "Регистрация"
                repeatPassword.isHidden = false
                button.setTitle("Войти", for: .normal)
                buttonDescription.isHidden = false

            } else {
                titleLabel.text = "Вход"
                repeatPassword.isHidden = true
                button.setTitle("Регистрация", for: .normal)
                buttonDescription.isHidden = true
            }
        }
    }
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(patternImage: UIImage(named: Constants.backGroundImage) ?? UIImage())
        enterLogin.delegate = self
        enterPassword.delegate = self
        repeatPassword.delegate = self

    }
    
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style:  .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private enum Constants {
        static let backGroundImage = "backGround.pdf"
    }
}

extension Authorization: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let login = enterLogin.text, let pass = enterPassword.text, let repeatPass = repeatPassword.text else {
            showAlert("Случилось страшное!")
            return true
        }
        
        if pass == repeatPass && !pass.isEmpty && !repeatPass.isEmpty && !login.isEmpty {
            Auth.auth().createUser(withEmail: login, password: pass) { (response, error) in
                if error == nil {
                    if let result = response {
                        print(result.user.uid)
                        let ref = Database.database().reference().child("users")
                        ref.child(result.user.uid).updateChildValues(["name" : login, "password" : pass])
                    }
                }
            }
        } else {
            showAlert("Заполните все поля!")
        }
        return true
    }
}
