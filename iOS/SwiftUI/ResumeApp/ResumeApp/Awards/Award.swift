//
//  Award.swift
//  ResumeApp
//
//  Created by Cory Steers on 11/7/23.
//

import Foundation

/// A description of a prize that can be awarded if the user meets the criiteria
struct Award: Decodable, Identifiable {
    var id: String { name }
    var name: String
    var description: String
    var color: String
    var criterion: String
    var value: Int
    var image: String

    static let allAwards = Bundle.main.decode("Awards.json", as: [Award].self)
    static let example = allAwards[0]
}
