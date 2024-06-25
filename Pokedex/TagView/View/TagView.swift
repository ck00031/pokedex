//
//  TagView.swift
//  Pokedex
//
//  Created by Alex Wang on 2024/6/23.
//

import UIKit
import SnapKit

class TagView: UIView {
    private let label = UILabel()
    var viewDidTap:(()->())?
    let allColors: [UIColor] = TypeColor.allCases.map { $0.color }
    init(text: String, fontSize: CGFloat = 16.0) {
        super.init(frame: .zero)
        setupView(text: text, fontSize: fontSize)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView(text: String, fontSize: CGFloat) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.addGestureRecognizer(tapGesture)
        
        label.text = text
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: fontSize)
        label.textAlignment = .center
        
        backgroundColor = TypeColor.color(for: text.lowercased())
        layer.cornerRadius = fontSize
        layer.masksToBounds = true
        
        addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10))
        }
    }
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        self.viewDidTap?()
    }
}
