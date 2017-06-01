////
///  EditorialInviteCell.swift
//

class EditorialInviteCell: EditorialCell {
    fileprivate let inviteLabel = StyledLabel(style: .largeWhite)
    fileprivate let sentLabel = StyledLabel(style: .white)
    fileprivate let textBg = UIView()
    fileprivate let textView = ClearTextView()
    fileprivate let submitButton = StyledButton(style: .editorialJoin)

    var onInviteChange: ((Editorial.InviteInfo) -> Void)?

    @objc
    func submitTapped() {
        guard let emails = textView.text else { return }

        let responder: EditorialToolsResponder? = findResponder()
        responder?.submitInvite(cell: self, emails: emails)
    }

    override func updateConfig() {
        super.updateConfig()
        textView.text = config.invite?.emails

        let sent = config.invite?.sent == true
        textBg.isHidden = sent
        sentLabel.isHidden = !sent
    }

    override func bindActions() {
        super.bindActions()
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
    }

    override func style() {
        super.style()

        textView.delegate = self
        textView.backgroundColor = .clear
        textView.tintColor = .black
        textView.textColor = .black
        textView.font = UIFont.editorFont()
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = UIEdgeInsets.zero
        textView.showsHorizontalScrollIndicator = false
        textView.keyboardAppearance = .dark
        textView.lineColor = .clear
        textView.selectedLineColor = .clear
        textView.autocapitalizationType = .none
        textView.autocorrectionType = .no
        textView.spellCheckingType = .no
        textView.enablesReturnKeyAutomatically = true
        textView.placeholder = InterfaceString.Editorials.InvitePlaceholder
        textView.placeholderStyle = .placeholder
        textView.keyboardType = .emailAddress

        inviteLabel.text = InterfaceString.Editorials.Invite
        sentLabel.text = InterfaceString.Editorials.Sent
        inviteLabel.numberOfLines = 0
        textBg.backgroundColor = .white
        textView.isEditable = true
        submitButton.isEnabled = false
        submitButton.setTitle(InterfaceString.Editorials.SubmitInvite, for: .normal)
    }

    override func arrange() {
        super.arrange()

        editorialContentView.addSubview(inviteLabel)
        editorialContentView.addSubview(sentLabel)
        editorialContentView.addSubview(textBg)
        textBg.addSubview(textView)
        editorialContentView.addSubview(submitButton)

        sentLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(textBg)
        }

        inviteLabel.snp.makeConstraints { make in
            make.top.equalTo(editorialContentView).inset(Size.smallTopMargin)
            make.leading.equalTo(editorialContentView).inset(Size.defaultMargin)
            make.trailing.lessThanOrEqualTo(editorialContentView).inset(Size.defaultMargin).priority(Priority.required)
        }
        inviteLabel.setContentHuggingPriority(UILayoutPriorityRequired, for: .vertical)

        textBg.snp.makeConstraints { make in
            make.leading.trailing.equalTo(editorialContentView).inset(Size.defaultMargin)
            make.top.equalTo(inviteLabel.snp.bottom).offset(Size.defaultMargin.top)
            make.bottom.equalTo(submitButton.snp.top).offset(-Size.textFieldMargin)
        }

        textView.snp.makeConstraints { make in
            make.edges.equalTo(textBg).inset(UIEdgeInsets(tops: 20, sides: 30))
        }

        submitButton.snp.makeConstraints { make in
            make.height.equalTo(Size.buttonHeight)
            make.bottom.equalTo(editorialContentView).offset(-Size.defaultMargin.bottom)
            make.leading.trailing.equalTo(editorialContentView).inset(Size.defaultMargin)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onInviteChange = nil
    }
}

extension EditorialInviteCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        (textView as? ClearTextView)?.textDidChange()
        submitButton.isEnabled = textView.text?.isEmpty == false
        let info: Editorial.InviteInfo = (emails: textView.text, sent: false)
        onInviteChange?(info)
    }
}
