////
///  OmnibarScreenAutocomplete.swift
//

extension OmnibarScreen {
    func throttleAutoComplete(_ textView: UITextView, text: String, location: Int) {
        let autoComplete = AutoComplete()
        let mightMatch = autoComplete.eagerCheck(text, location: location)
        if mightMatch && textView.autocorrectionType == .yes {
            textView.spellCheckingType = .no
            textView.autocorrectionType = .no
            _ = textView.resignFirstResponder()
            _ = textView.becomeFirstResponder()
        }
        else if !mightMatch && textView.autocorrectionType == .no {
            textView.spellCheckingType = .yes
            textView.autocorrectionType = .yes
            _ = textView.resignFirstResponder()
            _ = textView.becomeFirstResponder()
        }

        self.autoCompleteThrottle { [weak self] in
            guard let `self` = self else { return }

            // deleting characters yields a range.length > 0, go back 1 character for deletes
            if let match = autoComplete.check(text, location: location) {
                self.autoCompleteVC.load(match) { [weak self] count in
                    guard let `self` = self else { return }
                    guard text == textView.text else { return }

                    if count > 0 {
                        self.showAutoComplete(textView, count: count)
                    }
                    else if count == 0 {
                        self.hideAutoComplete(textView)
                    }
                }
            }
            else {
                self.hideAutoComplete(textView)
            }
        }
    }

    func emojiKeyboardShowing() -> Bool {
        return textView.textInputMode?.primaryLanguage == nil
            || textView.textInputMode?.primaryLanguage == "emoji"
    }

    func hideAutoComplete(_ textView: UITextView) {
        guard autoCompleteShowing else { return }

        autoCompleteShowing = false
        textView.spellCheckingType = .yes
        textView.inputAccessoryView = nil
        _ = textView.resignFirstResponder()
        _ = textView.becomeFirstResponder()
    }

    private func showAutoComplete(_ textView: UITextView, count: Int) {
        if !autoCompleteShowing {
            autoCompleteShowing = true
            textView.spellCheckingType = .no
            textView.autocorrectionType = .no
            let container = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 1))
            container.addSubview(autoCompleteContainer)
            textView.inputAccessoryView = container
            _ = textView.resignFirstResponder()
            _ = textView.becomeFirstResponder()
        }

        let height = AutoCompleteCell.Size.height * min(CGFloat(3.5), CGFloat(count))
        let constraintIndex = textView.inputAccessoryView?.constraints.firstIndex {
            $0.firstAttribute == .height
        }
        if let index = constraintIndex,
            let inputAccessoryView = textView.inputAccessoryView,
            let constraint = inputAccessoryView.constraints.safeValue(index)
        {
            constraint.constant = height
            inputAccessoryView.frame.size.height = height
            inputAccessoryView.setNeedsLayout()
        }
        autoCompleteContainer.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: height)
        autoCompleteVC.view.frame = autoCompleteContainer.bounds
    }
}


extension OmnibarScreen: AutoCompleteDelegate {
    func autoComplete(_ controller: AutoCompleteViewController, itemSelected item: AutoCompleteItem)
    {
        guard
            let name = item.result.name
        else { return }

        let prefix: String
        let suffix: String
        if item.type == .username {
            prefix = "@"
            suffix = ""
        }
        else {
            prefix = ":"
            suffix = ":"
        }

        let newText = textView.text.replacingCharacters(
            in: item.match.range,
            with: "\(prefix)\(name)\(suffix) "
        )
        let currentText = NSAttributedString(defaults: newText)
        textView.attributedText = currentText
        textViewDidChange(textView)
        updateButtons()
        hideAutoComplete(textView)
    }
}
