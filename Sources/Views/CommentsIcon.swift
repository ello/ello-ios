////
///  CommentsIcon.swift
//

class CommentsIcon: BasicIcon {
    fileprivate let commentTailView: UIView

    init() {
        let iconImage = InterfaceImage.bubbleBody.normalImage
        let iconSelectedImage = InterfaceImage.bubbleBody.selectedImage
        let icon = UIImageView(image: iconImage)
        let iconSelected = UIImageView(image: iconSelectedImage)

        let commentTail = InterfaceImage.bubbleTail.normalImage
        commentTailView = UIImageView(image: commentTail)
        super.init(normalIconView: icon, selectedIconView: iconSelected)
        addSubview(commentTailView)
        commentTailView.isHidden = true
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Private
    override func updateIcon(selected: Bool, enabled: Bool) {
        super.updateIcon(selected: selected, enabled: enabled)
        commentTailView.isHidden = !selected
    }
}

extension CommentsIcon {
    func animate() {
        let animation = CAKeyframeAnimation()
        animation.keyPath = "position.x"
        animation.values = [0, 8.9, 9.9, 9.9, 0.1, 0, 0]
        animation.keyTimes = [0, 0.25, 0.45, 0.55, 0.75, 0.95, 0]
        animation.duration = 0.6
        animation.repeatCount = Float.infinity
        animation.isAdditive = true
        commentTailView.layer.add(animation, forKey: "comments")
    }

    func finishAnimation() {
        commentTailView.layer.removeAnimation(forKey: "comments")
    }
}
