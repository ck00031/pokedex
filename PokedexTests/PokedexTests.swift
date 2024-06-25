//
//  PokedexTests.swift
//  PokedexTests
//
//  Created by Alex Wang on 2024/6/21.
//

import XCTest
import Alamofire
@testable import Pokedex

class MockPokemonAPI: PokemonAPIProtocol {
    func getPokemonList(param: Parameters, success: @escaping (PokemonResponse) -> (), failure: @escaping () -> ()) {
        let pokemons = [
            Pokemon(name: "bulbasaur", url: "https://pokeapi.co/api/v2/pokemon/1/"),
            Pokemon(name: "ivysaur", url: "https://pokeapi.co/api/v2/pokemon/2/")
        ]
        let response = PokemonResponse(results: pokemons, next: nil)
        success(response)
    }
    
    func getPokemonDetail(param: Parameters, success: @escaping (PokemonDetail) -> (), failure: @escaping () -> ()) {
        let detail = PokemonDetail(id: 1, name: "bulbasaur", sprites: Sprites(front_default: "url", other: SpritesOther(officialArtwork: OfficialArtwork(frontDefault: "url"))), types: [TypeElement(type: TypeInfo(name: "grass", url: ""))], species: Species(name: "bulbasaur", url: ""))
        success(detail)
    }
    
    func getSpecies(param: Parameters, success: @escaping (SpeciesResponse) -> (), failure: @escaping () -> ()) {
        let speciesResponse = SpeciesResponse(flavorTextEntries: [FlavorText(flavorText: "Bulbasaur is a grass type")], evolutionChain: SpeciesEvolutionChain(url: "https://pokeapi.co/api/v2/evolution-chain/1/"), id: 1, name: "bulbasaur")
        success(speciesResponse)
    }
    
    func getEvolutionChain(param: Parameters, success: @escaping (EvolutionChain) -> (), failure: @escaping () -> ()) {
        let chainLink = ChainLink(evolvesTo: [ChainLink(evolvesTo: [], species: Species(name: "ivysaur", url: ""))], species: Species(name: "bulbasaur", url: ""))
        let evolutionChain = EvolutionChain(chain: chainLink, id: 1)
        success(evolutionChain)
    }
    
    func getPokemonsByType(param: Parameters, success: @escaping (PokemonTypeDetail) -> (), failure: @escaping () -> ()) {
        let typeDetail = PokemonTypeDetail(pokemon: [TypePokemon(pokemon: Species(name: "bulbasaur", url: "https://pokeapi.co/api/v2/pokemon-species/1"))])
        success(typeDetail)
    }
}

class ToolsTests: XCTestCase {
    let tools = Tools.sharedInstance
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testGetPokeID() {
        let url1 = "https://pokeapi.co/api/v2/pokemon/1"
        let url2 = "https://pokeapi.co/api/v2/pokemon/25"
        let url3 = "https://pokeapi.co/api/v2/pokemon/150"
        let url4 = "https://pokeapi.co/api/v2/pokemon-species/1"
        let url5 = "https://pokeapi.co/api/v2/pokemon-species/25"
        let url6 = "https://pokeapi.co/api/v2/pokemon-species/150"
        let url7 = "https://pokeapi.co/api/v2/ability/1"
        let url8 = "https://pokeapi.co/api/v2/ability/150"
        let url9 = "https://pokeapi.co/api/v2/evolution-chain/1"
        let url10 = "https://pokeapi.co/api/v2/type/146"
        
        XCTAssertEqual(tools.getPokeID(from: url1), "1")
        XCTAssertEqual(tools.getPokeID(from: url2), "25")
        XCTAssertEqual(tools.getPokeID(from: url3), "150")
        XCTAssertEqual(tools.getPokeID(from: url4), "1")
        XCTAssertEqual(tools.getPokeID(from: url5), "25")
        XCTAssertEqual(tools.getPokeID(from: url6), "150")
        XCTAssertEqual(tools.getPokeID(from: url7), "1")
        XCTAssertEqual(tools.getPokeID(from: url8), "150")
        XCTAssertEqual(tools.getPokeID(from: url9), "1")
        XCTAssertEqual(tools.getPokeID(from: url10), "146")
    }
}

class PokemonsViewModelTests: XCTestCase {
    var viewModel: PokemonsViewModel!
    var mockAPI: MockPokemonAPI!
    
    override func setUp() {
        super.setUp()
        mockAPI = MockPokemonAPI()
        viewModel = PokemonsViewModel(with: mockAPI)
    }
    
    override func tearDown() {
        viewModel = nil
        mockAPI = nil
        super.tearDown()
    }
    
    func testFetchPokemons() {
        let expectation = self.expectation(description: "Data fetched")
        viewModel.dataFetched = {
            expectation.fulfill()
        }
        viewModel.fetchPokemons()
        
        waitForExpectations(timeout: 5, handler: {
            error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        })
        
        XCTAssertEqual(viewModel.pokemons.count, 2)
    }
    
    func testFetchFavoritePokemons() {
        let favoritePokemons = [["name": "bulbasaur", "pokeID": "1"]]
        
        let defaults = UserDefaults.standard
        if let encodedData = try? JSONEncoder().encode(favoritePokemons) {
            defaults.set(encodedData, forKey: "favoritePokemons")
            defaults.synchronize()
        }
        
        viewModel.fetchFavoritePokemons()
        
        XCTAssertEqual(viewModel.pokemons.count, 1)
        XCTAssertEqual(viewModel.pokemons.first?.name, "bulbasaur")
        XCTAssertNotEqual(viewModel.pokemons.first?.name, "Pikachiu")
    }
    
    func testFavoritePokemon() {
        let indexPath = IndexPath(row: 0, section: 0)
        
        viewModel.pokemons = [
            Pokemon(name: "bulbasaur", url: "https://pokeapi.co/api/v2/pokemon/1/", favorite: false)
        ]
        
        viewModel.favoritePokemon(favorite: true, indexPath: indexPath)
        XCTAssertTrue(viewModel.pokemons[indexPath.row].favorite)
        
        viewModel.favoritePokemon(favorite: false, indexPath: indexPath)
        XCTAssertFalse(viewModel.pokemons[indexPath.row].favorite)
    }
    
    func testUpdateFavoriteStatus() {
        let indexPath = IndexPath(row: 0, section: 0)
        
        viewModel.pokemons = [
            Pokemon(name: "bulbasaur", url: "https://pokeapi.co/api/v2/pokemon/1/")
        ]
        
        let favoritePokemons = [["name": "bulbasaur", "pokeID": "1"]]
        
        let defaults = UserDefaults.standard
        if let encodedData = try? JSONEncoder().encode(favoritePokemons) {
            defaults.set(encodedData, forKey: "favoritePokemons")
            defaults.synchronize()
        }
        
        viewModel.updateFavoriteStatus(indexPaths: [indexPath])
        
        XCTAssertTrue(viewModel.pokemons[indexPath.row].favorite)
    }
    
    func testFetchSpecies() {
        let expectation = self.expectation(description: "Species fetched")
        
        mockAPI.getSpecies(param: [:], success: { species in
            XCTAssertEqual(species.name, "bulbasaur")
            expectation.fulfill()
        }, failure: {
            XCTFail("Failed to fetch species")
        })
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testFetchEvolutionChain() {
        let expectation = self.expectation(description: "Evolution chain fetched")
        
        mockAPI.getEvolutionChain(param: [:], success: { chain in
            XCTAssertEqual(chain.chain.species.name, "bulbasaur")
            expectation.fulfill()
        }, failure: {
            XCTFail("Failed to fetch evolution chain")
        })
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testFetchPokemonsByType() {
        let expectation = self.expectation(description: "Pokemons by type fetched")
        
        mockAPI.getPokemonsByType(param: [:], success: { typeDetail in
            XCTAssertEqual(typeDetail.pokemon.first?.pokemon.name, "bulbasaur")
            expectation.fulfill()
        }, failure: {
            XCTFail("Failed to fetch pokemons by type")
        })
        
        waitForExpectations(timeout: 5, handler: nil)
    }
}


class PokemonListByTypeViewModelTests: XCTestCase {
    var viewModel: PokemonListByTypeViewModel!
    var mockAPI: MockPokemonAPI!
    
    override func setUp() {
        super.setUp()
        mockAPI = MockPokemonAPI()
        viewModel = PokemonListByTypeViewModel(with: mockAPI)
    }
    
    override func tearDown() {
        viewModel = nil
        mockAPI = nil
        super.tearDown()
    }
    
    func testFetchPokemonByType() {
        let expectation = self.expectation(description: "Data fetched")
        viewModel.dataFetched = {
            expectation.fulfill()
        }
        viewModel.fetchPokemonByType(typeID: "1")
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(viewModel.pokemons.count, 1)
        XCTAssertEqual(viewModel.pokemons.first?.name, "bulbasaur")
    }
    
    func testFavoritePokemon() {
        let indexPath = IndexPath(row: 0, section: 0)
        
        viewModel.pokemons = [
            Pokemon(name: "bulbasaur", url: "https://pokeapi.co/api/v2/pokemon/1/")
        ]
        
        viewModel.favoritePokemon(favorite: true, indexPath: indexPath)
        XCTAssertTrue(viewModel.pokemons[indexPath.row].favorite)
        
        viewModel.favoritePokemon(favorite: false, indexPath: indexPath)
        XCTAssertFalse(viewModel.pokemons[indexPath.row].favorite)
    }
    
    func testUpdateFavoriteStatus() {
        let indexPath = IndexPath(row: 0, section: 0)
        
        viewModel.pokemons = [
            Pokemon(name: "bulbasaur", url: "https://pokeapi.co/api/v2/pokemon/1/")
        ]
        
        let favoritePokemons = [["name": "bulbasaur", "pokeID": "1"]]
        let defaults = UserDefaults.standard
        if let encodedData = try? JSONEncoder().encode(favoritePokemons) {
            defaults.set(encodedData, forKey: "favoritePokemons")
            defaults.synchronize()
        }
        
        viewModel.updateFavoriteStatus(indexPaths: [indexPath])
        
        XCTAssertTrue(viewModel.pokemons[indexPath.row].favorite)
    }
    
    func testIsPokeIDContainsInFavorite() {
        let favoritePokemons = [["name": "bulbasaur", "pokeID": "1"]]
        let defaults = UserDefaults.standard
        if let encodedData = try? JSONEncoder().encode(favoritePokemons) {
            defaults.set(encodedData, forKey: "favoritePokemons")
            defaults.synchronize()
        }
        
        let result = viewModel.isPokeIDContainsInFavorite(url: "https://pokeapi.co/api/v2/pokemon/1/")
        
        XCTAssertTrue(result)
    }
    
    func testGetFavoritePokemons() {
        let favoritePokemons = [["name": "bulbasaur", "pokeID": "1"]]
        let defaults = UserDefaults.standard
        if let encodedData = try? JSONEncoder().encode(favoritePokemons) {
            defaults.set(encodedData, forKey: "favoritePokemons")
            defaults.synchronize()
        }
        
        let result = viewModel.getFavoritePokemons()
        
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?["name"], "bulbasaur")
    }
    
    func testSaveFavoritePokemons() {
        let favoritePokemons = [["name": "bulbasaur", "pokeID": "1"]]
        
        viewModel.saveFavoritePokemons(favoritePokemons)
        
        if let savedData = UserDefaults.standard.data(forKey: "favoritePokemons"),
           let decodedPokemons = try? JSONDecoder().decode([[String:String]].self, from: savedData) {
            XCTAssertEqual(decodedPokemons.count, 1)
            XCTAssertEqual(decodedPokemons.first?["name"], "bulbasaur")
        } else {
            XCTFail("Failed to save favorite pokemons")
        }
    }
}

class PokemonDetailViewModelTests: XCTestCase {
    var viewModel: PokemonDetailViewModel!
    var mockAPI: MockPokemonAPI!
    
    override func setUp() {
        super.setUp()
        mockAPI = MockPokemonAPI()
        viewModel = PokemonDetailViewModel(with: mockAPI)
    }
    
    override func tearDown() {
        viewModel = nil
        mockAPI = nil
        super.tearDown()
    }
    
    func testFetchSpecies() {
        let expectation = self.expectation(description: "Species fetched")
        viewModel.dataFetched = {
            expectation.fulfill()
        }
        
        viewModel.fetchSpecies(pokeID: "1")
        
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertNotNil(viewModel.speciesData)
        XCTAssertEqual(viewModel.speciesData?.name, "bulbasaur")
    }
    
    func testFetchEvolutionChain() {
        let expectation = self.expectation(description: "Evolution chain fetched")
        viewModel.dataFetched = {
            expectation.fulfill()
        }
        
        viewModel.fetchEvolutionChain(chainID: "1")
        
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(viewModel.evolutionList.count, 2)
        XCTAssertEqual(viewModel.evolutionList[0].name, "bulbasaur")
        XCTAssertEqual(viewModel.evolutionList[1].name, "ivysaur")
    }
    
    func testFavoritePokemon() {
        let url = "https://pokeapi.co/api/v2/pokemon-species/1/"
        let species = Species(name: "bulbasaur", url: url)
        let detail = PokemonDetail(id: 1, name: "bulbasaur", sprites: Sprites(front_default: "url", other: SpritesOther(officialArtwork: OfficialArtwork(frontDefault: "url"))), types: [TypeElement(type: TypeInfo(name: "grass", url: ""))], species: species)
        
        viewModel.pokemon = Pokemon(name: "bulbasaur", url: url, favorite: false, pokeID: "1", detail: detail)
        
        viewModel.favoritePokemon(favorite: true)
        XCTAssertTrue(viewModel.pokemon?.favorite ?? false)
        
        viewModel.favoritePokemon(favorite: false)
        XCTAssertFalse(viewModel.pokemon?.favorite ?? false)
    }
    
    func testIsPokeIDContainsInFavorite() {
        let favoritePokemons = [["name": "bulbasaur", "pokeID": "1"]]
        
        let defaults = UserDefaults.standard
        if let encodedData = try? JSONEncoder().encode(favoritePokemons) {
            defaults.set(encodedData, forKey: "favoritePokemons")
            defaults.synchronize()
        }
        
        let url = "https://pokeapi.co/api/v2/pokemon-species/1/"
        let result = viewModel.isPokeIDContainsInFavorite(url: url)
        
        XCTAssertTrue(result)
    }
    
    func testGetFavoritePokemons() {
        let favoritePokemons = [["name": "bulbasaur", "pokeID": "1"]]
        let defaults = UserDefaults.standard
        if let encodedData = try? JSONEncoder().encode(favoritePokemons) {
            defaults.set(encodedData, forKey: "favoritePokemons")
            defaults.synchronize()
        }
        
        let result = viewModel.getFavoritePokemons()
        
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?["name"], "bulbasaur")
    }
    
    func testSaveFavoritePokemons() {
        let favoritePokemons = [["name": "bulbasaur", "pokeID": "1"]]
        
        viewModel.saveFavoritePokemons(favoritePokemons)
        
        let defaults = UserDefaults.standard
        if let savedData = defaults.data(forKey: "favoritePokemons") {
            if let decodedPokemons = try? JSONDecoder().decode([[String:String]].self, from: savedData) {
                XCTAssertEqual(decodedPokemons.count, 1)
                XCTAssertEqual(decodedPokemons.first?["name"], "bulbasaur")
                return
            }
        }
        
        XCTFail("Failed to save favorite pokemons")
    }
}
