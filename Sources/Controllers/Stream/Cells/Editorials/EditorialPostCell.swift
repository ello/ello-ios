////
///  EditorialPostCell.swift
//

class EditorialPostCell: EditorialTitledCell {
    fileprivate let buttonsContainer = UIView()
    fileprivate let heartButton = UIButton()
    fileprivate let commentButton = UIButton()
    fileprivate let repostButton = UIButton()
    fileprivate let shareButton = UIButton()

    override func style() {
        super.style()

        heartButton.setImage(.heartOutline, imageStyle: .white, for: .normal)
        commentButton.setImage(.commentsOutline, imageStyle: .white, for: .normal)
        repostButton.setImage(.repost, imageStyle: .white, for: .normal)
        shareButton.setImage(.share, imageStyle: .white, for: .normal)
    }

    override func bindActions() {
        super.bindActions()
    }

    override func updateConfig() {
        super.updateConfig()
    }

    override func arrange() {
        super.arrange()

        contentView.addSubview(buttonsContainer)
        buttonsContainer.addSubview(heartButton)
        buttonsContainer.addSubview(commentButton)
        buttonsContainer.addSubview(repostButton)
        buttonsContainer.addSubview(shareButton)

        buttonsContainer.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalTo(contentView).inset(Size.defaultMargin)
        }

        let buttons = [heartButton, commentButton, repostButton]
        buttons.eachPair { prevButton, button in
            button.snp.makeConstraints { make in
                make.top.bottom.equalTo(buttonsContainer)
            }

            if let prevButton = prevButton {
                button.snp.makeConstraints { make in
                    make.leading.equalTo(prevButton.snp.trailing).offset(Size.buttonsMargin)
                }
            }
            else {
            button.snp.makeConstraints { make in
                make.leading.equalTo(buttonsContainer)
            }
            }
        }

        shareButton.snp.makeConstraints { make in
            make.trailing.top.bottom.equalTo(buttonsContainer)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(contentView).inset(Size.defaultMargin)
            make.trailing.lessThanOrEqualTo(contentView).inset(Size.defaultMargin).priority(Priority.required)
            make.bottom.equalTo(buttonsContainer.snp.top).offset(-Size.subtitleButtonMargin)
        }
    }
}
