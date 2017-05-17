////
///  EditorialPostStreamCell.swift
//

class EditorialPostStreamCell: EditorialPostCell {
    fileprivate let nextButton = UIButton()
    fileprivate let prevButton = UIButton()

    override func style() {
        super.style()

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

        contentView.addSubview(nextButton)
        contentView.addSubview(prevButton)

        nextButton.snp.makeConstraints { make in
            make.top.trailing.equalTo(contentView).inset(Size.arrowMargin)
        }
        prevButton.snp.makeConstraints { make in
            make.top.equalTo(contentView).inset(Size.arrowMargin)
            make.trailing.equalTo(nextButton.snp.leading).offset(-Size.arrowMargin)
        }
    }
}
