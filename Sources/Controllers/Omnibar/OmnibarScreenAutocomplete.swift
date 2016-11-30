////
///  OmnibarScreenAutocomplete.swift
//

// MARK: UITextViewDelegate
extension OmnibarScreen: UITextViewDelegate {
    private func throttleAutoComplete(textView: UITextView, text: String, range: NSRange) {
        let autoComplete = AutoComplete()
        let location = range.length > 0 && range.location > 0 ? range.location - 1 : range.location
        let mightMatch = autoComplete.eagerCheck(text, location: location)
        if mightMatch && textView.autocorrectionType == .Yes {
            textView.spellCheckingType = .No
            textView.autocorrectionType = .No
            textView.resignFirstResponder()
            textView.becomeFirstResponder()
        }
        else if !mightMatch && textView.autocorrectionType == .No {
            textView.spellCheckingType = .Yes
            textView.autocorrectionType = .Yes
            textView.resignFirstResponder()
            textView.becomeFirstResponder()
        }

        self.autoCompleteThrottle { [weak self] in
            guard let wSelf = self else { return }

            // deleting characters yields a range.length > 0, go back 1 character for deletes
            if let match = autoComplete.check(text, location: location) {
                wSelf.autoCompleteVC.load(match) { [weak self] count in
                    guard let wSelf = self else { return }
                    guard text == textView.text else { return }

                    if count > 0 {
                        wSelf.showAutoComplete(textView, count: count)
                    }
                    else if count == 0 {
                        wSelf.hideAutoComplete(textView)
                    }
                }
            } else {
                wSelf.hideAutoComplete(textView)
            }
        }
    }

    public func textView(textView: UITextView, shouldChangeTextInRange nsrange: NSRange, replacementText: String) -> Bool {
        if autoCompleteShowing && emojiKeyboardShowing() {
            return false
        }

        var text = textView.text
        if let range = text.rangeFromNSRange(nsrange) {
            text.replaceRange(range, with: replacementText)
        }
        self.throttleAutoComplete(textView, text: text, range: nsrange)
        return true
    }

    public func textViewDidChange(textView: UITextView) {
        if let path = currentTextPath
            where regionsTableView.cellForRowAtIndexPath(path) != nil
        {
            var currentText = textView.attributedText
            if currentText.string.characters.count == 0 {
                currentText = ElloAttributedString.style("")
                textView.typingAttributes = ElloAttributedString.attrs()
                boldButton.selected = false
                italicButton.selected = false
            }

            updateText(currentText, atPath: path)
        }
        updateButtons()
    }

    public func textViewDidChangeSelection(textView: UITextView) {
        let font = textView.typingAttributes[NSFontAttributeName] as? UIFont
        let fontName = font?.fontName ?? "AtlasGrotesk-Regular"

        switch fontName {
        case UIFont.editorItalicFont().fontName:
            boldButton.selected = false
            italicButton.selected = true
        case UIFont.editorBoldFont().fontName:
            boldButton.selected = true
            italicButton.selected = false
        case UIFont.editorBoldItalicFont().fontName:
            boldButton.selected = true
            italicButton.selected = true
        default:
            boldButton.selected = false
            italicButton.selected = false
        }

        if textView.typingAttributes[NSLinkAttributeName] is NSURL {
            linkButton.selected = true
            linkButton.enabled = true
        }
        else if let selection = textView.selectedTextRange
        where selection.empty {
            linkButton.selected = false
            linkButton.enabled = false
        }
        else {
            linkButton.selected = false
            linkButton.enabled = true
        }
    }

    private func emojiKeyboardShowing() -> Bool {
        return textView.textInputMode?.primaryLanguage == nil || textView.textInputMode?.primaryLanguage == "emoji"
    }

    func hideAutoComplete(textView: UITextView) {
        if autoCompleteShowing {
            autoCompleteShowing = false
            textView.spellCheckingType = .Yes
            textView.inputAccessoryView = keyboardButtonView
            textView.resignFirstResponder()
            textView.becomeFirstResponder()
        }
    }

    private func showAutoComplete(textView: UITextView, count: Int) {
        if !autoCompleteShowing {
            autoCompleteShowing = true
            textView.spellCheckingType = .No
            textView.autocorrectionType = .No
            let container = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 1))
            container.addSubview(autoCompleteContainer)
            textView.inputAccessoryView = container
            textView.resignFirstResponder()
            textView.becomeFirstResponder()
        }

        let height = AutoCompleteCell.cellHeight() * min(CGFloat(3.5), CGFloat(count))
        let constraintIndex = textView.inputAccessoryView?.constraints.indexOf { $0.firstAttribute == .Height }
        if let index = constraintIndex,
            inputAccessoryView = textView.inputAccessoryView,
            constraint = inputAccessoryView.constraints.safeValue(index)
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
    public func autoComplete(controller: AutoCompleteViewController, itemSelected item: AutoCompleteItem) {
        if let name = item.result.name {
            let prefix: String
            let suffix: String
            if item.type == .Username {
                prefix = "@"
                suffix = ""
            }
            else {
                prefix = ":"
                suffix = ":"
            }

            let newText = textView.text.stringByReplacingCharactersInRange(item.match.range, withString: "\(prefix)\(name)\(suffix) ")
            let currentText = ElloAttributedString.style(newText)
            textView.attributedText = currentText
            textViewDidChange(textView)
            updateButtons()
            hideAutoComplete(textView)
        }
    }
}
