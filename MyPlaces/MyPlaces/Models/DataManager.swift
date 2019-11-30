//
//  dataManager.swift
//  myPlaces
//
//  Created by Alexey Meleshkevich on 30/10/2019.
//  Copyright © 2019 Alexey Meleshkevich. All rights reserved.
//

import RealmSwift

let realm = try! Realm()

class DataManager {
    static func saveObject(_ place: Place){
        try! realm.write{
            realm.add(place)
        }
    }
    
    static func deleteObject(_ place: Place){
        try! realm.write{
            realm.delete(place)
        }
    }
    
}
