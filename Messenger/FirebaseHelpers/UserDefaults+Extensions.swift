//
//  UserDefaults+Extensions.swift
//  Messenger
//
//  Created by Harendra Rana on 12/10/23.
//

import Foundation

extension UserDefaults {
    func saveUserData(_ user: User) {
        let encoder = JSONEncoder()
        
        do {
            let encodedData = try encoder.encode(user)
            setValue(encodedData, forKey: kCurrentUser)
        }catch {
            print("Error while saving data to User Defaults:", error.localizedDescription)
        }
    }
    
    func getUserData() -> User? {
        guard let userData = data(forKey: kCurrentUser) else {
            return nil
        }
        
        let decoder = JSONDecoder()
        
        do {
            let parsedData = try decoder.decode(User.self, from: userData)
            return parsedData
        }catch {
            print(error.localizedDescription)
        }
        
        return nil
    }
}
