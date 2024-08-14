//
//  Answer.swift
//  PIC2BIM
//
//  Created by DREAMWORLD on 12/08/24.
//

import Foundation

struct Answer: Decodable {
    var status: String
    var error_msg: String?
    var photos_ids: [String]
}
