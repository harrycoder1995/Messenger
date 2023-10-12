//
//  ViewController.swift
//  Messenger
//
//  Created by Harendra Rana on 03/10/23.
//

import UIKit
import ProgressHUD

class LoginViewController: UIViewController {
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordLabel: UILabel!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var resendEmailButton: UIButton!
    
    private var isLogin = true
    
    private var viewModel = LoginViewModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        setUpUI()
        
        viewModel.delegate = self
    }
    
    //MARK: - SetUp
    
    private func setUpUI() {
        resendEmailButton.isHidden = true
        confirmPasswordLabel.isHidden = true
        confirmPasswordTextField.isHidden = true
        
        bottomLabel.isUserInteractionEnabled = true
        bottomLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleLabelTap)))
        
        setUpContinueButton()
        setUpBottomLabel()
        setUpTextFields()
        addTapGesture()
    }
    
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setUpTextFields() {
        emailTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        confirmPasswordTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        updateTextFieldPlaceholder(textField)
    }
    
    private func updateTextFieldPlaceholder(_ textField: UITextField) {
        switch textField {
        case emailTextField:
            emailLabel.text = textField.hasText ? "Email" : ""
        case passwordTextField:
            passwordLabel.text = textField.hasText ? "Password" : ""
        default :
            confirmPasswordLabel.text = textField.hasText ? "Confirm Password" : ""
        }
    }
    
    private func updateUIFor() {
        let loginButtonTitle = isLogin ? "LOGIN" : "SIGN UP"
        loginButton.setTitle(loginButtonTitle, for: .normal)
        
        setUpBottomLabel()
        
        UIView.animate(withDuration: 0.5) {
            self.confirmPasswordLabel.isHidden = self.isLogin
            self.confirmPasswordTextField.isHidden = self.isLogin
        }
    }
    
    private func setUpContinueButton() {
        loginButton.layer.cornerRadius = 15
    }
    
    private func setUpBottomLabel() {
        let termsAndConditionText = isLogin ? "Don't have an account? Sign Up" : "Have an Account? Log In"
        let range = (termsAndConditionText as NSString).range(of: isLogin ? "Sign Up" : "Log In")
        
        let attributedText = NSMutableAttributedString(string: termsAndConditionText)
        attributedText.addAttributes(
            [.foregroundColor : UIColor(hex: "#635ff6ff")],
            range: range
        )
        
        bottomLabel.attributedText = attributedText
        
    }
    
    func loginUser() {
        viewModel.loginUser(email: emailTextField.text ?? "", password: passwordTextField.text ?? "")
    }
    
    func registerUser() {
        viewModel.registerUser(email: emailTextField.text ?? "", password: passwordTextField.text ?? "", confirmPassword:  confirmPasswordTextField.text ?? "")
    }
    
    
    //MARK: - ACTIONS
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        isLogin ? loginUser() : registerUser()
    }
    
    @IBAction func forgotPasswordPressed(_ sender: UIButton) {
        viewModel.resetPasswordFor(email: emailTextField.text ?? "")
    }
    
    @IBAction func resendButtonPressed(_ sender: UIButton) {
        viewModel.resendVerificationMail()
    }
    
    @objc private func handleLabelTap() {
        isLogin = !isLogin
        updateUIFor()
    }
    
    @objc private func handleBackgroundTap() {
        view.endEditing(true)
    }
}

extension LoginViewController: LoginViewModelDelegate {
    func showError(_ errorMessage: String) {
        ProgressHUD.showError(errorMessage)
    }
    
    func handleSuccess(message: String) {
        ProgressHUD.showSuccess(message)
    }
    
    func enableResendEmail() {
        resendEmailButton.isHidden = false
    }
}

