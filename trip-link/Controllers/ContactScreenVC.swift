//
//  ContactScreenVC.swift
//  trip-link
//
//  Created by Sajjad Choobdari on 8/30/23.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

enum ContactViewMode {
	case view
	case edit
	case add
}

protocol ContactScreenDelegate: AnyObject {
	var contactViewMode: ContactViewMode { get set }
}

class ContactScreenVC: UIViewController {
		// Outlets
	@IBOutlet weak var firstNameTextField: UITextField!
	@IBOutlet weak var lastNameTextField: UITextField!
	@IBOutlet weak var phoneTextField: UITextField!
	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var noteTextField: NegativePaddedTextView!
	@IBOutlet weak var addPhotoButtonView: UIButton!
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var deleteContactButton: UIButton!

		// Variables
	var contactsModel = Contacts()
	var contactViewMode = ContactViewMode.view
	var cancelButton: UIBarButtonItem!
	var doneButton: UIBarButtonItem!
	var editButton: UIBarButtonItem!
	var contact: Contact?

		// Life Cycles
	override func viewDidLoad() {
		if contactViewMode == ContactViewMode.view {
			firstNameTextField.text = contact?.givenName
			lastNameTextField.text = contact?.familyName
			phoneTextField.text = contact?.phoneNumber
			emailTextField.text = contact?.emailAddress
			noteTextField.text = contact?.note
			if let imageData = contact?.image {
				imageView.image = UIImage(data: imageData)
			}
		}
		super.viewDidLoad()

		cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(onPressCancel))
		doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(onPressDone))
		editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(onPressEdit))

		firstNameTextField.delegate = self
		lastNameTextField.delegate = self
		phoneTextField.delegate = self
		emailTextField.delegate = self
		noteTextField.delegate = self

		updateFormHasBeenChangedState()
		updateActionButtons(for: self.contactViewMode)
		updateFieldsMode(for: self.contactViewMode)

		if (self.contactViewMode == ContactViewMode.add) {
			navigationItem.title = "New Contact"
		}
	}

		// Methods
	func updateActionButtons(for mode: ContactViewMode) {
		switch mode {
			case .add:
				navigationItem.leftBarButtonItems = [cancelButton]
				navigationItem.rightBarButtonItems = [doneButton]
				deleteContactButton.isHidden = true
				break
			case .view:
				navigationItem.leftBarButtonItems = []
				navigationItem.rightBarButtonItems = [editButton]
				deleteContactButton.isHidden = true
				break
			case .edit:
				navigationItem.leftBarButtonItems = [cancelButton]
				navigationItem.rightBarButtonItems = [doneButton]
				deleteContactButton.isHidden = false
				break
		}
	}
	func updateFieldsMode(for mode: ContactViewMode) {
		let fields: [UITextField] = [firstNameTextField, lastNameTextField, phoneTextField, emailTextField]

		switch mode {
			case .add, .edit:
				fields.forEach { field in
					field.isUserInteractionEnabled = true
					noteTextField.isEditable = true
				}
				break
			case .view:
				fields.forEach { field in
					field.isUserInteractionEnabled = false
					noteTextField.isEditable = false
				}
				break
		}
	}

	func navigateBack() {
		if let navigationController = self.navigationController {
			navigationController.popViewController(animated: true)
		}
	}

	func hasPickedAnImage() -> Bool {
		if let image = imageView.image {
			if !image.isSymbolImage {
				// The UIImageView has a non-nil image that is not a system symbol.
				return true
			}
			return false
		}
		return false
	}

	func presentImagePicker() {
		let imagePicker = UIImagePickerController()
		imagePicker.delegate = self
		imagePicker.sourceType = .photoLibrary
		imagePicker.mediaTypes = [UTType.image.identifier]
		present(imagePicker, animated: true, completion: nil)
	}

	func updateFormHasBeenChangedState() {
		let textInputs: [UITextInput] = [firstNameTextField, lastNameTextField, phoneTextField, emailTextField, noteTextField]

		let allFieldsEmpty = textInputs.allSatisfy { inputView in
			var text: String?

			if let textField = inputView as? UITextField {
				text = textField.text
			} else if let textView = inputView as? UITextView {
				text = textView.text
			}

			let trimmedText = text?.trimmingCharacters(in: .whitespacesAndNewlines)
			let isInputViewEmpty = trimmedText?.isEmpty ?? true
			return isInputViewEmpty
		}


		doneButton.isEnabled = !allFieldsEmpty
	}

	func showDiscardChangesAlert() {
		let alert = UIAlertController(
			title: "",
			message: "Are you sure you want to discard your changes?",
			preferredStyle: .actionSheet
		)

		let discardAction = UIAlertAction(
			title: "Discard Changes",
			style: .destructive,
			handler: { _ in
				self.navigateBack()
			}
		)
		let keepEditingAction = UIAlertAction(
			title: "Keep Editing",
			style: .cancel,
			handler: nil
		)

		alert.addAction(discardAction)
		alert.addAction(keepEditingAction)

		self.present(alert, animated: true, completion: nil)
	}

	func handleAddingNewContact() {
		guard let image = imageView.image else {
			return
		}
		guard let imageData = image.pngData() else {
			return
		}
		contactsModel.addNewContact(
			firstName: firstNameTextField.text ?? "No Name",
			lastName: lastNameTextField.text,
			phone: phoneTextField.text,
			email: emailTextField.text,
			note: noteTextField.text,
			image: imageData
		)
	}

	// Actions
	@objc func onPressEdit() {
		if (contactViewMode == ContactViewMode.view) {
			contactViewMode = ContactViewMode.edit
			updateActionButtons(for: ContactViewMode.edit)
			updateFieldsMode(for: ContactViewMode.edit)
		}
	}

	@objc func onPressDone() {
		if (contactViewMode == ContactViewMode.edit) {
			// save changes and update model and view and get back to view mode
			self.contactViewMode = ContactViewMode.view
			updateActionButtons(for: ContactViewMode.view)
			updateFieldsMode(for: ContactViewMode.view)
		} else if (contactViewMode == ContactViewMode.add) {
			// save changes and update model and navigate back
			//
			handleAddingNewContact()
			navigateBack()
		}
	}

	@objc func onPressCancel() {
		if (contactViewMode == ContactViewMode.edit) {
			// get confirmation from user for discarding changes and get back to view mode
			self.contactViewMode = ContactViewMode.view
			updateActionButtons(for: ContactViewMode.view)
			updateFieldsMode(for: ContactViewMode.view)
		} else if (contactViewMode == ContactViewMode.add) {
			// get confirmation from user for discarding changes and navigate back
			showDiscardChangesAlert()
		}
	}


	@IBAction func addPhoto(_ sender: UIButton) {
		presentImagePicker()
	}


	func showDeleteChangesAlert() {
		let alert = UIAlertController(
			title: nil,
			message: nil,
			preferredStyle: .actionSheet
		)

		let deleteAction = UIAlertAction(
			title: "Delete Contact",
			style: .destructive,
			handler: { _ in
				if let id = self.contact?.id {
					self.contactsModel.deleteContactByUUID(id: id)
					self.navigateBack()
				}
			}
		)
		let cancelAction = UIAlertAction(
			title: "Cancel",
			style: .cancel,
			handler: nil
		)

		alert.addAction(deleteAction)
		alert.addAction(cancelAction)

		self.present(alert, animated: true, completion: nil)
	}

	@IBAction func onPressDeleteContact(_ sender: UIButton) {
		showDeleteChangesAlert()
	}
}

extension ContactScreenVC: UIImagePickerControllerDelegate {
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		if let selectedImage = info[.originalImage] as? UIImage {
			imageView.image = selectedImage
			addPhotoButtonView.setTitle("Edit", for: .normal)

		}
		picker.dismiss(animated: true, completion: nil)
	}

	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
	}
}
extension ContactScreenVC: UINavigationControllerDelegate {
	func textFieldDidChangeSelection(_ textField: UITextField) {
		updateFormHasBeenChangedState()
	}
	func textViewDidChangeSelection(_ textView: UITextView) {
		updateFormHasBeenChangedState()
	}
}

extension ContactScreenVC: UITextFieldDelegate, UITextViewDelegate {

}



class NegativePaddedTextView: UITextView {
	override func layoutSubviews() {
		super.layoutSubviews()
		textContainerInset = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: -4)
	}
}
