//
//
//  CredentialsView.swift
//
//  Copyright (c) 2021 Tinkoff Bank
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit

typealias CredentialsTableCell = GenericTableCell<CredentialsView>

private enum UIConstants {
    static let buttonsBar: CGFloat = 25
    static let buttonImageInset: UInt = 2
    static let verticalStackSpacing: CGFloat = 20
    static let buttonImageSize = CGSize(width: 24, height: 24)
}

// MARK: - Model

extension CredentialsView {

    struct Model {
        let creds: SdkCredentials
        let name: String
        let description: String
        let isActiveSwitchModel: HorizontalTitleSwitchView.Model
        let shouldShowDeleteButton: Bool
        // actions
        weak var viewOutput: CredentialsViewOutput?
    }
}

protocol CredentialsViewOutput: AnyObject {
    func onEditing(credentialsViewInput: CredentialsViewInput)
    func onSaveAfterEdit(
        credentialsViewInput: CredentialsViewInput,
        newCreds: SdkCredentials,
        credsUuid: String
    )
    func onDelete(credentialsViewInput: CredentialsViewInput, credsUuid: String)
    func onSwitch(credsUuid: String, isOn: Bool)
}

protocol CredentialsViewInput: AnyObject {
    var output: CredentialsViewOutput? { get }
}

// MARK: - CredentialsView

final class CredentialsView: UIView, CredentialsViewInput {
    var output: CredentialsViewOutput?

    private let borderView = UIView()

    // MARK: - UI Elements

    private let verticalStackView = UIStackView()

    private let editButton = UIButton()
    private let deleteButton = UIButton()

    private let isActiveTitleSwitchView = HorizontalTitleSwitchView()

    private let nameInfoView = VerticalEditableView()
    private let descriptionInfoView = VerticalEditableView()
    private let terminalKeyInfoView = VerticalEditableView()
    private let terminalPasswordInfoView = VerticalEditableView()
    private let publicKeyInfoView = VerticalEditableView()
    private let customerKeyInfoView = VerticalEditableView()

    // MARK: - State

    weak var viewOutput: CredentialsViewOutput?

    private var isEditing = false
    private var modelUuid: String = ""
    private var isActiveSwitchModel: HorizontalTitleSwitchView.Model?

    // MARK: - Methods

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if !touch.isKind(of: UITextField.self) {
            endEditing(true)
        }
        super.touchesBegan(touches, with: event)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Static

    static func getSize(width: CGFloat) -> CGSize {
        return CGSize(width: width, height: 800)
    }

    // MARK: - Private

    private func setupViews() {
        addSubview(borderView)
        borderView.addSubview(verticalStackView)
        borderView.addSubview(isActiveTitleSwitchView)

        borderView.addSubview(deleteButton)
        borderView.addSubview(editButton)

        verticalStackView.addArrangedSubview(nameInfoView)
        verticalStackView.addArrangedSubview(descriptionInfoView)
        verticalStackView.addArrangedSubview(terminalKeyInfoView)
        verticalStackView.addArrangedSubview(terminalPasswordInfoView)
        verticalStackView.addArrangedSubview(publicKeyInfoView)
        verticalStackView.addArrangedSubview(customerKeyInfoView)

        borderView.layer.borderColor = UIColor.lightGray.cgColor
        borderView.layer.borderWidth = 1
        borderView.layer.cornerRadius = 10
        borderView.backgroundColor = UIColor.white

        verticalStackView.axis = .vertical
        verticalStackView.spacing = UIConstants.verticalStackSpacing

        deleteButton.setImage(
            Asset.Icons.delete.image
                .resizeImageVerticallyIfNeeded(fitSize: UIConstants.buttonImageSize)
                .addInsetsInside(inset: UIConstants.buttonImageInset),
            for: .normal
        )
        deleteButton.setTitle(Loc.CredentialsView.Title.delete, for: .normal)
        deleteButton.setTitleColor(.darkGray, for: .normal)

        editButton.setImage(
            Asset.Icons.editing.image
                .resizeImageVerticallyIfNeeded(fitSize: UIConstants.buttonImageSize)
                .addInsetsInside(inset: UIConstants.buttonImageInset),
            for: .normal
        )
        editButton.setTitle(Loc.CredentialsView.Title.edit, for: .normal)
        editButton.setTitleColor(.darkGray, for: .normal)

        setupConstraints()
    }

    private func setupConstraints() {
        borderView.dsl.makeEqualToSuperview(
            insets: UIEdgeInsets(side: .sixteen)
        )

        isActiveTitleSwitchView.dsl.makeConstraints { make in
            [
                make.top.constraint(equalTo: borderView.topAnchor, constant: .eight),
                make.right.constraint(equalTo: borderView.rightAnchor, constant: -.eight),
            ]
        }

        editButton.dsl.makeConstraints { make in
            [
                make.centerY.constraint(equalTo: isActiveTitleSwitchView.dsl.centerY),
                make.left.constraint(equalTo: make.superview.leftAnchor, constant: .eight),
            ]
        }

        deleteButton.dsl.makeConstraints { make in
            [
                make.centerY.constraint(equalTo: editButton.dsl.centerY),
                make.left.constraint(equalTo: editButton.dsl.right, constant: .eight),
            ]
        }

        verticalStackView.dsl.makeConstraints { make in
            [
                make.top.constraint(equalTo: isActiveTitleSwitchView.dsl.bottom, constant: .sixteen),
                make.bottom.constraint(lessThanOrEqualTo: borderView.dsl.bottom, constant: -.eight),
                make.left.constraint(equalTo: make.superview.dsl.left, constant: .eight),
                make.right.constraint(equalTo: make.superview.dsl.right, constant: -.eight),
            ]
        }
    }
}

extension CredentialsView: ConfigurableAndReusable {
    private func saveCreds() {
        let newCreds = SdkCredentials(
            uuid: modelUuid,
            name: nameInfoView.getTextFieldText(),
            description: descriptionInfoView.getTextFieldText(),
            publicKey: publicKeyInfoView.getTextFieldText(),
            terminalKey: terminalKeyInfoView.getTextFieldText(),
            terminalPassword: terminalPasswordInfoView.getTextFieldText(),
            customerKey: customerKeyInfoView.getTextFieldText()
        )

        viewOutput?.onSaveAfterEdit(
            credentialsViewInput: self,
            newCreds: newCreds,
            credsUuid: modelUuid
        )
    }

    @objc private func onEditPressed() {
        isEditing.toggle()

        editButton.setTitle(
            isEditing
                ? Loc.CredentialsView.Title.save
                : Loc.CredentialsView.Title.edit,
            for: .normal
        )

        let editImage = isEditing ? Asset.Icons.done.image : Asset.Icons.editing.image

        editButton.setImage(
            editImage
                .resizeImageVerticallyIfNeeded(fitSize: UIConstants.buttonImageSize)
                .addInsetsInside(inset: UIConstants.buttonImageInset),
            for: .normal
        )

        if isEditing {
            isActiveTitleSwitchView.setSwitchingEnabled(to: !isEditing)
            viewOutput?.onEditing(credentialsViewInput: self)
        } else {
            if let model = isActiveSwitchModel {
                isActiveTitleSwitchView.configure(model: model)
            }
            saveCreds()
        }

        verticalStackView.arrangedSubviews
            .compactMap { $0 as? VerticalEditableView }
            .forEach {
                $0.changeIsEditable(to: isEditing)
            }
    }

    @objc private func onDeletePressed() {
        viewOutput?.onDelete(credentialsViewInput: self, credsUuid: modelUuid)
    }

    func configure(model: CredentialsView.Model) {
        viewOutput = model.viewOutput
        modelUuid = model.creds.uuid
        isActiveSwitchModel = model.isActiveSwitchModel

        deleteButton.isHidden = !model.shouldShowDeleteButton

        editButton.addTarget(self, action: #selector(onEditPressed), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(onDeletePressed), for: .touchUpInside)

        [isActiveTitleSwitchView]
            .forEach {
                $0.apply(style: .basic)
                $0.layoutIfNeeded()
            }

        isActiveTitleSwitchView.configure(
            model: model.isActiveSwitchModel
        )

        nameInfoView.configure(
            model: VerticalEditableView.Model(
                labelText: Loc.CredentialsView.Title.name,
                textFieldText: model.name
            )
        )
        descriptionInfoView.configure(
            model: VerticalEditableView.Model(
                labelText: Loc.CredentialsView.Title.descriptiom,
                textFieldText: model.description
            )
        )
        terminalKeyInfoView.configure(
            model: VerticalEditableView.Model(
                labelText: Loc.CredentialsView.Title.terminalKey,
                textFieldText: model.creds.terminalKey
            )
        )
        terminalPasswordInfoView.configure(
            model: VerticalEditableView.Model(
                labelText: Loc.CredentialsView.Title.terminalPassword,
                textFieldText: model.creds.terminalPassword
            )
        )
        publicKeyInfoView.configure(
            model: VerticalEditableView.Model(
                labelText: Loc.CredentialsView.Title.publicKey,
                textFieldText: model.creds.publicKey
            )
        )
        customerKeyInfoView.configure(
            model: VerticalEditableView.Model(
                labelText: Loc.CredentialsView.Title.customerKey,
                textFieldText: model.creds.customerKey
            )
        )

        verticalStackView.arrangedSubviews
            .compactMap { $0 as? VerticalEditableView }
            .forEach {
                $0.apply(style: .basic)
                $0.changeIsEditable(to: isEditing)
                $0.layoutIfNeeded()
            }
    }

    func prepareForReuse() {
        modelUuid = ""
        viewOutput = nil
        isActiveSwitchModel = nil
        deleteButton.isHidden = false

        nameInfoView.prepareForReuse()
        descriptionInfoView.prepareForReuse()
        terminalKeyInfoView.prepareForReuse()
        terminalPasswordInfoView.prepareForReuse()
        publicKeyInfoView.prepareForReuse()
        customerKeyInfoView.prepareForReuse()
    }
}
