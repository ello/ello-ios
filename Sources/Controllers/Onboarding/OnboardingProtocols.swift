////
///  OnboardingProtocols.swift
//

enum OnboardingStep: Int {
    case categories = 0
    case createProfile
    case inviteFriends
}

protocol OnboardingDelegate: class {
    func nextAction()
    func abortAction()
}

protocol OnboardingScreenProtocol: class {
    var delegate: OnboardingDelegate? { get set }
    var controllerContainer: UIView { get set }
    var hasAbortButton: Bool { get set }
    var canGoNext: Bool { get set }
    var prompt: String? { get set }
    func styleFor(step: OnboardingStep)
}

protocol OnboardingStepController: class {
    var onboardingViewController: OnboardingViewController? { get set }
    var onboardingData: OnboardingData! { get set }
    func onboardingWillProceed(abort: Bool, proceedClosure: @escaping (_ success: OnboardingViewController.OnboardingProceed) -> Void)
    func onboardingStepBegin()
}
