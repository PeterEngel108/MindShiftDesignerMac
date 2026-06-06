import Foundation

@Observable
class AppSettings {
    static let shared = AppSettings()

    var elevenLabsApiKey: String  { didSet { save() } }
    var elevenLabsVoiceId: String { didSet { save() } }
    var ttsSpeed: Double          { didSet { save() } }

    private init() {
        let d = UserDefaults.standard
        elevenLabsApiKey  = d.string(forKey: "elevenLabsApiKey")  ?? ""
        elevenLabsVoiceId = d.string(forKey: "elevenLabsVoiceId") ?? ""
        let speed = d.double(forKey: "ttsSpeed")
        ttsSpeed = speed == 0 ? 0.9 : speed
    }

    private func save() {
        let d = UserDefaults.standard
        d.set(elevenLabsApiKey,  forKey: "elevenLabsApiKey")
        d.set(elevenLabsVoiceId, forKey: "elevenLabsVoiceId")
        d.set(ttsSpeed,          forKey: "ttsSpeed")
    }
}
