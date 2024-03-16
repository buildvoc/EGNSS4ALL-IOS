//
//  Task.swift
//  EGNSS4ALL
//
//  Created by Mayur Shrivas on 14/03/24.
//

import Foundation

struct Task: Decodable {
    var id: String
    var status: String
    var name: String?
    var text: String?
    var number_of_photos: String?
    var text_returned: String?
    var date_created: String
    var task_due_date: String
    var note: String?
    var photos_ids: [String] = []
}
