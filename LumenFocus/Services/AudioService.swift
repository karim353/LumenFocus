import Foundation
import AVFoundation

class AudioService: ObservableObject {
    static let shared = AudioService()
    
    private var audioPlayer: AVAudioPlayer?
    private var backgroundMusicPlayer: AVAudioPlayer?
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func playSound(_ soundName: String, volume: Float = 1.0) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "wav") else {
            print("Sound file not found: \(soundName)")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.volume = volume
            audioPlayer?.play()
        } catch {
            print("Failed to play sound: \(error)")
        }
    }
    
    func playPhaseCompleteSound(volume: Float = 1.0) {
        // Play a success sound for phase completion
        playSound("phase_complete", volume: volume)
    }
    
    func playSessionCompleteSound(volume: Float = 1.0) {
        // Play a celebration sound for session completion
        playSound("session_complete", volume: volume)
    }
    
    func playTickSound(volume: Float = 0.3) {
        // Play a subtle tick sound for timer updates
        playSound("tick", volume: volume)
    }
    
    func stopAllAudio() {
        audioPlayer?.stop()
        backgroundMusicPlayer?.stop()
    }
    
    func setVolume(_ volume: Float) {
        audioPlayer?.volume = volume
        backgroundMusicPlayer?.volume = volume
    }
    
    func duckBackgroundMusic() {
        // Lower the volume of background music temporarily
        backgroundMusicPlayer?.volume = 0.3
    }
    
    func restoreBackgroundMusic() {
        // Restore the volume of background music
        backgroundMusicPlayer?.volume = 1.0
    }
}
