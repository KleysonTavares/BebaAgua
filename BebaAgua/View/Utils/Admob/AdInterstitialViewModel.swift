//
//  AdInterstitialViewModel.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 24/07/25.
//

import GoogleMobileAds
import SwiftUI

class AdInterstitialViewModel: NSObject, FullScreenContentDelegate, ObservableObject {
    private var interstitial: InterstitialAd?
    private let adUnitID = "ca-app-pub-3940256099942544/4411468910" // ID de teste do Google
    
    @Published var isAdReady: Bool = false
    @Published var adDidDismiss = false

    override init() {
        super.init()
        loadAd()
    }

    func loadAd() {
        let request = Request()
        InterstitialAd.load(with: adUnitID, request: request) { [weak self] ad, error in
            guard let self = self else { return }
            if let error = error {
                print("Erro ao carregar intersticial: \(error.localizedDescription)")
                return
            }
            self.interstitial = ad
            self.interstitial?.fullScreenContentDelegate = self
            self.isAdReady = true
        }
    }

    func showAd(from root: UIViewController) {
        guard let ad = interstitial else {
            return
        }
        ad.present(from: root)
        isAdReady = false // para evitar exibir novamente até recarregar
    }

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        adDidDismiss = true
        loadAd() // Carrega novamente após fechar
    }
}
