//
//  SoundManager.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 24/07/25.
//

import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    private var player: AVAudioPlayer?

    private init() {}

    func playSound(named name: String, withExtension ext: String = "mp3", volume: Float = 1.0) {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            print("Som \(name).\(ext) não encontrado.")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.volume = 0.2
            player?.prepareToPlay()
            player?.play()
        } catch {
            print("Erro ao tocar som: \(error.localizedDescription)")
        }
    }
}
