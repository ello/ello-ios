////
///  NotificationsFilterBar.swift
//

class NotificationsFilterBar: UIView {

    struct Size {
        static let height: CGFloat = calculateHeight()
        static let buttonPadding: CGFloat = 1

        static private func calculateHeight() -> CGFloat {
            return 44 + StatusBar.Size.height
        }
    }

    var buttons: [UIButton] {
        return self.subviews.filter { $0 as? UIButton != nil } as! [UIButton]
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white

        let statusBar = StatusBar(frame: CGRect(x: 0, y: 0, width: frame.width, height: 20))
        self.addSubview(statusBar)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .white
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let buttons = self.buttons
        if buttons.count > 0 {
            var x: CGFloat = 0
            let y: CGFloat = StatusBar.Size.height
            let w: CGFloat = (
                self.frame.size.width - Size.buttonPadding * CGFloat(buttons.count - 1)
            ) / CGFloat(buttons.count)
            for button in buttons {
                let frame = CGRect(x: x, y: y, width: w, height: self.frame.size.height - y)
                button.frame = frame
                x += w + Size.buttonPadding
            }
        }
    }

    func selectButton(_ selectedButton: UIButton) {
        for button in buttons {
            button.isSelected = button == selectedButton
        }
    }
}
