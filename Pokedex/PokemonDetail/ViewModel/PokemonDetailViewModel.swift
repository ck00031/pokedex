//
//  PokemonDetailViewModel.swift
//  Pokedex
//
//  Created by Alex Wang on 2024/6/22.
//

import Foundation

class PokemonDetailViewModel: NSObject {
    fileprivate let dataService: PokemonAPIProtocol
    var dataFetched:(()->())?
    var speciesData:SpeciesResponse?
    var evolutionList: [Species] = []
    var pokemon:Pokemon?
    
    init(with dataService: PokemonAPIProtocol) {
        self.dataService = dataService
        super.init()
    }
    
    func fetchSpecies(pokeID:String) {
        var params:[String : Any] = [:]
        
        params["id"] = pokeID
        
        dataService.getSpecies(param: params, success: {
            [weak self] data in
            let group = DispatchGroup()
            
            group.enter()
            self?.speciesData = data
            if let chainID = Tools.sharedInstance.getPokeID(from: data.evolutionChain.url) {
                self?.fetchEvolutionChain(chainID: chainID)
                group.leave()
            }else{
                group.leave()
            }
            
            group.notify(queue: .main) {
                self?.dataFetched?()
            }
        }, failure: {
            
        })
    }
    
    func fetchEvolutionChain(chainID:String) {
        var params:[String : Any] = [:]
        
        params["id"] = chainID
        
        dataService.getEvolutionChain(param: params, success: {
            [weak self] data in
            guard let self = self else { return }
            
            if data.chain.evolvesTo.count > 0 {
                self.evolutionList.append(data.chain.species)
                for evolution in data.chain.evolvesTo {
                    self.evolutionList.append(evolution.species)
                    self.evolutionList.append(contentsOf: self.getAllEvolutions(from: evolution).map({$0.species}))
                }
            }
            
            self.dataFetched?()
        }, failure: {
            print("failure")
        })
    }
    
    func fetchPokemonDetail(pokeID:String) {
        var params:[String : Any] = [:]
        
        params["id"] = pokeID
        
        dataService.getPokemonDetail(param: params, success: {
            [weak self] data in
            var pokemon = Pokemon(name: data.species.name, url: data.species.url)
            pokemon.favorite = self?.isPokeIDContainsInFavorite(url: data.species.url) ?? false
            pokemon.detail = data
            self?.pokemon = pokemon
            self?.dataFetched?()
        }, failure: {
            
        })
    }
    
    private func getAllEvolutions(from chainLink: ChainLink) -> [ChainLink] {
        var allEvolutions: [ChainLink] = []
        for evolution in chainLink.evolvesTo {
            allEvolutions.append(evolution)
            allEvolutions.append(contentsOf: getAllEvolutions(from: evolution))
        }
        return allEvolutions
    }
}

//MARK: Favorite Pokemons
extension PokemonDetailViewModel {
    func getFavoritePokemons() -> [[String:String]] {
        let defaults = UserDefaults.standard
        if let savedData = defaults.data(forKey: "favoritePokemons") {
            if let decodedPokemons = try? JSONDecoder().decode([[String:String]].self, from: savedData) {
                return decodedPokemons
            }
        }
        return []
    }

    func saveFavoritePokemons(_ favorites: [[String:String]]) {
        let defaults = UserDefaults.standard
        if let encodedData = try? JSONEncoder().encode(favorites) {
            defaults.set(encodedData, forKey: "favoritePokemons")
            defaults.synchronize()
        }
    }

    func favoritePokemon(favorite: Bool) {
        guard let name = pokemon?.detail?.species.name, let url = pokemon?.detail?.species.url else { return }
        let pokeID = Tools.sharedInstance.getPokeID(from: url) ?? ""
        pokemon?.favorite = favorite
        
        var favoritePokemons = getFavoritePokemons()
        
        if favorite {
            // 將寶可夢加入收藏
            if !favoritePokemons.contains(where: { $0["pokeID"] == pokeID }) {
                favoritePokemons.append(["name":name, "pokeID":pokeID])
            }
        } else {
            if let index = favoritePokemons.firstIndex(where: { $0["pokeID"] == pokeID }) {
                favoritePokemons.remove(at: index)
            }
        }
        
        saveFavoritePokemons(favoritePokemons)
        
        self.dataFetched?()
    }
    
    func isPokeIDContainsInFavorite(url:String) -> Bool {
        guard let pokeID = Tools.sharedInstance.getPokeID(from: url) else { return false }
        let favoritePokemons = getFavoritePokemons()
        return favoritePokemons.contains(where: { $0["pokeID"] == pokeID})
    }
}
