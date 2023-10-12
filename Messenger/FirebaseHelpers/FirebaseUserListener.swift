//
//  FirebaseUserListener.swift
//  Messenger
//
//  Created by Harendra Rana on 11/10/23.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseAuth

class FirebaseUserListener {
   static let shared = FirebaseUserListener()
    
   private init() {}
    
    //MARK: - LOGIN

    func loginUser(email: String, password: String, completion: @escaping (_ error: Error?, _ isEmailVerified: Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authDataResult, error in
            guard error == nil && authDataResult!.user.isEmailVerified else {
                completion(error,false)
                return
            }
            
            self.fetchUserDetails(userID: authDataResult!.user.uid, email: email)
            completion(error, true)
        }
    }
    //MARK: - REGISTER
    
    func registerUser(email: String, password: String, completion: @escaping (_ error: Error?)->Void) {
        Auth.auth().createUser(withEmail: email, password: password){ authStoreData, error in
            completion(error)
            
            if error == nil {
                authStoreData?.user.sendEmailVerification() { error in
                    print("auth email sent with error:", error?.localizedDescription)
                }
                
                if let authUserData = authStoreData?.user {
                    let user = User(id: authUserData.uid, username: authUserData.email!, email: authUserData.email!, status: "Hey, there I'm using Messenger")
                    
                    //Save User Locally
                    UserDefaults.standard.saveUserData(user)
                    
                    //Save User to firestore
                    self.saveUserToDatabase(user)
                }
            }
        }
    }
    
    //MARK: - RESET PASSWORD
    func resetPasswordFor(email: String, completion: @escaping (_ error: Error?)-> Void) {
        Auth.auth().sendPasswordReset(withEmail: email,completion: completion)
    }
    
    //MARK: - RESEND VERIFICATION EMAIL
    func resendVerificationEmail(completion: @escaping (_ error: Error?)->Void) {
        Auth.auth().currentUser?.reload(completion: { _ in
            Auth.auth().currentUser?.sendEmailVerification() { error in
                completion(error)
            }
        })
    }
    
    //MARK: - Helper Methods
    
    func getCurrentId() -> String? {
        Auth.auth().currentUser?.uid
    }
    
    func getCurrentUser() -> User? {
        guard Auth.auth().currentUser != nil else {
            return nil
        }
        
        return UserDefaults.standard.getUserData()
    }
    
    func saveUserToDatabase(_ user: User) {
        do{
            try firebaseCollectionReference(.User).document(user.id).setData(from: user)
        }catch {
            print("Error occurred while saving data to Firestore:", error.localizedDescription)
        }
    }
    
    func fetchUserDetails(userID: String, email: String? = nil) {
        firebaseCollectionReference(.User).document(userID).getDocument { querySnapshot, error in
            guard let document = querySnapshot else {
                print(#function,"No document found for user")
                return
            }
            
            let result = Result {
                try? document.data(as: User.self)
            }
            
            switch result {
            case .success(let userObject):
                if let user = userObject {
                    UserDefaults.standard.saveUserData(user)
                } else {
                    print(#function,"Document does not exist.")
                }
            case .failure(let failure):
                print(#function,"Error decoding user : \(failure)")
            }
        }
    }
}
