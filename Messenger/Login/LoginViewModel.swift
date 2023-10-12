//
//  LoginViewModel.swift
//  Messenger
//
//  Created by Harendra Rana on 11/10/23.
//

import Foundation

protocol LoginViewModelDelegate: AnyObject {
    func showError(_ errorMessage: String)
    func handleSuccess(message: String)
    func enableResendEmail()
}

class LoginViewModel {
    
    weak var delegate: LoginViewModelDelegate?
    
    //MARK: - VALIDATION
    
    private func validateUserData(value: String) -> Bool {
        value != ""
    }
    
    private func validateRegistrationDetails(email: String, password: String, confirmPassword: String) -> Bool {
        guard validateUserData(value: email) && validateUserData(value: password) && validateUserData(value: confirmPassword) else {
            delegate?.showError("Mandatory Fields cannot be empty")
            return false
        }
        
        guard password == confirmPassword else {
            delegate?.showError("Password Mismatch!!")
            return false
        }
        
        return true
    }
    
    private func validateLoginDetails(email: String, password: String) -> Bool {
        guard validateUserData(value: email) && validateUserData(value: password) else {
            delegate?.showError("Mandatory Fields cannot be empty")
            return false
        }
        
        return true
    }
    
    
    //MARK: - LOGIN
    func loginUser(email: String, password: String) {
        guard validateLoginDetails(email: email, password: password) else {
            return
        }
        
        FirebaseUserListener.shared.loginUser(email: email, password: password) { error, isEmailVerified in
            guard error == nil else {
                self.delegate?.showError(error!.localizedDescription)
                return
            }
            
            if isEmailVerified {
                self.delegate?.handleSuccess(message: "User has logged in with: \(self.getCurrentUser()!.username)")
            } else {
                self.delegate?.showError("Please verify your email")
                self.delegate?.enableResendEmail()
            }
        }
    }
    
    //MARK: - REGISTER
    func registerUser(email: String, password: String, confirmPassword: String) {
        guard validateRegistrationDetails(email: email, password: password, confirmPassword: confirmPassword) else {
            return
        }
        
        FirebaseUserListener.shared.registerUser(email: email, password: password) { error in
            if error == nil {
                self.delegate?.handleSuccess(message: "Confirmation email has been sent to the registered email.")
                self.delegate?.enableResendEmail()
            }else {
                self.delegate?.showError(error?.localizedDescription ?? "")
            }
        }
        
    }
    
    //MARK: - RESET PASSWORD
    func resetPasswordFor(email: String) {
        guard validateUserData(value: email) else {
            self.delegate?.showError("Email required for reset password.")
            return
        }
        FirebaseUserListener.shared.resetPasswordFor(email: email) { error in
            if error == nil {
                self.delegate?.handleSuccess(message: "Reset Password Link has been sent to registered email.")
            } else {
                self.delegate?.showError(error!.localizedDescription)
            }
        }
    }
    
    //MARK: - RESEND VERIFICATION EMAIL
    func resendVerificationMail() {
        FirebaseUserListener.shared.resendVerificationEmail { error in
            if error == nil {
                self.delegate?.handleSuccess(message: "Reset Password Link has been sent to registered email.")
            } else {
                self.delegate?.showError(error!.localizedDescription)
            }
        }
    }
    
    //MARK: - Helper Methods
    
    func getCurrentUser() -> User? {
        FirebaseUserListener.shared.getCurrentUser()
    }
    
}
