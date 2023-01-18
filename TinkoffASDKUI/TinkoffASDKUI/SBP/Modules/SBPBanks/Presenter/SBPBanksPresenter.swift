//
//  SBPBanksPresenter.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 21.12.2022.
//

import Foundation
import TinkoffASDKCore

private enum SBPBanksScreenType {
    case startEmpty
    case startWithData
}

final class SBPBanksPresenter: ISBPBanksPresenter, ISBPBanksModuleInput {

    // Dependencies
    weak var view: ISBPBanksViewController?
    private let router: ISBPBanksRouter

    private let paymentService: ISBPPaymentServiceNew?
    private let banksService: ISBPBanksService
    private let bankAppChecker: ISBPBankAppChecker
    private let bankAppOpener: ISBPBankAppOpener
    private let cellPresentersAssembly: ISBPBankCellPresenterNewAssembly

    // Properties
    private var screenType: SBPBanksScreenType = .startEmpty
    private var allBanks = [SBPBank]()
    private var allBanksCellPresenters = [ISBPBankCellNewPresenter]()
    private var filteredBanksCellPresenters = [ISBPBankCellNewPresenter]()

    private var lastSearchedText = ""
    private var qrPayload: GetQRPayload?

    // MARK: - Initialization

    init(
        router: ISBPBanksRouter,
        paymentService: ISBPPaymentServiceNew?,
        banksService: ISBPBanksService,
        bankAppChecker: ISBPBankAppChecker,
        bankAppOpener: ISBPBankAppOpener,
        cellPresentersAssembly: ISBPBankCellPresenterNewAssembly
    ) {
        self.router = router
        self.paymentService = paymentService
        self.banksService = banksService
        self.bankAppChecker = bankAppChecker
        self.bankAppOpener = bankAppOpener
        self.cellPresentersAssembly = cellPresentersAssembly
    }
}

// MARK: - ISBPBanksModuleInput

extension SBPBanksPresenter {
    func set(qrPayload: GetQRPayload?, banks: [SBPBank]) {
        self.qrPayload = qrPayload
        allBanks = banks
        screenType = .startWithData
    }
}

// MARK: - ISBPBanksPresenter

extension SBPBanksPresenter {
    func viewDidLoad() {
        switch screenType {
        case .startEmpty:
            view?.hideSearchBar()
            prepareAndShowSkeletonModels()
            loadQrPayloadAndBanks()
            view?.setupNavigationWithCloseButton()
        case .startWithData:
            setupScreen(with: allBanks)
            view?.setupNavigationWithBackButton()
        }
    }

    func closeButtonPressed() {
        router.closeScreen()
    }

    func prefetch(for rows: [Int]) {
        rows.forEach { cellPresenter(for: $0).startLoadingCellImageIfNeeded() }
    }

    func numberOfRows() -> Int {
        filteredBanksCellPresenters.count
    }

    func cellPresenter(for row: Int) -> ISBPBankCellNewPresenter {
        return filteredBanksCellPresenters[row]
    }

    func searchTextDidChange(to text: String) {
        let lowercasedText = text.lowercased()

        guard lastSearchedText != lowercasedText else { return }
        lastSearchedText = lowercasedText

        DispatchQueue.main.asyncDeduped(target: self, after: .searchDelay) { [weak self] in
            guard let self = self else { return }

            if lowercasedText.isEmpty {
                self.filteredBanksCellPresenters = self.allBanksCellPresenters
            } else {
                self.filteredBanksCellPresenters = self.allBanksCellPresenters.filter { $0.bankName.lowercased().contains(lowercasedText) }
            }
            self.view?.reloadTableView()
        }
    }

    func didSelectRow(at index: Int) {
        cellPresenter(for: index).action()
    }
}

// MARK: - Private methods

extension SBPBanksPresenter {
    private func prepareAndShowSkeletonModels() {
        allBanksCellPresenters = [SBPBankCellNewPresenter](repeatElement(cellPresentersAssembly.build(cellType: .skeleton), count: .skeletonsCount))
        filteredBanksCellPresenters = allBanksCellPresenters
        view?.reloadTableView()
    }

    private func clearCellModels() {
        allBanksCellPresenters = []
        filteredBanksCellPresenters = []
        view?.reloadTableView()
    }

    private func loadQrPayloadAndBanks() {
        paymentService?.loadPaymentQr(completion: { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(qrPayload):
                self.qrPayload = qrPayload
                self.loadBanks()
            case let .failure(error):
                DispatchQueue.main.async {
                    self.handleFailureLoad(error: error)
                }
            }
        })
    }

    private func loadBanks() {
        banksService.loadBanks { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                switch result {
                case let .success(banks):
                    self.handleSuccessLoaded(banks: banks)
                case let .failure(error):
                    self.handleFailureLoad(error: error)
                }
            }
        }
    }

    private func handleSuccessLoaded(banks: [SBPBank]) {
        allBanks = banks

        let preferredBanks = getPreferredBanks()
        if preferredBanks.isEmpty {
            view?.showSearchBar()
            allBanksCellPresenters = createCellPresenters(from: allBanks)
        } else {
            let bankButtonCellType: SBPBankCellNewType = .bankButton(
                imageAsset: Asset.Sbp.sbpLogo,
                name: Loc.Acquiring.SBPBanks.anotherBank
            )
            let otherBankCellPresenter = cellPresentersAssembly.build(cellType: bankButtonCellType, action: { [weak self] in
                guard let self = self else { return }

                let otherBanks = self.getNotPreferredBanks()
                self.router.show(banks: otherBanks, qrPayload: self.qrPayload)
            })
            allBanksCellPresenters = createCellPresenters(from: preferredBanks)
            allBanksCellPresenters.append(otherBankCellPresenter)
        }

        filteredBanksCellPresenters = allBanksCellPresenters
        view?.reloadTableView()
    }

    private func handleFailureLoad(error: Error) {
        switch (error as NSError).code {
        case NSURLErrorNotConnectedToInternet:
            viewShowNoNetworkStub()
        default:
            viewShowServerErrorStub()
        }
    }

    private func setupScreen(with banks: [SBPBank]) {
        allBanksCellPresenters = createCellPresenters(from: banks)
        filteredBanksCellPresenters = allBanksCellPresenters
        view?.reloadTableView()
    }

    private func createCellPresenters(from banks: [SBPBank]) -> [SBPBankCellNewPresenter] {
        guard let paymentUrl = URL(string: qrPayload?.qrCodeData ?? ""),
              let paymentId = qrPayload?.paymentId else { return [] }

        return banks.map { bank in
            cellPresentersAssembly.build(cellType: .bank(bank), action: { [weak self] in
                self?.bankAppOpener.openBankApp(url: paymentUrl, bank, completion: { isOpen in
                    isOpen ? self?.router.showPaymentSheet(paymentId: paymentId) : self?.router.showDidNotFindBankAppAlert()
                })
            })
        }
    }

    private func getPreferredBanks() -> [SBPBank] {
        bankAppChecker.bankAppsPreferredByMerchant(from: allBanks)
    }

    private func getNotPreferredBanks() -> [SBPBank] {
        let preferredBanks = getPreferredBanks()
        return allBanks.filter { bank in !preferredBanks.contains(where: { $0 == bank }) }
    }

    private func viewShowNoNetworkStub() {
        clearCellModels()
        view?.showStubView(mode: .noNetwork { [weak self] in
            self?.view?.hideStubView()
            self?.prepareAndShowSkeletonModels()
            self?.loadQrPayloadAndBanks()
        })
    }

    private func viewShowServerErrorStub() {
        clearCellModels()
        view?.showStubView(mode: .serverError { [weak self] in
            self?.router.closeScreen()
        })
    }
}

// MARK: - Constants

private extension Int {
    static let skeletonsCount = 7
}

private extension TimeInterval {
    static let searchDelay = 0.3
}