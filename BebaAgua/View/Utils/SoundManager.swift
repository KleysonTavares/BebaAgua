//
//  SoundManager.swift
//  BebaAgua
//
//  Created by Kleyson Tavares on 24/07/25.
//

import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    private var players: [String: AVAudioPlayer] = [:]
    private init() {}

    func prepare(sounds: [String]) {
        for sound in sounds {
            if let url = Bundle.main.url(forResource: sound, withExtension: "mp3") ??
                Bundle.main.url(forResource: sound, withExtension: "caf") {
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.prepareToPlay()
                    players[sound] = player
                } catch {
                    print("Erro ao pré-carregar som \(sound): \(error)")
                }
            }
        }
    }

    func playSound(named name: String) {
        if let player = players[name] {
            if player.isPlaying { player.stop() }
            player.currentTime = 0
            player.play()
        } else {
            if let url = Bundle.main.url(forResource: name, withExtension: "mp3") ??
                Bundle.main.url(forResource: name, withExtension: "caf") {
                try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
                try? AVAudioSession.sharedInstance().setActive(true)
                let player = try? AVAudioPlayer(contentsOf: url)
                player?.volume = 0.2
                player?.play()
            }
        }
    }
}
