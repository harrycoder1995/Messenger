//
//  FirebaseCollectionReference.swift
//  Messenger
//
//  Created by Harendra Rana on 11/10/23.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

enum FirebaseCollectionReference: String {
    case User
    case Recent
}

func firebaseCollectionReference(_ collectionReference: FirebaseCollectionReference) -> CollectionReference {
    Firestore.firestore().collection(collectionReference.rawValue)
}
