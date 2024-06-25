//
//  PokemonModel.swift
//  Pokedex
//
//  Created by Alex Wang on 2024/6/21.
//

import Foundation
import UIKit

struct PokemonResponse: Hashable, Codable {
    var results: [Pokemon]
    var next:String?
    
    enum CodingKeys: String, CodingKey {
        case results
        case next
    }
}

struct Pokemon: Hashable, Codable {
    var name: String
    var url: String
    var favorite: Bool = false
    var pokeID: String = ""
    var detail: PokemonDetail?
    
    enum CodingKeys: String, CodingKey {
        case name
        case url
    }
}

struct PokemonDetail: Hashable, Codable {
    let id: Int
    let name: String
    let sprites: Sprites
    let types: [TypeElement]
    let species:Species
//    var favorite: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case sprites
        case types
        case species
    }
}

struct Sprites: Hashable, Codable {
    let front_default: String
    let other: SpritesOther
}

struct Species: Hashable, Codable {
    let name:String
    let url:String
}

struct SpritesOther: Hashable, Codable {
    let officialArtwork: OfficialArtwork
    
    enum CodingKeys: String, CodingKey {
        case officialArtwork = "official-artwork"
    }
}

struct OfficialArtwork: Hashable, Codable {
    let frontDefault: String
    
    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
    }
}

struct TypeElement: Hashable, Codable {
    let type: TypeInfo
}

struct TypeInfo: Hashable, Codable {
    let name: String
    let url: String
}

struct SpeciesResponse: Hashable, Codable {
    let flavorTextEntries:[FlavorText]
    let evolutionChain: SpeciesEvolutionChain
    let id: Int
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case flavorTextEntries = "flavor_text_entries"
        case evolutionChain = "evolution_chain"
        case id
        case name
    }
}

struct SpeciesEvolutionChain: Hashable, Codable {
    let url: String
}

struct FlavorText: Hashable, Codable {
    let flavorText:String
    
    enum CodingKeys: String, CodingKey {
        case flavorText = "flavor_text"
    }
}

struct EvolutionChain: Hashable, Codable {
//    let babyTriggerItem: String?
    let chain: ChainLink
    let id: Int

    enum CodingKeys: String, CodingKey {
//        case babyTriggerItem = "baby_trigger_item"
        case chain
        case id
    }
}

struct ChainLink: Hashable, Codable {
    let evolvesTo: [ChainLink]
    let species: Species

    enum CodingKeys: String, CodingKey {
        case evolvesTo = "evolves_to"
        case species
    }
}

struct PokemonTypeDetail: Hashable, Codable {
    let pokemon: [TypePokemon]
}

struct TypePokemon: Hashable, Codable {
    let pokemon: Species
}

//struct NamedAPIResource: Hashable, Codable {
//    let name: String
//    let url: String
//}

enum TypeColor:String, CaseIterable {
    case normal = "9FA19F"
    case fighting = "FF8000"
    case flying = "81B9EF"
    case poison = "9141CB"
    case ground = "915121"
    case rock = "AFA981"
    case bug = "91A119"
    case ghost = "704170"
    case steel = "60A1B8"
    case fire = "E62829"
    case water = "2980EF"
    case grass = "3FA129"
    case electric = "FAC000"
    case psychic = "EF4179"
    case ice = "3DCEF3"
    case dark = "624D4E"
    case fairy = "EF70EF"
    case stellar = "40B5A5"
    case unknown = "68A090"
    
    var color: UIColor {
        return UIColor(hexString: self.rawValue)
    }
    
    static func color(for typeName: String) -> UIColor? {
        if let type = TypeColor.allCases.first(where: { "\($0)" == typeName }) {
            return type.color
        }
        return nil
    }
}
