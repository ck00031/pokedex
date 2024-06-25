//
//  PokemonCell.swift
//  Pokedex
//
//  Created by Alex Wang on 2024/6/21.
//

import UIKit
import SnapKit
import SDWebImage

class PokemonCell: UICollectionViewCell {
    static let reuseIdentifier = "PokemonCell"
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
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    private lazy var idLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .center
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
        containerView.addSubview(imageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(idLabel)
        containerView.addSubview(favoriteButton)
        containerView.addSubview(stackView)

        containerView.snp.makeConstraints({
            make in
            make.top.bottom.leading.trailing.equalToSuperview()
        })
        
        imageView.snp.makeConstraints { 
            make in
            make.top.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
            let width = self.bounds.size.width - 40
            make.width.equalTo(width)
            make.height.equalTo(width)
        }

        nameLabel.snp.makeConstraints { 
            make in
            make.top.equalTo(imageView.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.centerX.equalToSuperview()
        }

        idLabel.snp.makeConstraints { 
            make in
            make.top.equalTo(nameLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
//            make.bottom.equalToSuperview().offset(-20)
        }
        
        favoriteButton.snp.makeConstraints({
            make in
            make.right.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(10)
            make.width.height.equalTo(30)
        })
        
        stackView.snp.makeConstraints({
            make in
            make.top.equalTo(idLabel.snp.bottom).offset(10)
            make.bottom.equalTo(containerView.snp.bottom).offset(-20)
            make.left.equalTo(containerView.snp.left).offset(20)
        })
    }
    
    func updateLayout() {
        containerView.snp.updateConstraints({
            make in
            make.top.bottom.leading.trailing.equalToSuperview()
        })
        
        imageView.snp.updateConstraints {
            make in
            make.top.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
            let width = self.bounds.size.width - 40
            make.width.equalTo(width)
            make.height.equalTo(width)
        }

        nameLabel.snp.updateConstraints {
            make in
            make.top.equalTo(imageView.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.centerX.equalToSuperview()
        }

        idLabel.snp.updateConstraints {
            make in
            make.top.equalTo(nameLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
//            make.bottom.equalToSuperview().offset(-20)
        }
        
        favoriteButton.snp.updateConstraints({
            make in
            make.right.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(10)
            make.width.height.equalTo(30)
        })
        
        stackView.snp.updateConstraints({
            make in
            make.top.equalTo(idLabel.snp.bottom).offset(10)
            make.bottom.equalTo(containerView.snp.bottom).offset(-20)
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
