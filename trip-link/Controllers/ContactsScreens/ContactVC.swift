//
//  ContactScreenVC.swift
//  trip-link
//
//  Created by Sajjad Choobdari on 8/30/23.
//

import UIKit
import UniformTypeIdentifiers

enum ContactViewMode {
	case view
	case edit
	case add
}

class ContactScreenVC: UIViewController {
		// Outlets
	@IBOutlet private weak var firstNameTextField: UITextField!
	@IBOutlet private weak var lastNameTextField: UITextField!
	@IBOutlet private weak var phoneTextField: UITextField!
	@IBOutlet private weak var emailTextField: UITextField!
	@IBOutlet private weak var noteTextField: NegativePaddedTextView!
	@IBOutlet private weak var addPhotoButtonView: UIButton!
	@IBOutlet private weak var imageView: UIImageView!
	@IBOutlet private weak var deleteContactButton: UIButton!

		// Variables
	private var contactsModel = Contacts()
	var contactViewMode: ContactViewMode = .view
	private var cancelButton: UIBarButtonItem!
	private var doneButton: UIBarButtonItem!
	private var editButton: UIBarButtonItem!
	var contact: Contact?
	private var formHasBeenChanged: Bool = false

		// Life Cycles
	override func viewDidLoad() {
		super.viewDidLoad()

		if contactViewMode == .view {
			firstNameTextField.text = contact?.mutableProps.givenName
			lastNameTextField.text = contact?.mutableProps.familyName
			phoneTextField.text = contact?.mutableProps.phoneNumber
			emailTextField.text = contact?.mutableProps.emailAddress
			noteTextField.text = contact?.mutableProps.note
			if let imageData = contact?.mutableProps.image {
				imageView.image = UIImage(data: imageData)
			}
		}

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

		if (self.contactViewMode != .add) {
			navigationItem.title = ""
		}
	}

		// Methods
	private func updateActionButtons(for mode: ContactViewMode) {
		switch mode {
			case .add:
				self.navigationItem.leftBarButtonItems = [cancelButton]
				self.navigationItem.rightBarButtonItems = [doneButton]
				deleteContactButton.isHidden = true
				addPhotoButtonView.isHidden = false
				break
			case .view:
				self.navigationItem.leftBarButtonItems = []
				self.navigationItem.rightBarButtonItems = [editButton]
				deleteContactButton.isHidden = true
				addPhotoButtonView.isHidden = true
				break
			case .edit:
				self.navigationItem.leftBarButtonItems = [cancelButton]
				self.navigationItem.rightBarButtonItems = [doneButton]
				deleteContactButton.isHidden = false
				addPhotoButtonView.isHidden = false
				if contact?.mutableProps.image != nil {
					addPhotoButtonView.setTitle("Edit", for: .normal)
				}
				break
		}
	}

	private func updateFieldsMode(for mode: ContactViewMode) {
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

	private func navigateBack() {
		if let navigationController = self.navigationController {
			navigationController.popViewController(animated: true)
		}
	}

	private func hasPickedAnImage() -> Bool {
		if let image = imageView.image {
			if !image.isSymbolImage {
				// The UIImageView has a non-nil image that is not a system symbol.
				return true
			}
			return false
		}
		return false
	}

	private func presentImagePicker() {
		let imagePicker = UIImagePickerController()
		imagePicker.delegate = self
		imagePicker.sourceType = .photoLibrary
		imagePicker.mediaTypes = [UTType.image.identifier]
		self.present(imagePicker, animated: true, completion: nil)
	}

	private func updateFormHasBeenChangedState() {
		let textFields: [String?] = [firstNameTextField?.text, lastNameTextField?.text, phoneTextField?.text, emailTextField?.text, noteTextField?.text]
		let contactValues: [String?] = [contact?.mutableProps.givenName, contact?.mutableProps.familyName, contact?.mutableProps.phoneNumber, contact?.mutableProps.emailAddress, contact?.mutableProps.note]

		if (self.contactViewMode == .add) {
			let allFieldsEmpty = textFields.allSatisfy { text in
				let trimmedText = text?.trimmingCharacters(in: .whitespacesAndNewlines)
				let isInputViewEmpty = trimmedText?.isEmpty ?? true

				return isInputViewEmpty
			}
			formHasBeenChanged = !allFieldsEmpty
			if let image = imageView.image, !image.isSymbolImage {
				formHasBeenChanged = true
			}
		} else if (self.contactViewMode == .edit) {
			let allFieldsUntouched = !zip(textFields, contactValues).contains(where: { $0 != $1 })

			formHasBeenChanged = !allFieldsUntouched
			if let initialImageData = contact?.mutableProps.image,
				 let currentImageData = imageView.image?.pngData(),
				 currentImageData != initialImageData
			{
				formHasBeenChanged = true
			}
		}
		doneButton.isEnabled = formHasBeenChanged
	}

	private func showDiscardChangesAlert(completion: @escaping (UIAlertAction) -> Void) {
		AlertUtility.showActionSheet(
			on: self, title: "", message: "Are you sure you want to discard your changes?",
			confirmActionTitle: "Discard Changes", confirmActionStyle: .destructive, confirmHandler: completion,
			cancelActionTitle: "Keep Editing", cancelActionStyle: .cancel, cancelHandler: nil
		)
	}

	private func handleAddingNewContact() {
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
		) { addedContact in
			self.contact = addedContact
			self.contactViewMode = .view
			self.updateFieldsMode(for: .view)
			self.updateActionButtons(for: .view)
			self.updateFormHasBeenChangedState()
		}
	}

	private func discardEditingChanges() {
		firstNameTextField.text = contact?.mutableProps.givenName
		lastNameTextField.text = contact?.mutableProps.familyName
		phoneTextField.text = contact?.mutableProps.phoneNumber
		emailTextField.text = contact?.mutableProps.emailAddress
		noteTextField.text = contact?.mutableProps.note
		if let imageData = contact?.mutableProps.image {
			imageView.image = UIImage(data: imageData)
		}

		self.contactViewMode = .view
		updateActionButtons(for: .view)
		updateFieldsMode(for: .view)
	}

	private func confirmDeleteContactPressed(_: UIAlertAction) {
		if let id = self.contact?.immutableProps.id {
			self.contactsModel.deleteContactByUUID(id: id)
			self.navigateBack()
		}
	}

	private func showDeleteContactAlert() {
		AlertUtility.showActionSheet(
			on: self, title: "", message: "",
			confirmActionTitle: "Delete Contact", confirmActionStyle: .destructive, confirmHandler: confirmDeleteContactPressed,
			cancelActionTitle: "Cancel", cancelActionStyle: .cancel, cancelHandler: nil
		)
	}

	// Actions
	@objc private func onPressEdit() {
		if (contactViewMode == .view) {
			contactViewMode = .edit
			updateActionButtons(for: .edit)
			updateFieldsMode(for: .edit)
			updateFormHasBeenChangedState()
		}
	}

	@objc private func onPressDone() {
		if (contactViewMode == .edit) {
			// save changes and update model and view and get back to view mode
			if let contactIdToModify = contact?.immutableProps.id {
				let modifiedContact = Contact(
					firstName: firstNameTextField.text,
					lastName: lastNameTextField.text,
					phone: phoneTextField.text,
					email: emailTextField.text,
					note: noteTextField.text,
					image: imageView.image?.pngData()
				)
				contactsModel.updateContactByUUID(id: contactIdToModify, modifiedData: modifiedContact.mutableProps) {
					self.contact?.mutableProps = modifiedContact.mutableProps
					self.contactViewMode = .view
					self.updateActionButtons(for: .view)
					self.updateFieldsMode(for: .view)
					self.updateFormHasBeenChangedState()
				}
			}
		} else if (contactViewMode == .add) {
			handleAddingNewContact()
		}
	}

	@objc private func onPressCancel() {
		if (contactViewMode == .edit) {
			if (formHasBeenChanged) {
				showDiscardChangesAlert { _ in
					self.discardEditingChanges()
				}
			} else {
				self.discardEditingChanges()
			}
		} else if (contactViewMode == .add) {
			if (formHasBeenChanged) {
				showDiscardChangesAlert { _ in
					self.navigateBack()
				}
			} else {
				navigateBack()
			}
		}
	}

	@IBAction func onPressAddPhoto(_ sender: UIButton) {
		self.presentImagePicker()
	}

	@IBAction func onPressDeleteContact(_ sender: UIButton) {
		self.showDeleteContactAlert()
	}
}

extension ContactScreenVC: UIImagePickerControllerDelegate {
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		if let selectedImage = info[.originalImage] as? UIImage {
			imageView.image = selectedImage
			updateFormHasBeenChangedState()
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
	//
}
