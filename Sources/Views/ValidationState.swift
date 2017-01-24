////
///  ValidationState.swift
//

import UIKit


enum ValidationState {
    case loading
    case error
    case ok
    case okSmall
    case none

    var imageRepresentation: UIImage? {
        switch self {
        case .loading: return InterfaceImage.validationLoading.normalImage
        case .error: return InterfaceImage.validationError.normalImage
        case .ok: return InterfaceImage.validationOK.normalImage
        case .okSmall: return InterfaceImage.smallCheck.normalImage
        case .none: return nil
        }
    }
}
