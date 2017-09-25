////
///  EditorialTitledCell.swift
//

import SnapKit


class EditorialTitledCell: EditorialCell {
    let titleLabel = StyledLabel(style: .editorialHeader)
    let authorLabel = StyledLabel(style: .editorialHeader)
    let subtitleWebView = ElloWebView()
    var subtitleHeightConstraint: Constraint?

    enum TitlePlacement {
        case `default`
        case inStream
    }
    var titlePlacement: TitlePlacement = .default {
        didSet {
            let top: CGFloat
            switch titlePlacement {
            case .default:
                top = Size.defaultMargin.top
            case .inStream:
                top = Size.postStreamLabelMargin
            }

            titleLabel.snp.updateConstraints { make in
                make.top.equalTo(editorialContentView).offset(top)
            }
        }
    }

    override func style() {
        super.style()
        titleLabel.isMultiline = true
        authorLabel.isMultiline = false
        subtitleWebView.delegate = self
        subtitleWebView.backgroundColor = .clear
        subtitleWebView.isOpaque = false
        subtitleWebView.scrollView.isScrollEnabled = false
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titlePlacement = .default
    }

    override func updateConfig() {
        super.updateConfig()
        titleLabel.text = config.title
        authorLabel.text = config.author

        if let html = config.subtitle {
            let wrappedHtml = StreamTextCellHTML.editorialHTML(html)
            subtitleWebView.loadHTMLString(wrappedHtml, baseURL: URL(string: "/"))
        }
        else {
            subtitleWebView.loadHTMLString("", baseURL: URL(string: "/"))
        }
    }

    override func arrange() {
        super.arrange()

        editorialContentView.addSubview(titleLabel)
        editorialContentView.addSubview(authorLabel)
        editorialContentView.addSubview(subtitleWebView)

        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(editorialContentView).inset(Size.defaultMargin)
        }

        authorLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(editorialContentView).inset(Size.defaultMargin)
            make.top.equalTo(titleLabel.snp.bottom).offset(3)
        }
    }

}

extension EditorialTitledCell: UIWebViewDelegate {
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let scheme = request.url?.scheme, scheme == "default" {
            tappedEditorial()
            return false
        }
        else {
            return ElloWebViewHelper.handle(request: request, origin: self)
        }
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        if let actualHeight = webView.windowContentSize()?.height,
            let constraint = subtitleHeightConstraint
        {
            constraint.update(offset: actualHeight)
        }
    }
}
