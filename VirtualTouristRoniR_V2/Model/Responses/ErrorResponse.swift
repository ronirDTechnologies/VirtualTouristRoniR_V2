//
//  ErrorResponse.swift
//  VIrtualTourist_RoniR
//
//  Created by Roni Rozenblat on 1/28/20.
//  Copyright © 2020 dinatech. All rights reserved.
//
import Foundation


struct ErrorResponse: Codable
{
    let stat: String?
    let code: String?
    let message: String?
}

extension ErrorResponse: LocalizedError
{
    var errorDescription: String?
    {
        return message
    }
    
}
