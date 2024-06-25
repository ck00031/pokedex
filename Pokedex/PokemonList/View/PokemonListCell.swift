//
//  PokemonListCell.swift
//  Pokedex
//
//  Created by Alex Wang on 2024/6/23.
//

import UIKit
import SnapKit
import SDWebImage

class PokemonListCell: UICollectionViewCell {
    static let reuseIdentifier = "PokemonListCell"
    var didFavoriteButtonClick:((_ isFavorited:Bool)->())?
    
    private lazy var containerView:UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var imageView:UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.sd_imageTransition = .fade
        return view
    }()
    
    private lazy var nameLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 24)
        return label
    }()
    
    private lazy var idLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private lazy var favoriteButton:UIButton = {
        let button = UIButton()
        button.setImage(UIImage.init(named: "icon_pokeball_disable"), for: .normal)
        button.setImage(UIImage.init(named: "icon_pokeball_enable"), for: .selected)
        return button
    }()
    
    private lazy var stackView:UIStackView = {
        let view = UIStackView()
        view.spacing = 10
        return view
    }()
    
    var typeButtonDidClick:((_ name:String, _ typeID:String)->())?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        favoriteButton.addTarget(self, action: #selector(favoriteButtonDidSelected), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        removeAllTags()
    }

    private func setupViews() {
        contentView.addSubview(containerView)
        contentView.addSubview(imageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(idLabel)
        containerView.addSubview(favoriteButton)
        containerView.addSubview(stackView)

        containerView.snp.makeConstraints({
            make in
            make.top.equalToSuperview().offset(30)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(imageView)
        })
        
        imageView.snp.makeConstraints {
            make in
            make.top.equalToSuperview()
            make.right.equalToSuperview().offset(-40)
            make.bottom.equalToSuperview()
            make.width.equalTo(150)
            make.height.equalTo(150)
        }

        nameLabel.snp.makeConstraints {
            make in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(20)
        }

        idLabel.snp.makeConstraints {
            make in
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.left.equalTo(nameLabel)
        }
        
        favoriteButton.snp.makeConstraints({
            make in
            make.right.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(10)
            make.width.height.equalTo(30)
        })
        
        stackView.snp.makeConstraints({
            make in
            make.bottom.equalTo(containerView.snp.bottom).offset(-10)
            make.left.equalTo(containerView.snp.left).offset(20)
        })
    }

    func updateLayout() {
        containerView.snp.updateConstraints({
            make in
            make.top.equalToSuperview().offset(30)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(imageView)
        })
        
        imageView.snp.updateConstraints {
            make in
            make.top.equalToSuperview()
            make.right.equalToSuperview().offset(-40)
            make.bottom.equalToSuperview()
            make.width.equalTo(150)
            make.height.equalTo(150)
        }

        nameLabel.snp.updateConstraints {
            make in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(20)
        }

        idLabel.snp.updateConstraints {
            make in
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.left.equalTo(nameLabel)
        }
        
        favoriteButton.snp.updateConstraints({
            make in
            make.right.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(10)
            make.width.height.equalTo(30)
        })
        
        stackView.snp.updateConstraints({
            make in
            make.bottom.equalTo(containerView.snp.bottom).offset(-10)
            make.left.equalTo(containerView.snp.left).offset(20)
        })
        
        setNeedsUpdateConstraints()
    }
    
    func configure(with pokemon: Pokemon) {
        var pokeID = Tools.sharedInstance.getPokeID(from: pokemon.url) ?? ""
        if !pokemon.pokeID.isEmpty {
            pokeID = pokemon.pokeID
        }
        nameLabel.text = pokemon.name.capitalized
        idLabel.text = "#\(pokeID.ToFourDigitsWithZero())"
        
        if let url = URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(pokeID).png"){
            imageView.sd_setImage(with: url, completed: {
                [weak self] image, error, cacheType, url in
                self?.containerView.backgroundColor = image?.averageColor
            })
        }else{
            containerView.backgroundColor = .lightGray
        }
        
        favoriteButton.isSelected = pokemon.favorite
        
        if let types = pokemon.detail?.types {
            for item in types {
                addTags([["name": item.type.name.capitalized, "url":item.type.url]])
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
    
    private func addTags(_ tags: [[String:String]]) {
        for tag in tags {
            if let name = tag["name"], let url = tag["url"], let typeID = Tools.sharedInstance.getPokeID(from: url) {
                let tagView = TagView(text: name, fontSize: 12)
                tagView.viewDidTap = {
                    [weak self] in
                    self?.typeButtonDidClick?(name,typeID)
                }
                
                stackView.addArrangedSubview(tagView)
            }
        }
    }
    
    @objc fileprivate func favoriteButtonDidSelected() {
        favoriteButton.isSelected.toggle()
        didFavoriteButtonClick?(favoriteButton.isSelected)
    }
}

