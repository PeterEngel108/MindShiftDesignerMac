import Foundation

struct TtsService {
    static func generate(text: String, apiKey: String, voiceId: String, speed: Double) async throws -> Data {
        guard let encodedVoiceId = voiceId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: "https://api.elevenlabs.io/v1/text-to-speech/\(encodedVoiceId)")
        else {
            throw NSError(domain: "TTS", code: -1, userInfo: [NSLocalizedDescriptionKey: "Ungültige Voice-ID"])
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "xi-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "text": text,
            "model_id": "eleven_multilingual_v2",
            "voice_settings": ["stability": 0.5, "similarity_boost": 0.75, "speed": speed]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let msg = String(data: data, encoding: .utf8) ?? "Unbekannter Fehler"
            throw NSError(domain: "TTS", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "HTTP-Fehler: \(msg.prefix(200))"])
        }
        return data
    }
}
