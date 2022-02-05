//
//  Photo.swift
//  VIrtualTourist_RoniR
//
//  Created by Roni Rozenblat on 2/7/20.
//  Copyright © 2020 dinatech. All rights reserved.
//
import Foundation
struct Photo: Codable {
    let id: String
    let urlT: String

    enum CodingKeys: String, CodingKey {
    case id = "id"
    case urlT = "url_t"
        
    }
}
