//
//  VGSBlinkCardHandler.swift
//  VGSBlinkCardCollector
//

import Foundation
#if os(iOS)
import SwiftUI
import UIKit
#endif

#if canImport(BlinkCard) && canImport(BlinkCardUX)
import BlinkCard
import BlinkCardUX
#if !COCOAPODS
import VGSCollectSDK
#endif

@available(iOS 16.0, *)
internal struct VGSBlinkCardConfiguration {
  var extractOwner = true
  var extractExpiryDate = true
  var extractCvv = true
  var extractIban = true
  var allowInvalidCardNumber = false
  var showOnboardingInfo = true
  var showIntroductionDialog = true

  var extractionSettings: ExtractionSettings {
    ExtractionSettings(
      extractIban: extractIban,
      extractExpiryDate: extractExpiryDate,
      extractCardholderName: extractOwner,
      extractCvv: extractCvv,
      extractInvalidCardNumber: allowInvalidCardNumber
    )
  }

  var scanningSettings: ScanningSettings {
    ScanningSettings(extractionSettings: extractionSettings)
  }

  var sessionSettings: BlinkCardSessionSettings {
    BlinkCardSessionSettings(inputImageSource: .video, scanningSettings: scanningSettings)
  }

  var uxSettings: ScanningUXSettings {
    ScanningUXSettings(
      showIntroductionAlert: showIntroductionDialog,
      showHelpButton: showOnboardingInfo
    )
  }
}

@available(iOS 16.0, *)
internal enum VGSBlinkCardErrorCode: Int {
  case sdkInitializationFailed = -1
}

/// BlinkCard wrapper, manages communication between public API and BlinkCard.
@available(iOS 16.0, *)
@MainActor
internal class VGSBlinkCardHandler: NSObject, VGSScanHandlerProtocol {
  /// VGS BlinkCard Controller Delegate.
  weak var delegate: VGSBlinkCardControllerDelegate?
  /// BlinkCard scanner UIViewController.
  weak var view: UIViewController?

  let licenseKey: String
  let errorCallback: (NSInteger) -> Void
  var configuration = VGSBlinkCardConfiguration()
  private var didFinishCurrentScan = false

  /// Initialization
  /// - Parameters:
  ///   - licenseKey: key required for BlinkCard SDK usage.
  ///   - errorCallback: Error callback with safe scanner initialization error code, triggered only when an error occurs.
  required init(licenseKey: String, errorCallback: @escaping ((NSInteger) -> Void)) {
    self.licenseKey = licenseKey
    self.errorCallback = errorCallback
    super.init()
  }

  /// Setup BlinkCard params and present scanner.
  func presentScanVC(on viewController: UIViewController, animated: Bool, modalPresentationStyle: UIModalPresentationStyle, completion: (() -> Void)?) {
    didFinishCurrentScan = false
    let scannerView = VGSBlinkCardScannerView(
      licenseKey: licenseKey,
      configuration: configuration,
      onResult: { [weak self] result in
        self?.handleScanResult(result)
      },
      onCancel: { [weak self] in
        self?.handleScanCancel()
      },
      onError: { [weak self] error in
        self?.handleScanError(error)
      }
    )
    let hostingController = UIHostingController(rootView: scannerView)
    hostingController.modalPresentationStyle = modalPresentationStyle
    self.view = hostingController
    viewController.present(hostingController, animated: animated, completion: completion)
  }

  /// Dismiss BlinkCard scanner.
  func dismissScanVC(animated: Bool, completion: (() -> Void)?) {
    view?.dismiss(animated: animated, completion: completion)
  }

  /// BlinkCard v3000 uses package localization resources. Retained for source compatibility.
  static func setCustomLocalization(fileName: String) {}

  static func mapScanResult(_ result: VGSBlinkCardScanResult) -> [VGSBlinkCardDataType: String] {
    VGSBlinkCardResultMapper.mapScanResult(result)
  }

  static func mapScanResult(_ result: BlinkCardScanningResult) -> [VGSBlinkCardDataType: String] {
    VGSBlinkCardResultMapper.mapScanResult(VGSBlinkCardScanResult(result))
  }

  private func handleScanResult(_ result: BlinkCardScanningResult) {
    guard !didFinishCurrentScan else { return }
    didFinishCurrentScan = true

    let dataDict = Self.mapScanResult(result)

    for dataType in VGSBlinkCardDataType.allCases {
      if let textfield = delegate?.textFieldForScannedData(type: dataType), let value = dataDict[dataType] {
        textfield.setText(value)
        if dataType == .cardNumber, let form = textfield.configuration?.vgsCollector {
          VGSAnalyticsClient.shared.trackFormEvent(form.formAnalyticsDetails, type: .scan, status: .success, extraData: ["scannerType": "BlinkCard"])
        }
      }
    }

    delegate?.userDidFinishScan()
  }

  private func handleScanCancel() {
    guard !didFinishCurrentScan else { return }
    didFinishCurrentScan = true
    VGSAnalyticsClient.shared.trackEvent(.scan, status: .cancel, extraData: ["scannerType": "BlinkCard"])
    delegate?.userDidCancelScan()
  }

  private func handleScanError(_ error: Error) {
    guard !didFinishCurrentScan else { return }
    didFinishCurrentScan = true
    let code = (error as NSError).code
    let safeCode = code == 0 ? VGSBlinkCardErrorCode.sdkInitializationFailed.rawValue : code
    VGSAnalyticsClient.shared.trackEvent(.scan, status: .failed, extraData: ["scannerType": "BlinkCard", "errorCode": safeCode])
    errorCallback(safeCode)
  }
}

@available(iOS 16.0, *)
internal struct VGSBlinkCardScannerView: View {
  let licenseKey: String
  let configuration: VGSBlinkCardConfiguration
  let onResult: @MainActor (BlinkCardScanningResult) -> Void
  let onCancel: @MainActor () -> Void
  let onError: @MainActor (Error) -> Void

  @State private var viewModel: BlinkCardUXModel?
  @State private var isLoading = true

  var body: some View {
    Group {
      if let viewModel {
        VGSBlinkCardScannerContentView(viewModel: viewModel, onResult: onResult, onCancel: onCancel)
      } else {
        ProgressView()
      }
    }
    .task {
      await setupScannerIfNeeded()
    }
  }

  @MainActor
  private func setupScannerIfNeeded() async {
    guard viewModel == nil, isLoading else { return }
    isLoading = true

    do {
      let settings = BlinkCardSdkSettings(licenseKey: licenseKey, downloadResources: true)
      let sdk = try await BlinkCardSdk.createBlinkCardSdk(withSettings: settings)
      let analyzer = try await BlinkCardAnalyzer(
        sdk: sdk,
        blinkCardSessionSettings: configuration.sessionSettings,
        eventStream: BlinkCardEventStream()
      )
      let model = BlinkCardUXModel(analyzer: analyzer, uxSettings: configuration.uxSettings)
      self.viewModel = model
      self.isLoading = false
    } catch {
      self.isLoading = false
      onError(error)
    }
  }
}

@available(iOS 16.0, *)
private struct VGSBlinkCardScannerContentView: View {
  @ObservedObject var viewModel: BlinkCardUXModel
  let onResult: @MainActor (BlinkCardScanningResult) -> Void
  let onCancel: @MainActor () -> Void

  var body: some View {
    BlinkCardUXView(viewModel: viewModel)
      .onReceive(viewModel.$result.compactMap { $0 }) { resultState in
        if let result = resultState.scanningResult {
          onResult(result)
        } else {
          onCancel()
        }
      }
  }
}
#endif
