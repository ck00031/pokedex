//
//  PokemonListByTypeViewController.swift
//  Pokedex
//
//  Created by Alex Wang on 2024/6/25.
//

import UIKit
import SnapKit

class PokemonListByTypeViewController: UIViewController {
    enum LayoutMode {
        case grid
        case list
    }
    var typeID: String?
    var typeName: String?
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Int, Pokemon>!
    var layoutMode: LayoutMode = .list
    fileprivate let viewModel = PokemonListByTypeViewModel(with: PokemonAPI())
    private let loadingGifView:UIImageView = {
        let view = UIImageView()
        if let gifImage = UIImage.gif(name: "pokeball_loading") {
            view.image = gifImage
        }
        view.contentMode = .scaleAspectFit
        view.sd_imageTransition = .fade
        return view
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //update favorite status
        viewModel.updateFavoriteStatus(indexPaths: self.collectionView.indexPathsForVisibleItems)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupDataSource()
        setupNavigationBar()
        setIndicator()
        
        startLoading()
        
        
        //handle data fetched
        viewModel.dataFetched = {
            [weak self] in
            self?.updateDataSource()
            self?.stopLoading()
        }
        
        //get data
        if let typeID = self.typeID {
            viewModel.fetchPokemonByType(typeID: typeID)
        }
    }

    private func startLoading() {
        loadingGifView.isHidden = false
    }
    
    private func stopLoading() {
        loadingGifView.isHidden = true
    }
    
    private func setIndicator() {
        view.addSubview(loadingGifView)
        loadingGifView.snp.makeConstraints({
            make in
            make.center.equalToSuperview()
            make.width.height.equalTo(150)
        })
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.register(PokemonCell.self, forCellWithReuseIdentifier: PokemonCell.reuseIdentifier)
        collectionView.register(PokemonListCell.self, forCellWithReuseIdentifier: PokemonListCell.reuseIdentifier)
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        view.addSubview(collectionView)

        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Int, Pokemon>(collectionView: collectionView) { (collectionView, indexPath, pokemon) -> UICollectionViewCell? in
            if self.layoutMode == .list {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PokemonListCell.reuseIdentifier, for: indexPath) as! PokemonListCell
                cell.configure(with: pokemon)
                cell.didFavoriteButtonClick = {
                    [weak self] isFavorite in
                    self?.viewModel.favoritePokemon(favorite: isFavorite, indexPath: indexPath)
                    Tools.sharedInstance.makeFeeback()
                }
                cell.typeButtonDidClick = {
                    [weak self] name, typeID in
                    let typePoekmonListVC = PokemonListByTypeViewController()
                    typePoekmonListVC.typeID = typeID
                    typePoekmonListVC.typeName = name
                    
                    self?.navigationController?.pushViewController(typePoekmonListVC, animated: true)
                }
                return cell
            }else{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PokemonCell.reuseIdentifier, for: indexPath) as! PokemonCell
                cell.configure(with: pokemon)
                cell.didFavoriteButtonClick = {
                    [weak self] isFavorite in
                    self?.viewModel.favoritePokemon(favorite: isFavorite, indexPath: indexPath)
                    Tools.sharedInstance.makeFeeback()
                }
                cell.typeButtonDidClick = {
                    [weak self] name, typeID in
                    let typePoekmonListVC = PokemonListByTypeViewController()
                    typePoekmonListVC.typeID = typeID
                    typePoekmonListVC.typeName = name
                    
                    self?.navigationController?.pushViewController(typePoekmonListVC, animated: true)
                }
                return cell
            }
        }
    }

    private func updateDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Pokemon>()
        snapshot.appendSections([0])
        snapshot.appendItems(self.viewModel.pokemons)
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: false)
        }
    }

    fileprivate func createLayout() -> UICollectionViewLayout {
        return layoutMode == .grid ? createGridLayout() : createListLayout()
    }

    private func createGridLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                              heightDimension: .estimated(220))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(220))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 12, bottom: 0, trailing: 12)
        section.interGroupSpacing = 10

        return UICollectionViewCompositionalLayout(section: section)
    }

    private func createListLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .estimated(180))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(180))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 12, bottom: 0, trailing: 12)
        section.interGroupSpacing = 10
        return UICollectionViewCompositionalLayout(section: section)
    }

    private func setupNavigationBar() {
        let image = layoutMode == .list ? UIImage.init(systemName: "square.grid.2x2") : UIImage.init(systemName: "list.dash")
        let switchLayoutButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(switchLayout))
        navigationItem.rightBarButtonItem = switchLayoutButton
        
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .inline
        if let typeName = typeName {
            title = "\(typeName.capitalized) type Pokemons"
        }else{
            title = "Pokemons"
        }
    }

    @objc private func switchLayout() {
        layoutMode = layoutMode == .grid ? .list : .grid
        setupNavigationBar()
        
        collectionView.setCollectionViewLayout(createLayout(), animated: false) {
            completed in
            if self.layoutMode == .list {
                self.collectionView.visibleCells.forEach { cell in
                    if let customCell = cell as? PokemonListCell {
                        customCell.updateLayout()
                    }
                }
            }else{
                self.collectionView.visibleCells.forEach { cell in
                    if let customCell = cell as? PokemonCell {
                        customCell.updateLayout()
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.collectionView.scrollToItem(at: IndexPath.init(item: 0, section: 0), at: .top, animated: false)
            }
        }
    }
}

extension PokemonListByTypeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let pokeID = Tools.sharedInstance.getPokeID(from: viewModel.pokemons[indexPath.row].url) else { return }
        let detailVC = DetailViewController()
        detailVC.pokeID = pokeID
        detailVC.viewModel.pokemon = viewModel.pokemons[indexPath.row]
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

