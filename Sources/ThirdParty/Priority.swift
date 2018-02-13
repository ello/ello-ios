////
///  SnapKitExtensions.swift
//

import SnapKit


enum Priority: ConstraintPriorityTarget {
    case high
    case medium
    case low
    case required

    var value: Float { return constraintPriorityTargetValue }
    var constraintPriorityTargetValue: Float {
        switch self {
        case .low: return UILayoutPriority.defaultLow.rawValue
        case .medium: return (UILayoutPriority.defaultHigh.rawValue + UILayoutPriority.defaultLow.rawValue) / 2
        case .high: return UILayoutPriority.defaultHigh.rawValue
        case .required: return UILayoutPriority.required.rawValue
        }
    }

}
