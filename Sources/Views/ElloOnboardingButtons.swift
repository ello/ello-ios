////
///  ElloOnboardingButtons.swift
//

public class OnboardingBackButton: UIButton {

    override public var enabled: Bool {
        didSet {
            self.backgroundColor = enabled ? .greyE5() : .greyF1()
        }
    }

    required override public init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedSetup()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.sharedSetup()
    }

    func sharedSetup() {
        self.setImages(.AngleBracket, degree: 180)
        self.backgroundColor = enabled ? .greyE5() : .greyF1()
    }

}

public class OnboardingSkipButton: WhiteElloButton {

    override func sharedSetup() {
        super.sharedSetup()
        self.setTitleColor(UIColor.greyA(), forState: .Normal)
        self.setTitle(InterfaceString.Skip, forState: .Normal)
    }

}

public class OnboardingNextButton: LightElloButton {
    var chevron: UIImageView?

    override public func updateStyle() {
        super.updateStyle()
        updateImage()
    }

    override func sharedSetup() {
        super.sharedSetup()
        titleEdgeInsets.right = 20

        let chevron = UIImageView()
        chevron.autoresizingMask = [.FlexibleLeftMargin, .FlexibleTopMargin, .FlexibleBottomMargin]
        chevron.contentMode = .Center
        addSubview(chevron)
        self.chevron = chevron

        addTarget(self, action: #selector(OnboardingNextButton.updateImage), forControlEvents: [.TouchDown, .TouchDragEnter, .TouchUpInside, .TouchCancel, .TouchDragExit])
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        if let chevron = chevron {
            chevron.frame = bounds.fromRight().growLeft(frame.height)
        }
    }

    func updateImage() {
        if !enabled {
            chevron?.image = InterfaceImage.AngleBracket.disabledImage
        }
        else if highlighted {
            chevron?.image = InterfaceImage.AngleBracket.selectedImage
        }
        else {
            chevron?.image = InterfaceImage.AngleBracket.normalImage
        }
    }

}

public class FollowAllElloButton: ElloButton {

    required public init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override public func updateStyle() {
        backgroundColor = selected ? .blackColor() : .whiteColor()
        layer.borderWidth = 1
        updateOutline()
    }

    override public func sharedSetup() {
        titleLabel?.font = UIFont.defaultFont()
        titleLabel?.numberOfLines = 1
        setTitleColor(UIColor.blackColor(), forState: .Normal)
        setTitleColor(UIColor.whiteColor(), forState: .Selected)
        setTitleColor(UIColor.greyA(), forState: .Disabled)
        backgroundColor = selected ? .blackColor() : .whiteColor()
    }

    func updateOutline() {
        layer.borderColor = (currentTitleColor ?? UIColor.whiteColor()).CGColor
    }

}