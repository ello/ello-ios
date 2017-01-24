////
///  OmnibarScreenTableViewDelegate.swift
//

extension OmnibarScreen: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewRegions.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt path: IndexPath) -> CGFloat {
        if let (_, region) = tableViewRegions.safeValue(path.row) {
            switch region {
            case let .attributedText(attrdString):
                return OmnibarTextCell.heightForText(attrdString, tableWidth: regionsTableView.frame.width, editing: reordering)
            case let .image(image):
                return OmnibarImageCell.heightForImage(image, tableWidth: regionsTableView.frame.width, editing: reordering)
            case let .imageData(image, _, _):
                return OmnibarImageCell.heightForImage(image, tableWidth: regionsTableView.frame.width, editing: reordering)
            case .imageURL:
                return OmnibarImageDownloadCell.Size.height
            case .spacer:
                return OmnibarImageCell.Size.bottomMargin
            case .error:
                return OmnibarErrorCell.Size.height
            }
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt path: IndexPath) -> UITableViewCell {
        if let (_, region) = tableViewRegions.safeValue(path.row) {
            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: region.reuseIdentifier, for: path)
            cell.selectionStyle = .none
            cell.showsReorderControl = true

            switch region {
            case let .attributedText(attributedText):
                let textCell = cell as! OmnibarTextCell
                textCell.isFirst = path.row == 0
                textCell.attributedText = attributedText
            case let .image(image):
                let imageCell = cell as! OmnibarImageCell
                imageCell.hasBuyButtonURL = (buyButtonURL != nil)
                imageCell.omnibarImage = image
                imageCell.reordering = reordering
            case let .imageData(_, data, _):
                let imageCell = cell as! OmnibarImageCell
                imageCell.hasBuyButtonURL = (buyButtonURL != nil)
                imageCell.omnibarAnimagedImage = FLAnimatedImage(animatedGIFData: data)
                imageCell.reordering = reordering
            case let .error(url):
                let textCell = cell as! OmnibarErrorCell
                textCell.url = url
            default: break
            }
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt path: IndexPath) {
        if let (_, region) = tableViewRegions.safeValue(path.row) {
            switch region {
            case .attributedText(_):
                startEditingAtPath(path)
            default:
                stopEditing()
            }
        }
    }

    func tableView(_ tableView: UITableView, canMoveRowAt path: IndexPath) -> Bool {
        if let (_, region) = tableViewRegions.safeValue(path.row) {
            switch region {
            case .error, .spacer: return false
            default: return true
            }
        }
        return false
    }

    func tableView(_ tableView: UITableView, moveRowAt sourcePath: IndexPath, to destPath: IndexPath) {
        if let source = reorderableRegions.safeValue(sourcePath.row) {
            reorderableRegions.remove(at: sourcePath.row)
            reorderableRegions.insert(source, at: destPath.row)
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt path: IndexPath) -> Bool {
        if let (_, region) = tableViewRegions.safeValue(path.row) {
            return region.editable
        }
        return false
    }

    func tableView(_ tableView: UITableView, commit style: UITableViewCellEditingStyle, forRowAt path: IndexPath) {
        if style == .delete {
            if reordering {
                deleteReorderableAtIndexPath(path)
            }
            else {
                deleteEditableAtIndexPath(path)
            }
        }
    }

    func deleteReorderableAtIndexPath(_ path: IndexPath) {
        if let (_, region) = reorderableRegions.safeValue(path.row), region.editable
        {
            reorderableRegions.remove(at: path.row)
            regionsTableView.deleteRows(at: [path], with: .automatic)
            if reorderableRegions.count == 0 {
                reorderingTable(false)
            }
        }
    }

    func deleteEditableAtIndexPath(_ path: IndexPath) {
        if let (index_, region) = editableRegions.safeValue(path.row),
            let index = index_, region.editable
        {
            if editableRegions.count == 1 {
                submitableRegions = [.text("")]
                editableRegions = generateEditableRegions(submitableRegions)
                regionsTableView.reloadRows(at: [path], with: .top)
            }
            else {
                submitableRegions.remove(at: index)
                var deletePaths = [path]
                var reloadPaths = [IndexPath]()
                var insertPaths = [IndexPath]()
                regionsTableView.beginUpdates()

                // remove the spacer *after* the deleted row (if it's the first
                // or N-1th row in series of image rows), and *before* the last
                // row (if it's the last row in a series of image rows)
                if let (_, belowTextRegion) = editableRegions.safeValue(path.row + 2),
                    let (_, aboveTextRegion) = editableRegions.safeValue(path.row - 2),
                    let belowText = belowTextRegion.text, let aboveText = aboveTextRegion.text
                {
                    // merge text in submitableRegions
                    let newText = aboveText.joinWithNewlines(belowText)
                    submitableRegions[index - 1] = .attributedText(newText)
                    submitableRegions.remove(at: index)
                    reloadPaths.append(IndexPath(item: path.row - 2, section: 0))
                    deletePaths.append(IndexPath(item: path.row - 1, section: 0))
                    deletePaths.append(IndexPath(item: path.row + 1, section: 0))
                    deletePaths.append(IndexPath(item: path.row + 2, section: 0))
                }
                else if let last = submitableRegions.last, !last.isText {
                    insertPaths.append(path)
                    submitableRegions.append(.text(""))
                }
                else if let (_, region) = editableRegions.safeValue(path.row + 1), region.isSpacer {
                    deletePaths.append(IndexPath(item: path.row + 1, section: 0))
                }
                else if let (_, region) = editableRegions.safeValue(path.row - 1), region.isSpacer {
                    deletePaths.append(IndexPath(item: path.row - 1, section: 0))
                }

                editableRegions = generateEditableRegions(submitableRegions)
                regionsTableView.deleteRows(at: deletePaths, with: .automatic)
                regionsTableView.reloadRows(at: reloadPaths, with: .none)
                regionsTableView.insertRows(at: insertPaths, with: .automatic)
                regionsTableView.endUpdates()
            }
        }
        updateButtons()
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == textScrollView {
            synchronizeScrollViews()
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView != regionsTableView {
            regionsTableView.contentOffset = scrollView.contentOffset
        }
    }

}
