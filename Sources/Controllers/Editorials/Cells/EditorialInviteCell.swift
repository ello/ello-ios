////
///  EditorialInviteCell.swift
//

import SnapKit


class EditorialInviteCell: EditorialCell {
    private let inviteControls = UIView()
    private let inviteLabel = StyledLabel(style: .editorialHeader)
    private let inviteCaption = StyledLabel(style: .editorialCaption)
    private let inviteInstructions = StyledLabel(style: .editorialCaption)
    private let textBg = UIView()
    private let textView = ClearTextView()
    private var submitControls: UIView { return submitButton }
    private let submitButton = StyledButton(style: .editorialJoin)
    private let sentLabel = StyledLabel(style: .editorialSuccess)

    private var collapseInstructions: Constraint!
    private var timer: Timer?

    var onInviteChange: ((Editorial.InviteInfo) -> Void)?

    @objc
    func submitTapped() {
        guard let emails = textView.text else { return }

        let responder: EditorialToolsResponder? = findResponder()
        responder?.submitInvite(cell: self, emails: emails)

        inviteControls.isHidden = true
        sentLabel.isVisible = true
        textView.text = ""
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(showControls), userInfo: .none, repeats: false)
    }

    override func updateConfig() {
        super.updateConfig()
        textView.text = config.invite?.emails

        let showSent: Bool
        let now = Globals.now
        if let sent = config.invite?.sent, now.timeIntervalSince(sent) < 2 {
            showSent = true
            let timeRemaining = 2 - now.timeIntervalSince(sent)
            timer = Timer.scheduledTimer(timeInterval: timeRemaining, target: self, selector: #selector(showControls), userInfo: .none, repeats: false)
        }
        else {
            showSent = false
            timer?.invalidate()
        }
        inviteControls.isHidden = showSent
        sentLabel.isVisible = showSent
    }

    @objc
    func showControls() {
        inviteControls.isVisible = true
        sentLabel.isHidden = true
        timer = nil
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
        inviteLabel.isMultiline = true
        inviteCaption.text = InterfaceString.Editorials.InviteCaption
        inviteCaption.isMultiline = true
        inviteInstructions.text = InterfaceString.Editorials.InviteInstructions
        inviteInstructions.isMultiline = true
        sentLabel.text = InterfaceString.Editorials.InviteSent
        textBg.backgroundColor = .white
        textView.isEditable = true
        submitButton.isEnabled = false
        submitButton.title = InterfaceString.Editorials.SubmitInvite
    }

    override func arrange() {
        super.arrange()

        editorialContentView.addSubview(inviteControls)
        editorialContentView.addSubview(sentLabel)

        inviteControls.addSubview(inviteLabel)
        inviteControls.addSubview(inviteCaption)
        inviteControls.addSubview(inviteInstructions)
        inviteControls.addSubview(textBg)
        inviteControls.addSubview(textView)
        inviteControls.addSubview(submitButton)

        sentLabel.snp.makeConstraints { make in
            make.center.equalTo(editorialContentView)
        }

        inviteControls.snp.makeConstraints { make in
            make.edges.equalTo(editorialContentView)
        }

        inviteLabel.snp.makeConstraints { make in
            make.top.equalTo(editorialContentView).inset(Size.smallTopMargin)
            make.leading.equalTo(editorialContentView).inset(Size.defaultMargin)
            make.trailing.lessThanOrEqualTo(editorialContentView).inset(Size.defaultMargin).priority(Priority.required)
        }
        inviteLabel.setContentHuggingPriority(UILayoutPriority.required, for: .vertical)

        inviteCaption.snp.makeConstraints { make in
            make.top.equalTo(inviteLabel.snp.bottom).offset(Size.textFieldMargin)
            make.leading.equalTo(editorialContentView).inset(Size.defaultMargin)
            make.trailing.lessThanOrEqualTo(editorialContentView).inset(Size.defaultMargin).priority(Priority.required)
        }
        inviteCaption.setContentHuggingPriority(UILayoutPriority.required, for: .vertical)

        textBg.snp.makeConstraints { make in
            make.top.equalTo(inviteCaption.snp.bottom).offset(Size.textFieldMargin)
            make.leading.trailing.equalTo(editorialContentView).inset(Size.defaultMargin)
        }

        textView.snp.makeConstraints { make in
            make.edges.equalTo(textBg).inset(UIEdgeInsets(tops: 20, sides: 30))
        }

        inviteInstructions.snp.makeConstraints { make in
            make.top.equalTo(textBg.snp.bottom).offset(Size.textFieldMargin)
            make.leading.equalTo(editorialContentView).inset(Size.defaultMargin)
            make.trailing.lessThanOrEqualTo(editorialContentView).inset(Size.defaultMargin).priority(Priority.required)
            collapseInstructions = make.height.equalTo(0).priority(Priority.required).constraint
        }
        inviteInstructions.setContentHuggingPriority(UILayoutPriority.required, for: .vertical)
        collapseInstructions.deactivate()

        submitButton.snp.makeConstraints { make in
            make.top.equalTo(inviteInstructions.snp.bottom).offset(Size.textFieldMargin)
            make.height.equalTo(Size.buttonHeight)
            make.bottom.equalTo(editorialContentView).offset(-Size.defaultMargin.bottom)
            make.leading.trailing.equalTo(editorialContentView).inset(Size.defaultMargin)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onInviteChange = nil
        collapseInstructions.deactivate()
        timer?.invalidate()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()

        if textView.frame.height < Size.minInviteTextHeight {
            collapseInstructions.activate()
        }
    }
}

extension EditorialInviteCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        (textView as? ClearTextView)?.textDidChange()
        submitButton.isEnabled = textView.text?.isEmpty == false
        let info: Editorial.InviteInfo = (emails: textView.text, sent: nil)
        onInviteChange?(info)
    }
}
