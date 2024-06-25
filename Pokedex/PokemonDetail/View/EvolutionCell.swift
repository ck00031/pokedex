//
//  EvolutionCell.swift
//  Pokedex
//
//  Created by Alex Wang on 2024/6/23.
//

import UIKit
import SnapKit

class EvolutionCell: UICollectionViewCell {
    static let reuseIdentifier = "EvolutionCell"
    
    private lazy var container:UIView = {
        let view = UIView()
        
        return view
    }()
    
    private lazy var imageView:UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.backgroundColor = .lightGray
        view.clipsToBounds = true
        view.sd_imageTransition = .fade
        return view
    }()
    
    private lazy var nameLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.lineBreakMode = .byCharWrapping
        label.numberOfLines = 2
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.layer.cornerRadius = 10
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(container)
        container.addSubview(imageView)
        container.addSubview(nameLabel)
        
        container.snp.makeConstraints({
            make in
            make.top.left.right.bottom.equalToSuperview()
        })
        
        imageView.snp.makeConstraints {
            make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(imageView.snp.width)
        }
        
        nameLabel.snp.makeConstraints { 
            make in
            make.top.equalTo(imageView.snp.bottom).offset(4)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    func configure(with species: Species) {
        let pokeID = Tools.sharedInstance.getPokeID(from: species.url) ?? ""
        
        if let url = URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(pokeID).png"){
            imageView.sd_setImage(with: url, completed: {
                [weak self] image, error, cacheType, url in
                self?.imageView.backgroundColor = image?.averageColor
            })
        }else{
            imageView.backgroundColor = .lightGray
        }
        nameLabel.text = species.name.capitalized
    }
}
