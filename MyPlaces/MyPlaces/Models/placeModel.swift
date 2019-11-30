//
//  placeModel.swift
//  myPlaces
//
//  Created by Alexey Meleshkevich on 23/10/2019.
//  Copyright © 2019 Alexey Meleshkevich. All rights reserved.
//

import RealmSwift

@objcMembers
class Place: Object {
    
    dynamic var name = ""
    dynamic var location: String?
    dynamic var type: String?
    dynamic var imageData: Data?
    dynamic var date = Date()
    dynamic var rating = 0.0
    
    convenience init(name: String, location: String?, type: String?, imageData: Data?, rating: Double){
        self.init()
        self.name = name
        self.location = location
        self.type = type
        self.imageData = imageData
        self.rating = rating
    }
}

