//
//  NoteEditViewController.swift
//  Example
//
//  Created by Виталий Короткий on 02.01.2021.
//  Copyright © 2021 ProVir. All rights reserved.
//

import UIKit
import Combine
import ServiceInjects

class NoteEditViewController: UIViewController {
    @EntityInject(NoteEditPresenter.self)
    private var presenter
    
    private var cancellableSet: Set<AnyCancellable> = []
    
    @IBOutlet private var closeBarItem: UIBarButtonItem!
    @IBOutlet private var saveBarItem: UIBarButtonItem!
    @IBOutlet private weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.presentationController?.delegate = self
        
        presenter.configure(
            showAlertHandler: { [weak self] title, message in
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(.init(title: "OK", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            }
        )
        
        textView.textContainer.lineFragmentPadding = 0
        updateTextViewInsets(keyboardHeight: 0)
        
        textView.text = presenter.contentText
        textView.delegate = self
        
        presenter.titlePublisher.sink { [weak self] in
            self?.navigationItem.title = $0
        }.store(in: &cancellableSet)
        
        presenter.editStatePublisher.sink { [weak self] in
            self?.updateForEditState($0)
        }.store(in: &cancellableSet)
        
        NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillChangeFrameNotification)
            .sink { [weak self] notification in
                guard let self = self,
                      let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
                let keyboardScreenEndFrame = keyboardValue.cgRectValue
                let keyboardViewEndFrame = self.view.convert(keyboardScreenEndFrame, from: self.view.window)
                let keyboardHeight = keyboardViewEndFrame.height - self.view.safeAreaInsets.bottom
                self.updateTextViewInsets(keyboardHeight: keyboardHeight)
                self.scrollToCursorTextView()
            }.store(in: &cancellableSet)
        
        NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] _ in
                self?.updateTextViewInsets(keyboardHeight: 0)
            }.store(in: &cancellableSet)
    }
    
    // MARK: Actions
    @IBAction private func close() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func save() {
        presenter.save(completion: nil)
    }
    
    private func confirmClose() {
        let alert = UIAlertController(title: "Save changes?", message: nil, preferredStyle: .actionSheet)
        alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(.init(title: "Save", style: .default, handler: { [weak self] _ in
            self?.presenter.save(completion: { success in
                if success {
                    self?.close()
                }
            })
        }))
        alert.addAction(.init(title: "Not save", style: .destructive, handler: { [weak self] _ in
            self?.close()
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Private
    private func updateForEditState(_ state: NoteEditViewModel.EditState) {
        closeBarItem?.title = state == .saved ? "Done" : "Cancel"
        saveBarItem?.title = (state == .new || state == .newInvalid) ? "Add" : "Save"
        
        let canSaved = state == .new || state == .changed
        saveBarItem?.isEnabled = canSaved
        isModalInPresentation = canSaved
    }

    private func updateTextViewInsets(keyboardHeight: CGFloat) {
        let padding: CGFloat = 16
        textView.contentInset = .init(top: padding, left: padding, bottom: padding + keyboardHeight, right: padding)
        textView.scrollIndicatorInsets = .init(top: 0, left: 0, bottom: keyboardHeight, right: 0)
    }
    
    private func scrollToCursorTextView() {
        let selectedRange = textView.selectedRange
        textView.scrollRangeToVisible(selectedRange)
    }
}

extension NoteEditViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        presenter.contentText = textView.text ?? ""
    }
}

extension NoteEditViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        confirmClose()
    }
}
