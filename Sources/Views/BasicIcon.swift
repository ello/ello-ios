////
///  BasicIcon.swift
//

import Foundation

class BasicIcon: UIView {

    fileprivate var _enabled = false
    fileprivate var _selected = false
    fileprivate var _highlighted = false

    fileprivate let normalIconView: UIView
    fileprivate let selectedIconView: UIView
    fileprivate let disabledIconView: UIView?

    // MARK: Initializers

    init(normalIconView: UIView, selectedIconView: UIView, disabledIconView: UIView? = nil) {
        self.normalIconView = normalIconView
        self.selectedIconView = selectedIconView
        self.disabledIconView = disabledIconView

        let frame = CGRect(
            x: 0,
            y: 0,
            width: normalIconView.frame.size.width,
            height: normalIconView.frame.size.height
        )
        super.init(frame: frame)
        addSubview(self.normalIconView)
        addSubview(self.selectedIconView)
        self.selectedIconView.isHidden = true

        if let view = disabledIconView {
            addSubview(view)
            view.isHidden = true
        }
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Private
    func updateIcon(selected: Bool, enabled: Bool) {
        if let disabledIconView = disabledIconView {
            normalIconView.isHidden = !(enabled && !selected)
            selectedIconView.isHidden = !(enabled && selected)
            disabledIconView.isHidden = enabled
        }
        else {
            normalIconView.isHidden = selected
            selectedIconView.isHidden = !selected
        }
    }
}

extension BasicIcon: ImageLabelAnimatable {

    var enabled: Bool {
        get { return _enabled }
        set {
            _enabled = newValue
            updateIcon(selected: _selected, enabled: newValue)
        }
    }

    var selected: Bool {
        get { return _selected }
        set {
            _selected = newValue
            updateIcon(selected: newValue, enabled: _enabled)
        }
    }

    var highlighted: Bool {
        get { return _highlighted }
        set {
            _highlighted = newValue
            if selected { return }
            updateIcon(selected: newValue, enabled: _enabled)
        }
    }

    var view: UIView { return self }
}
