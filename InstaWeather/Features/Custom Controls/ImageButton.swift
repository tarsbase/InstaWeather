//
//  ImageButton.swift
//  InstaWeather
//
//  Created by Besher on 2018-11-10.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit



class ImageButton: UIControl {
    
    // TODO add text above button to describe which weather state, fades as you touch down
    
    var normalScale: CGFloat = 1.0
    
    private var growAnimator = UIViewPropertyAnimator()
    
    var buttonActionHandler: (() -> Void)?
    
    var image: UIImageView?
    var imageName: String?
    
    override func layoutSubviews() {
        addTarget(self, action: #selector(touchDown), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(touchUp), for: [.touchUpInside, .touchDragExit, .touchCancel])
        
        isUserInteractionEnabled = true
        backgroundColor = .clear
        image?.contentMode = .scaleAspectFit
        image?.layer.minificationFilter = CALayerContentsFilter.trilinear
    }
    
    @objc private func touchDown() {
        let scale = normalScale * 1.2
        
        // size
        growAnimator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.4) { [weak self] in
            self?.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
        growAnimator.startAnimation()
    }
    
    @objc private func touchUp() {
        let scale = normalScale
        guard isEnabled else { return }
        
        // size
        growAnimator = UIViewPropertyAnimator(duration: 0.08, curve: .easeOut, animations: { [weak self] in
            self?.transform = CGAffineTransform(scaleX: scale, y: scale)
        })
        growAnimator.startAnimation()
    }
    
    // this is currently unnecessary, keeping it for later
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
    }
    
    func setupImageWith(name: String, action: @escaping (() -> Void)) {
        let image = UIImageView(frame: self.frame)
        image.image = UIImage(named: name)
        image.contentMode = .scaleAspectFill
        addSubview(image)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.minificationFilter = .trilinear
        
        let dimensions = image.image?.size ?? .zero
        // ensures image fills up circle
        var aspect = dimensions.width / dimensions.height
        if aspect < 1 { aspect = 1 / aspect }
        
        NSLayoutConstraint.activate([
            image.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            image.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            image.widthAnchor.constraint(equalToConstant: self.bounds.width * aspect),
            image.heightAnchor.constraint(equalToConstant: self.bounds.height * aspect)
            ])
        
        // remove old image first
        self.image?.removeFromSuperview()
        self.image = image
        self.imageName = name
        
        // add action
        addSelector(action: action)
    }
    
    func addSelector(action: @escaping (() -> Void)) {
        self.buttonActionHandler = action
        addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
    }
    
    @objc func buttonAction() {
        buttonActionHandler?()
    }
    
    // makes button easier to activate
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let biggerFrame = bounds.insetBy(dx: -15, dy: -15)
        return biggerFrame.contains(point)
    }
}

class DashboardButton: ImageButton {
    
    var buttonIsSelected: Bool = false { didSet { updateSelection(to: buttonIsSelected) }}
    
    
    func updateSelection(to selected: Bool) {
        let duration = 0.4
        UIViewPropertyAnimator(duration: duration, dampingRatio: 0.9) { [weak self] in
            let newScale: CGFloat = selected ? 1.5 : 1.0
            self?.normalScale = newScale
            self?.transform = CGAffineTransform(scaleX: newScale, y: newScale)
            }.startAnimation()
    }
}
