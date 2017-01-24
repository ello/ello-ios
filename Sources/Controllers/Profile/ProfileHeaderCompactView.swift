////
///  ProfileHeaderCompactView.swift
//

import SnapKit


class ProfileHeaderCompactView: ProfileHeaderLayoutView {
    override func style() {
        backgroundColor = .clear
    }

    override func bindActions() {}

    override func setText() {}

    override func arrange() {
        super.arrange()

        addSubview(avatarView)
        addSubview(namesView)
        addSubview(totalCountView)
        addSubview(statsView)
        addSubview(bioView)
        addSubview(locationView)
        addSubview(linksView)

        avatarView.snp.makeConstraints { make in
            make.top.width.centerX.equalTo(self)
            avatarHeightConstraint = make.height.equalTo(0).constraint
        }

        namesView.snp.makeConstraints { make in
            make.top.equalTo(self.avatarView.snp.bottom)
            make.width.centerX.equalTo(self)
            namesHeightConstraint = make.height.equalTo(0).constraint
        }

        totalCountView.snp.makeConstraints { make in
            make.top.equalTo(self.namesView.snp.bottom)
            make.width.centerX.equalTo(self)
            totalCountHeightConstraint = make.height.equalTo(0).constraint
        }

        statsView.snp.makeConstraints { make in
            make.top.equalTo(self.totalCountView.snp.bottom)
            make.width.centerX.equalTo(self)
            make.height.equalTo(ProfileStatsView.Size.height)
        }

        bioView.snp.makeConstraints { make in
            make.top.equalTo(self.statsView.snp.bottom)
            make.width.centerX.equalTo(self)
            bioHeightConstraint = make.height.equalTo(0).constraint
        }

        locationView.snp.makeConstraints { make in
            make.top.equalTo(self.bioView.snp.bottom)
            make.width.centerX.equalTo(self)
            locationHeightConstraint = make.height.equalTo(0).constraint
        }

        linksView.snp.makeConstraints { make in
            make.top.equalTo(self.locationView.snp.bottom)
            make.width.centerX.equalTo(self)
            linksHeightConstraint = make.height.equalTo(0).constraint
        }
    }
}
