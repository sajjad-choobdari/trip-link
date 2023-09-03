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
	var contactViewMode: ContactViewMode = .view
	var cancelButton: UIBarButtonItem!
	var doneButton: UIBarButtonItem!
	var editButton: UIBarButtonItem!
	var contact: Contact?
	var formHasBeenChanged: Bool = false

		// Life Cycles
	override func viewDidLoad() {
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

		if (self.contactViewMode == .add) {
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
				addPhotoButtonView.isHidden = false
				break
			case .view:
				navigationItem.leftBarButtonItems = []
				navigationItem.rightBarButtonItems = [editButton]
				deleteContactButton.isHidden = true
				addPhotoButtonView.isHidden = true
				break
			case .edit:
				navigationItem.leftBarButtonItems = [cancelButton]
				navigationItem.rightBarButtonItems = [doneButton]
				deleteContactButton.isHidden = false
				addPhotoButtonView.isHidden = false
				if let contactImageData = contact?.mutableProps.image {
					addPhotoButtonView.setTitle("Edit", for: .normal)
				}
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
				 currentImageData != initialImageData {
				print(currentImageData)
				print(initialImageData)
				print(currentImageData == initialImageData)
				formHasBeenChanged = true
			}
		}
		doneButton.isEnabled = formHasBeenChanged
	}

	func showDiscardChangesAlert(onAccept: @escaping () -> Void) {
		let alert = UIAlertController(
			title: "",
			message: "Are you sure you want to discard your changes?",
			preferredStyle: .actionSheet
		)

		let discardAction = UIAlertAction(
			title: "Discard Changes",
			style: .destructive,
			handler: { _ in
				onAccept()
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
		) { addedContact in
			contact = addedContact
			self.contactViewMode = .view
			updateFieldsMode(for: .view)
			updateActionButtons(for: .view)
			updateFormHasBeenChangedState()
		}
	}

	func discardEditingChanges() {
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

	// Actions
	@objc func onPressEdit() {
		if (contactViewMode == .view) {
			contactViewMode = .edit
			updateActionButtons(for: .edit)
			updateFieldsMode(for: .edit)
			updateFormHasBeenChangedState()
		}
	}

	@objc func onPressDone() {
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
					contact?.mutableProps = modifiedContact.mutableProps
					self.contactViewMode = .view
					updateActionButtons(for: .view)
					updateFieldsMode(for: .view)
					updateFormHasBeenChangedState()
				}
			}
		} else if (contactViewMode == .add) {
			handleAddingNewContact()
		}
	}

	@objc func onPressCancel() {
		if (contactViewMode == .edit) {
			// get confirmation from user for discarding changes and get back to view mode
			if (formHasBeenChanged) {
				showDiscardChangesAlert {
					self.discardEditingChanges()
				}
			} else {
				self.discardEditingChanges()
			}
		} else if (contactViewMode == .add) {
			if (formHasBeenChanged) {
				showDiscardChangesAlert {
					self.navigateBack()
				}
			} else {
				navigateBack()
			}
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
				if let id = self.contact?.immutableProps.id {
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

}



class NegativePaddedTextView: UITextView {
	override func layoutSubviews() {
		super.layoutSubviews()
		textContainerInset = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: -4)
	}
}
