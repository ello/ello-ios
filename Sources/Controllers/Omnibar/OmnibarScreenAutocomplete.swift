////
///  OmnibarScreenAutocomplete.swift
//

// MARK: UITextViewDelegate
extension OmnibarScreen: UITextViewDelegate {
    private func throttleAutoComplete(_ textView: UITextView, text: String, location: Int) {
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
            } else {
                self.hideAutoComplete(textView)
            }
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn nsrange: NSRange, replacementText: String) -> Bool {
        if autoCompleteShowing && emojiKeyboardShowing() {
            return false
        }

        if var text = textView.text,
            let range = text.rangeFromNSRange(nsrange)
        {
            text = text.replacingCharacters(in: range, with: replacementText)

            var location: Int = text.distance(from: text.startIndex, to: range.lowerBound)
            location += replacementText.count
            throttleAutoComplete(textView, text: text, location: location)
        }
        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        if let path = currentTextPath, regionsTableView.cellForRow(at: path as IndexPath) != nil
        {
            var currentText = textView.attributedText
            if currentText?.string.isEmpty == true {
                currentText = NSAttributedString(defaults: "")
                textView.typingAttributes = NSAttributedString.oldAttrs(NSAttributedString.defaultAttrs())
                boldButton.isSelected = false
                italicButton.isSelected = false
            }

            updateText(currentText!, atPath: path)
        }
        updateButtons()
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
        let font = textView.typingAttributes[NSAttributedStringKey.font.rawValue] as? UIFont
        let fontName = font?.fontName ?? "AtlasGrotesk-Regular"

        switch fontName {
        case UIFont.editorItalicFont().fontName:
            boldButton.isSelected = false
            italicButton.isSelected = true
        case UIFont.editorBoldFont().fontName:
            boldButton.isSelected = true
            italicButton.isSelected = false
        case UIFont.editorBoldItalicFont().fontName:
            boldButton.isSelected = true
            italicButton.isSelected = true
        default:
            boldButton.isSelected = false
            italicButton.isSelected = false
        }

        if textView.typingAttributes[NSAttributedStringKey.link.rawValue] is URL {
            linkButton.isSelected = true
            linkButton.isEnabled = true
        }
        else if let selection = textView.selectedTextRange, selection.isEmpty {
            linkButton.isSelected = false
            linkButton.isEnabled = false
        }
        else {
            linkButton.isSelected = false
            linkButton.isEnabled = true
        }
    }

    private func emojiKeyboardShowing() -> Bool {
        return textView.textInputMode?.primaryLanguage == nil || textView.textInputMode?.primaryLanguage == "emoji"
    }

    func hideAutoComplete(_ textView: UITextView) {
        if autoCompleteShowing {
            autoCompleteShowing = false
            textView.spellCheckingType = .yes
            textView.inputAccessoryView = keyboardButtonsContainer
            _ = textView.resignFirstResponder()
            _ = textView.becomeFirstResponder()
        }
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
        let constraintIndex = textView.inputAccessoryView?.constraints.index { $0.firstAttribute == .height }
        if let index = constraintIndex,
            let inputAccessoryView = textView.inputAccessoryView,
            let constraint = inputAccessoryView.constraints.safeValue(index)
        {
            constraint.constant = height
            inputAccessoryView.setNeedsUpdateConstraints()
            inputAccessoryView.frame.size.height = height
            inputAccessoryView.setNeedsLayout()
        }
        autoCompleteContainer.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: height)
        autoCompleteVC.view.frame = autoCompleteContainer.bounds
    }
}


extension OmnibarScreen: AutoCompleteDelegate {
    func autoComplete(_ controller: AutoCompleteViewController, itemSelected item: AutoCompleteItem) {
        if let name = item.result.name {
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

            let newText = textView.text.replacingCharacters(in: item.match.range, with: "\(prefix)\(name)\(suffix) ")
            let currentText = NSAttributedString(defaults: newText)
            textView.attributedText = currentText
            textViewDidChange(textView)
            updateButtons()
            hideAutoComplete(textView)
        }
    }
}
