////
///  EditorialPostStreamCell.swift
//

class EditorialPostStreamCell: EditorialPostCell {
    fileprivate let nextButton = UIButton()
    fileprivate let prevButton = UIButton()

    override func style() {
        super.style()

        subtitleLabel.isHidden = true
        nextButton.setImage(.arrow, imageStyle: .white, for: .normal, degree: 90)
        prevButton.setImage(.arrow, imageStyle: .white, for: .normal, degree: -90)
    }

    override func bindActions() {
        super.bindActions()
    }

    override func updateConfig() {
        super.updateConfig()
    }

    override func arrange() {
        super.arrange()

        editorialContentView.addSubview(nextButton)
        editorialContentView.addSubview(prevButton)

        nextButton.snp.makeConstraints { make in
            make.top.trailing.equalTo(editorialContentView).inset(Size.arrowMargin)
        }
        prevButton.snp.makeConstraints { make in
            make.top.equalTo(editorialContentView).inset(Size.arrowMargin)
            make.trailing.equalTo(nextButton.snp.leading).offset(-Size.arrowMargin)
        }
    }
}
