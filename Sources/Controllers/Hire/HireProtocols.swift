////
///  HireProtocols.swift
//

protocol HireDelegate: class {
    func submit(body: String)
}

protocol HireScreenProtocol: class {
    func toggleKeyboard(visible: Bool)
    func showSuccess()
    func hideSuccess()
}
