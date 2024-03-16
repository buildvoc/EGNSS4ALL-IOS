//
//  Photo.swift
//  EGNSS4ALL
//
//  Created by Mayur Shrivas on 14/03/24.
//

import Foundation

struct Photo: Decodable {
    var note: String// – photo note
    var lat: String?// – photo lattitude
    var lng: String?// – photo longitude
    var photo_heading: String?// – heading in degrees
    var created: String
    var photo: String?// – base64 encoded photo
    var digest: String// – photo hash
}
