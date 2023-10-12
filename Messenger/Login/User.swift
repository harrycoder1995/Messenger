//
//  User.swift
//  Messenger
//
//  Created by Harendra Rana on 11/10/23.
//

import Foundation

struct User: Codable, Equatable {
    var id = ""
    var username: String
    var email: String
    var pushId = ""
    var avatarLink = ""
    var status: String
}
