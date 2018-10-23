////
///  SnapKitExtensions.swift
//

import SnapKit


enum Priority: ConstraintPriorityTarget {
    case low
    case medium
    case high
    case veryHigh
    case required

    var value: Float { return constraintPriorityTargetValue }
    var constraintPriorityTargetValue: Float {
        switch self {
        case .low: return UILayoutPriority.defaultLow.rawValue
        case .medium: return (UILayoutPriority.defaultHigh.rawValue + UILayoutPriority.defaultLow.rawValue) / 2
        case .high: return UILayoutPriority.defaultHigh.rawValue
        case .veryHigh: return UILayoutPriority.required.rawValue - 1
        case .required: return UILayoutPriority.required.rawValue
        }
    }

}

extension Constraint {
    func set(isActivated: Bool) {
        if isActivated {
            activate()
        }
        else {
            deactivate()
        }
    }
}
