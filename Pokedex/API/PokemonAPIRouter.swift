//
//  PokemonAPIRouter.swift
//  Pokedex
//
//  Created by Alex Wang on 2024/6/22.
//

import Alamofire

enum PokemonAPIRouter: URLRequestConvertible {
    case getPokemonList(parameters:Parameters)
    case getPokemonDetail(parameters:Parameters)
    case getSpecies(parameters:Parameters)
    case getEvolutionChain(parameters:Parameters)
    case getPokemonsByType(parameters:Parameters)
    
    var method: HTTPMethod {
        switch self {
        default:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .getPokemonList:
            return "pokemon"
        case .getPokemonDetail(let params):
            if let pokeID = params["id"] as? String {
                return "pokemon/\(pokeID)"
            }
            
            return ""
        case .getSpecies(let params):
            if let pokeID = params["id"] as? String {
                return "pokemon-species/\(pokeID)"
            }
            
            return ""
        case .getEvolutionChain(let params):
            if let pokeID = params["id"] as? String {
                return "evolution-chain/\(pokeID)"
            }
            
            return ""
        case .getPokemonsByType(let params):
            if let typeID = params["id"] as? String {
                return "type/\(typeID)"
            }
            
            return ""
        }
    }
    
    var baseUrl: String{
        return "https://pokeapi.co/api/v2/"
    }
    
    // MARK: URLRequestConvertible
    func asURLRequest() throws -> URLRequest {
        let url = try baseUrl.asURL()
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        
//        switch self {
//        case .getPokemonDetail:
//            urlRequest = try URLEncoding.default.encode(urlRequest, with: nil)
//        case .getPokemonList(let params):
//            urlRequest = try URLEncoding.default.encode(urlRequest, with: params)
//        case .getSpecies:
//            urlRequest = try URLEncoding.default.encode(urlRequest, with: nil)
//        case .getEvolutionChain:
//            urlRequest = try URLEncoding.default.encode(urlRequest, with: nil)
//        case .getPokemonsByType:
//            urlRequest = try URLEncoding.default.encode(urlRequest, with: nil)
//        }
        
        switch self {
        case .getPokemonList(let params):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: params)
        default:
            urlRequest = try URLEncoding.default.encode(urlRequest, with: nil)
        }
        
        return urlRequest
    }
}
