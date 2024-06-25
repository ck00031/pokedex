//
//  PokemonAPI.swift
//  Pokedex
//
//  Created by Alex Wang on 2024/6/22.
//

import Foundation
import Alamofire

protocol PokemonAPIProtocol {
    func getPokemonList(param:Parameters,success:@escaping (_ data:PokemonResponse)->(),failure:@escaping ()->())
    func getPokemonDetail(param:Parameters,success:@escaping (_ data:PokemonDetail)->(),failure:@escaping ()->())
    func getSpecies(param:Parameters,success:@escaping (_ data:SpeciesResponse)->(),failure:@escaping ()->())
    func getEvolutionChain(param:Parameters,success:@escaping (_ data:EvolutionChain)->(),failure:@escaping ()->())
    func getPokemonsByType(param:Parameters,success:@escaping (_ data:PokemonTypeDetail)->(),failure:@escaping ()->())
}

class PokemonAPI:PokemonAPIProtocol {
    public func getPokemonList(param:Parameters,success:@escaping (_ data:PokemonResponse)->(),failure:@escaping ()->()) {
        NetworkManager.sharedInstance.getWithRouterDecodable(Router: PokemonAPIRouter.getPokemonList(parameters: param)) { (status, result, tipString) in
            switch status {
            case .Success:
                if let result = result {
                    do {
                        let pokemonResponse = try JSONDecoder().decode(PokemonResponse.self, from: result)
                        success(pokemonResponse)
                    } catch {
                        print("Error decoding JSON: \(error)")
                        failure()
                    }
                }else{
                    failure()
                }
            case .Failure:
                failure()
            }
        }
    }
    
    public func getPokemonDetail(param:Parameters,success:@escaping (_ data:PokemonDetail)->(),failure:@escaping ()->()) {
        NetworkManager.sharedInstance.getWithRouterDecodable(Router: PokemonAPIRouter.getPokemonDetail(parameters: param)) { (status, result, tipString) in
            switch status {
            case .Success:
                if let result = result {
                    do {
                        let pokemonResponse = try JSONDecoder().decode(PokemonDetail.self, from: result)
                        success(pokemonResponse)
                        return
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                }
                
                failure()
            case .Failure:
                failure()
            }
        }
    }
    
    public func getSpecies(param:Parameters,success:@escaping (_ data:SpeciesResponse)->(),failure:@escaping ()->()) {
        NetworkManager.sharedInstance.getWithRouterDecodable(Router: PokemonAPIRouter.getSpecies(parameters: param)) { (status, result, tipString) in
            switch status {
            case .Success:
                if let result = result {
                    do {
                        let pokemonResponse = try JSONDecoder().decode(SpeciesResponse.self, from: result)
                        success(pokemonResponse)
                        return
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                }
                
                failure()
            case .Failure:
                failure()
            }
        }
    }
    
    public func getEvolutionChain(param:Parameters,success:@escaping (_ data:EvolutionChain)->(),failure:@escaping ()->()) {
        NetworkManager.sharedInstance.getWithRouterDecodable(Router: PokemonAPIRouter.getEvolutionChain(parameters: param)) { (status, result, tipString) in
            switch status {
            case .Success:
                if let result = result {
                    do {
                        let pokemonResponse = try JSONDecoder().decode(EvolutionChain.self, from: result)
                        success(pokemonResponse)
                        return
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                }
                
                failure()
            case .Failure:
                failure()
            }
        }
    }
    
    public func getPokemonsByType(param:Parameters,success:@escaping (_ data:PokemonTypeDetail)->(),failure:@escaping ()->()) {
        NetworkManager.sharedInstance.getWithRouterDecodable(Router: PokemonAPIRouter.getPokemonsByType(parameters: param)) { (status, result, tipString) in
            switch status {
            case .Success:
                if let result = result {
                    do {
                        let pokemonResponse = try JSONDecoder().decode(PokemonTypeDetail.self, from: result)
                        success(pokemonResponse)
                        return
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                }
                
                failure()
            case .Failure:
                failure()
            }
        }
    }
}

