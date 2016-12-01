////
///  ProfileHeaderCompactView.swift
//

import SnapKit


public class ProfileHeaderCompactView: ProfileHeaderLayoutView {
    override func style() {
        backgroundColor = .clearColor()
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

        avatarView.snp_makeConstraints { make in
            make.top.width.centerX.equalTo(self)
            avatarHeightConstraint = make.height.equalTo(0).constraint
        }

        namesView.snp_makeConstraints { make in
            make.top.equalTo(self.avatarView.snp_bottom)
            make.width.centerX.equalTo(self)
            namesHeightConstraint = make.height.equalTo(0).constraint
        }

        totalCountView.snp_makeConstraints { make in
            make.top.equalTo(self.namesView.snp_bottom)
            make.width.centerX.equalTo(self)
            totalCountHeightConstraint = make.height.equalTo(0).constraint
        }

        statsView.snp_makeConstraints { make in
            make.top.equalTo(self.totalCountView.snp_bottom)
            make.width.centerX.equalTo(self)
            make.height.equalTo(ProfileStatsView.Size.height)
        }

        bioView.snp_makeConstraints { make in
            make.top.equalTo(self.statsView.snp_bottom)
            make.width.centerX.equalTo(self)
            bioHeightConstraint = make.height.equalTo(0).constraint
        }

        locationView.snp_makeConstraints { make in
            make.top.equalTo(self.bioView.snp_bottom)
            make.width.centerX.equalTo(self)
            locationHeightConstraint = make.height.equalTo(0).constraint
        }

        linksView.snp_makeConstraints { make in
            make.top.equalTo(self.locationView.snp_bottom)
            make.width.centerX.equalTo(self)
            linksHeightConstraint = make.height.equalTo(0).constraint
        }
    }
}
