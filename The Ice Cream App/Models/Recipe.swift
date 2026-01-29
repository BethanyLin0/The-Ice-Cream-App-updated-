//
//  Recipe.swift
//  Ice Cream
//
//  Created by Bethany on 2025/3/5.
//

import SwiftData
import Foundation //Since UUID and Date are part of the Foundation framework, importing Foundation is required to use these types in the Recipe class definition.

//This page will save data inputted by the user on the Recipes page
@Model
class Recipe {
    @Attribute(.unique) var id: UUID //unique ID for each entry on Recipes page
    var name: String
    var ingredients: String
    var lastMade: Date // Changed from String to Date
    var tutorialLink: String
    var notes: String
    var dateCreated: Date

    init(
        id: UUID = UUID(),
        name: String,
        ingredients: String,
        lastMade: Date = .now,
        tutorialLink: String = "",
        notes: String = "")
    {
        self.id = id
        self.name = name
        self.ingredients = ingredients
        self.lastMade = lastMade
        self.tutorialLink = tutorialLink
        self.notes = notes
        self.dateCreated = Date()
    }
}

