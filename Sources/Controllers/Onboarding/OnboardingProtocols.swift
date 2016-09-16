////
///  OnboardingProtocols.swift
//

public enum OnboardingStep: Int {
    case Categories = 0
    case CreateProfile
    case InviteFriends
}

public protocol OnboardingDelegate: class {
    var isLastOnboardingStep: Bool { get set }
    var canGoNext: Bool { get set }
    var prompt: String? { get set }

    func nextAction()
    func abortAction()
}

public protocol OnboardingScreenProtocol: class {
    var delegate: OnboardingDelegate? { get set }
    var controllerContainer: UIView { get set }
    var isLastOnboardingStep: Bool { get set }
    var canGoNext: Bool { get set }
    var prompt: String? { get set }
    func styleFor(step step: OnboardingStep)
}

public protocol OnboardingStepController: class {
    var onboardingViewController: OnboardingViewController? { get set }
    var onboardingData: OnboardingData! { get set }
    func onboardingWillProceed(abort: Bool, proceedClosure: (success: Bool?) -> Void)
    func onboardingStepBegin()
}
