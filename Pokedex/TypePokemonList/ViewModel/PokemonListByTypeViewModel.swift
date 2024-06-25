//
//  PokemonListByTypeViewModel.swift
//  Pokedex
//
//  Created by Alex Wang on 2024/6/25.
//

import Foundation

class PokemonListByTypeViewModel: NSObject {
    fileprivate let dataService: PokemonAPIProtocol
    var dataFetched:(()->())?
    var pokemons:[Pokemon] = []
    
    init(with dataService: PokemonAPIProtocol) {
        self.dataService = dataService
        super.init()
    }
    
    func fetchPokemonByType(typeID:String) {
        var params:[String : Any] = [:]
        
        params["id"] = typeID
        dataService.getPokemonsByType(param: params, success: {
            [weak self] data in
            let group = DispatchGroup()
            
            for item in data.pokemon {
                group.enter()
                
                var pokemon = Pokemon.init(name: item.pokemon.name, url: item.pokemon.url)
                pokemon.favorite = self?.isPokeIDContainsInFavorite(url: item.pokemon.url) ?? false
                
                if let pokeID = Tools.sharedInstance.getPokeID(from: item.pokemon.url) {
                    pokemon.pokeID = pokeID
                    self?.fetchPokemonDetail(pokeID: pokeID, completion: {
                        detail in
                        pokemon.detail = detail
                        self?.pokemons.append(pokemon)
                        group.leave()
                    })
                }else{
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                self?.dataFetched?()
            }
        }, failure: {
            
        })
    }
    
    private func fetchPokemonDetail(pokeID:String, completion: @escaping (PokemonDetail?) -> Void) {
        var params:[String : Any] = [:]
        
        params["id"] = pokeID
        
        dataService.getPokemonDetail(param: params, success: {
            data in
            completion(data)
        }, failure: {
            completion(nil)
        })
    }
}

//MARK: Favorite Pokemons
extension PokemonListByTypeViewModel {
    //get favorite pokemons from userdefaults
    func getFavoritePokemons() -> [[String:String]] {
        let defaults = UserDefaults.standard
        if let savedData = defaults.data(forKey: "favoritePokemons") {
            if let decodedPokemons = try? JSONDecoder().decode([[String:String]].self, from: savedData) {
                return decodedPokemons.sorted {
                    guard let id1 = $0["pokeID"], let id2 = $1["pokeID"], let intID1 = Int(id1), let intID2 = Int(id2) else {
                        return false
                    }
                    return intID1 < intID2
                }
            }
        }
        return []
    }

    //save favorite pokemons to userdefaults
    func saveFavoritePokemons(_ favorites: [[String:String]]) {
        let defaults = UserDefaults.standard
        if let encodedData = try? JSONEncoder().encode(favorites) {
            defaults.set(encodedData, forKey: "favoritePokemons")
            defaults.synchronize()
        }
    }

    func favoritePokemon(favorite: Bool, indexPath: IndexPath) {
        var pokemon = pokemons[indexPath.row]
        
        var favoritePokemons = getFavoritePokemons()
        
        var pokeID = pokemon.pokeID
        if pokeID.isEmpty {
            guard let id = Tools.sharedInstance.getPokeID(from: pokemon.url) else { return }
            pokeID = id
        }
        
        if pokeID.isEmpty { return }

        pokemon.favorite = favorite
        pokemons[indexPath.row] = pokemon
        
        if favorite {
            //add pokeID to favorite
            if !favoritePokemons.contains(where: { $0["name"] == pokemon.name }) {
                favoritePokemons.append(["name":pokemon.name,"pokeID":pokeID])
            }
        } else {
            //remove pokeID from favorite
            if let index = favoritePokemons.firstIndex(where: {$0["name"] == pokemon.name }) {
                favoritePokemons.remove(at: index)
            }
        }
        
        saveFavoritePokemons(favoritePokemons)
        
        self.dataFetched?()
    }
    
    func isPokeIDContainsInFavorite(url:String) -> Bool {
        guard let pokeID = Tools.sharedInstance.getPokeID(from: url) else { return false }
        let favoritePokemons = getFavoritePokemons()
        return favoritePokemons.contains(where: { $0["pokeID"] == pokeID })
    }
    
    func updateFavoriteStatus(indexPaths:[IndexPath]) {
        if indexPaths.isEmpty { return }
        
        for index in indexPaths {
            var pokemon = pokemons[index.row]
            pokemon.favorite = isPokeIDContainsInFavorite(url: pokemon.url)
            pokemons[index.row] = pokemon
        }
        
        self.dataFetched?()
    }
}
