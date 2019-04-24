////
///  OmnibarScreenTextViewDelegate.swift
//

extension OmnibarScreen: UITextViewDelegate {

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
        if let path = currentTextPath, regionsTableView.cellForRow(at: path as IndexPath) != nil,
            var currentText = textView.attributedText
        {
            if currentText.string.isEmpty == true {
                currentText = NSAttributedString(defaults: "")
                textView.typingAttributes = NSAttributedString.defaultAttrs()
                boldButton.isSelected = false
                italicButton.isSelected = false
            }

            updateText(currentText, atPath: path)
        }
        updateButtons()
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
        let font = textView.typingAttributes[.font] as? UIFont
        let fontName = font?.fontName ?? "AtlasGrotesk-Regular"

        let selectionIsEmpty = textView.selectedTextRange?.isEmpty ?? true
        var isStyled = false

        switch fontName {
        case UIFont.editorItalicFont().fontName:
            boldButton.isSelected = false
            italicButton.isSelected = true
            isStyled = true
        case UIFont.editorBoldFont().fontName:
            boldButton.isSelected = true
            italicButton.isSelected = false
            isStyled = true
        case UIFont.editorBoldItalicFont().fontName:
            boldButton.isSelected = true
            italicButton.isSelected = true
            isStyled = true
        default:
            boldButton.isSelected = false
            italicButton.isSelected = false
        }

        if textView.typingAttributes[.link] is URL {
            linkButton.isSelected = true
            linkButton.isEnabled = true
            isStyled = true
        }
        else {
            linkButton.isSelected = false
            linkButton.isEnabled = !selectionIsEmpty
        }

        toggleStylingButtons(visible: isStyled || !selectionIsEmpty)
    }
}
