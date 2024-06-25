//
//  DetailViewController.swift
//  Pokedex
//
//  Created by Alex Wang on 2024/6/21.
//

import UIKit
import SnapKit
import SDWebImage

class DetailViewController: UIViewController {
    var viewModel = PokemonDetailViewModel(with: PokemonAPI())
    var pokeID:String = ""
    private var collectionView: UICollectionView!
    let verticalSzcrollView:UIScrollView = {
        let view = UIScrollView()
        view.alwaysBounceVertical = true
        return view
    }()
    
    lazy var container:UIView = {
        let view = UIView()
        
        return view
    }()
    
    private lazy var favoriteButton:UIButton = {
        let button = UIButton()
        button.setImage(UIImage.init(named: "icon_pokeball_disable"), for: .normal)
        button.setImage(UIImage.init(named: "icon_pokeball_enable"), for: .selected)
        return button
    }()
    
    lazy var imageContainerView:UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 20
        view.backgroundColor = .lightGray
        return view
    }()
    
    lazy var imageView:UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.sd_imageTransition = .fade
        return view
    }()
    
    lazy var flavornContainerView:UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.init(hexString: "c9c9c9").cgColor
        view.layer.borderWidth = 0.5
        return view
    }()
    
    lazy var flavorTitle:UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.text = "Description"
        label.textAlignment = .left
        label.textColor = .black
        return label
    }()
    
    lazy var flavorDescription:UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    lazy var evolutionContainerView:UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.init(hexString: "c9c9c9").cgColor
        view.layer.borderWidth = 0.5
        return view
    }()
    
    lazy var evolutionTitle:UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.text = "Evolution"
        label.textAlignment = .left
        label.textColor = .black
        return label
    }()
    
    lazy var nameLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .black
        return label
    }()
    
    lazy var idLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    lazy var stackView:UIStackView = {
        let view = UIStackView()
        view.spacing = 10
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupNavigationBar()
        setupCollectionView()
        setupDetailView()
        
        viewModel.dataFetched = {
            [weak self] in
            DispatchQueue.main.async {
                self?.setData()
                self?.setFlavorDescrption()
                if let count = self?.viewModel.evolutionList.count, count > 0 {
                    self?.evolutionContainerView.isHidden = false
                    self?.collectionView.reloadData()
                }else{
                    self?.evolutionContainerView.isHidden = true
                }
            }
        }
        
//        viewModel.fetchPokemonDetail(pokeID: pokeID)
        setData()
        viewModel.fetchSpecies(pokeID: pokeID)
    }
    
    func setupNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
    }

    func setupDetailView() {
        view.addSubview(verticalSzcrollView)
        verticalSzcrollView.addSubview(container)
        container.addSubview(imageContainerView)
        imageContainerView.addSubview(imageView)
        container.addSubview(flavornContainerView)
        flavornContainerView.addSubview(flavorTitle)
        flavornContainerView.addSubview(flavorDescription)
        container.addSubview(nameLabel)
        container.addSubview(favoriteButton)
        container.addSubview(idLabel)
        container.addSubview(evolutionContainerView)
        evolutionContainerView.addSubview(collectionView)
        evolutionContainerView.addSubview(evolutionTitle)
        container.addSubview(stackView)
        
        favoriteButton.addTarget(self, action: #selector(favoriteButtonDidSelected), for: .touchUpInside)
        
        verticalSzcrollView.snp.makeConstraints({
            make in
            make.left.right.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        })
        
        container.snp.makeConstraints({
            make in
            make.top.left.right.bottom.equalToSuperview()
            make.width.equalToSuperview()
        })
        
        imageContainerView.snp.makeConstraints({
            make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        })
        
        imageView.snp.makeConstraints { 
            make in
            make.top.equalToSuperview().offset(40)
            make.width.height.equalTo(self.view.frame.width-140)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-40)
        }
        
        nameLabel.snp.makeConstraints {
            make in
            make.top.equalTo(imageContainerView.snp.bottom).offset(20)
            make.left.equalToSuperview().inset(20)
        }
        
        favoriteButton.snp.makeConstraints({
            make in
            make.left.equalTo(nameLabel.snp.right).offset(10)
            make.width.height.equalTo(30)
            make.centerY.equalTo(nameLabel)
        })
        
        idLabel.snp.makeConstraints {
            make in
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.left.right.equalToSuperview().inset(20)
        }
        
        evolutionContainerView.snp.makeConstraints({
            make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(flavornContainerView.snp.bottom).offset(40)
            make.bottom.equalToSuperview().offset(-20)
        })
        
        evolutionTitle.snp.makeConstraints({
            make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview().offset(-25)
        })
        
        collectionView.snp.makeConstraints {
            make in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(130)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        flavornContainerView.snp.makeConstraints({
            make in
            make.top.equalTo(idLabel.snp.bottom).offset(50)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        })
        
        flavorTitle.snp.makeConstraints({
            make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview().offset(-25)
        })
        
        flavorDescription.snp.makeConstraints({
            make in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-10)
        })
        
        stackView.snp.makeConstraints({
            make in
            make.bottom.equalTo(imageContainerView.snp.bottom).offset(-20)
            make.left.equalTo(imageContainerView.snp.left).offset(10)
        })
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.register(EvolutionCell.self, forCellWithReuseIdentifier: EvolutionCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    @objc fileprivate func favoriteButtonDidSelected() {
        favoriteButton.isSelected.toggle()
        viewModel.favoritePokemon(favorite: favoriteButton.isSelected)
        
        Tools.sharedInstance.makeFeeback()
    }
    
    fileprivate func setData() {
        guard let pokemonDetail = viewModel.pokemon?.detail else { return }
        
        if let url = URL(string: pokemonDetail.sprites.other.officialArtwork.frontDefault) {
            imageView.sd_setImage(with: url, completed: {
                [weak self] image, error, cacheType, url in
                self?.imageContainerView.backgroundColor = image?.averageColor
            })
        }

        nameLabel.text = pokemonDetail.name.capitalized
        removeAllTags()
        for item in pokemonDetail.types {
            addTags([["name": item.type.name.capitalized, "url":item.type.url]])
        }
        
        let pokeID = "\(pokemonDetail.id)".ToFourDigitsWithZero()
        idLabel.text = "#\(pokeID)"
        
        favoriteButton.isSelected = viewModel.pokemon?.favorite ?? false
    }
    
    fileprivate func setFlavorDescrption() {
        guard let flavorText = viewModel.speciesData?.flavorTextEntries.first?.flavorText else { return }
        let modifiedString = flavorText.replacingOccurrences(of: "\n", with: " ")
        let attributedString = NSMutableAttributedString(string: modifiedString)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        flavorDescription.attributedText = attributedString
    }
    
    private func addTags(_ tags: [[String:String]]) {
        for tag in tags {
            if let name = tag["name"], let url = tag["url"], let typeID = Tools.sharedInstance.getPokeID(from: url) {
                let tagView = TagView(text: name)
                tagView.viewDidTap = {
                    [weak self] in
                    let typePoekmonListVC = PokemonListByTypeViewController()
                    typePoekmonListVC.typeID = typeID
                    typePoekmonListVC.typeName = name
                    
                    self?.navigationController?.pushViewController(typePoekmonListVC, animated: true)
                }
                
                stackView.addArrangedSubview(tagView)
            }
        }
    }
    
    private func removeAllTags() {
        let arrangedSubviews = stackView.arrangedSubviews
        for view in arrangedSubviews {
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
}

extension DetailViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.evolutionList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EvolutionCell.reuseIdentifier, for: indexPath) as! EvolutionCell
        let species = viewModel.evolutionList[indexPath.item]
        cell.configure(with: species)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 130)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let pokeID = Tools.sharedInstance.getPokeID(from: viewModel.evolutionList[indexPath.item].url) else { return }
        let detailVC = DetailViewController()
        detailVC.pokeID = pokeID
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
