//
//  Expense.swift
//  Ice Cream
//
//  Created by Bethany on 2025/3/5.
//

import SwiftData
import Foundation

//This page will save data inputted by the user on the Budget page
@Model
class Expense {
    @Attribute(.unique) var id: UUID //unique ID for each entry on Budget page
    var name: String
    var cost: Double //takes in integers with decimals
    var dateCreated: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        cost: Double
    )
    {
        self.id = id
        self.name = name
        self.cost = cost
        self.dateCreated = Date()
    }
}
