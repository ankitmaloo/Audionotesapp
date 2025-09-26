import Foundation

struct OpenAIConfig: Sendable {
    var baseURL: String
    var apiKey: String
    var transcriptionModel: String
    var textModel: String
}

enum OpenAIServiceError: Error, LocalizedError {
    case missingAPIKey
    case invalidURL
    case requestFailed(String)
    case decodingFailed
    case emptyResponse

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "OpenAI API key is missing. Add it in Settings."
        case .invalidURL:
            return "Invalid OpenAI base URL."
        case .requestFailed(let message):
            return message
        case .decodingFailed:
            return "Failed to decode response from OpenAI."
        case .emptyResponse:
            return "OpenAI returned an empty response."
        }
    }
}

struct TranscriptionSegment: Decodable, Sendable {
    let start: Double
    let end: Double
    let text: String
}

struct TranscriptionResult: Sendable {
    let text: String
    let segments: [TranscriptionSegment]

    var timestampedText: String {
        if segments.isEmpty {
            return text
        }
        func fmt(_ t: Double) -> String {
            let total = Int(t.rounded())
            let h = total / 3600
            let m = (total % 3600) / 60
            let s = total % 60
            if h > 0 { return String(format: "%d:%02d:%02d", h, m, s) }
            return String(format: "%02d:%02d", m, s)
        }
        return segments.map { seg in
            "[\(fmt(seg.start))–\(fmt(seg.end))] \(seg.text)"
        }.joined(separator: "\n")
    }
}

actor OpenAIService {
    func testConnection(config: OpenAIConfig) async throws -> String {
        guard !config.apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw OpenAIServiceError.missingAPIKey
        }
        let base = normalizedBase(config.baseURL, defaultBase: "https://api.openai.com/v1")
        guard let url = URL(string: base + "/responses") else { throw OpenAIServiceError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(config.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        struct Body: Encodable { let model: String; let input: String; let temperature: Double }
        let body = Body(model: config.textModel.isEmpty ? "gpt-5" : config.textModel, input: "ping", temperature: 0)
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw mapNetworkError(error)
        }
        if let http = response as? HTTPURLResponse, http.statusCode >= 400 {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw OpenAIServiceError.requestFailed("HTTP \(http.statusCode): \(message)")
        }

        struct ResponsesAPIResponse: Decodable {
            struct OutputItem: Decodable {
                struct ContentItem: Decodable { let type: String?; let text: String? }
                let content: [ContentItem]?
            }
            let output: [OutputItem]?
        }
        guard let top = try? JSONDecoder().decode(ResponsesAPIResponse.self, from: data),
              let text = top.output?.first?.content?.first?.text, !text.isEmpty else {
            throw OpenAIServiceError.decodingFailed
        }
        return text
    }
    private func normalizedBase(_ raw: String, defaultBase: String) -> String {
        var s = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.isEmpty { return defaultBase }
        if !(s.lowercased().hasPrefix("http://") || s.lowercased().hasPrefix("https://")) {
            s = "https://" + s
        }
        // Drop a trailing slash to avoid accidental double slashes
        while s.hasSuffix("/") { s.removeLast() }
        return s
    }

    private func mapNetworkError(_ error: Error) -> OpenAIServiceError {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .cannotFindHost, .cannotConnectToHost:
                return .requestFailed("Cannot resolve or connect to host. Check the Base URL in Settings.")
            case .notConnectedToInternet, .networkConnectionLost, .timedOut:
                return .requestFailed("Network issue. Check your connection and try again.")
            default:
                return .requestFailed(urlError.localizedDescription)
            }
        }
        return .requestFailed(error.localizedDescription)
    }
    func transcribeAudio(at fileURL: URL, config: OpenAIConfig, prompt: String? = nil) async throws -> String {
        guard !config.apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw OpenAIServiceError.missingAPIKey
        }
        let base = normalizedBase(config.baseURL, defaultBase: "https://api.openai.com/v1")
        guard let url = URL(string: base + "/audio/transcriptions") else { throw OpenAIServiceError.invalidURL }

        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(config.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        // Build multipart body
        var body = Data()

        func appendFormField(name: String, value: String) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }

        // model
        appendFormField(name: "model", value: config.transcriptionModel.isEmpty ? "whisper-1" : config.transcriptionModel)
        // optional prompt (not required for basic usage)
        if let prompt, !prompt.isEmpty {
            appendFormField(name: "prompt", value: prompt)
        }
        // Using whisper-1 by default; verbose_json returns segments with timestamps

        // file part
        let filename = fileURL.lastPathComponent
        let fileData = try Data(contentsOf: fileURL)
        let mimeType = "audio/wav" // Files are saved as .wav

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n".data(using: .utf8)!)

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw mapNetworkError(error)
        }
        if let http = response as? HTTPURLResponse, http.statusCode >= 400 {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw OpenAIServiceError.requestFailed("HTTP \(http.statusCode): \(message)")
        }

        struct TranscriptionResponse: Decodable { let text: String }
        let decoded = try? JSONDecoder().decode(TranscriptionResponse.self, from: data)
        guard let text = decoded?.text, !text.isEmpty else {
            throw OpenAIServiceError.emptyResponse
        }
        return text
    }

    func transcribeAudioDetailed(at fileURL: URL, config: OpenAIConfig, prompt: String? = nil) async throws -> TranscriptionResult {
        guard !config.apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw OpenAIServiceError.missingAPIKey
        }
        let base = normalizedBase(config.baseURL, defaultBase: "https://api.openai.com/v1")
        guard let url = URL(string: base + "/audio/transcriptions") else { throw OpenAIServiceError.invalidURL }

        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(config.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        func appendFormField(name: String, value: String) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        appendFormField(name: "model", value: config.transcriptionModel.isEmpty ? "whisper-1" : config.transcriptionModel)
        if let prompt, !prompt.isEmpty { appendFormField(name: "prompt", value: prompt) }
        // Request verbose JSON to include segments with start/end timestamps
        appendFormField(name: "response_format", value: "verbose_json")
        appendFormField(name: "timestamp_granularities[]", value: "segment")

        let filename = fileURL.lastPathComponent
        let fileData = try Data(contentsOf: fileURL)
        let mimeType = "audio/wav"
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw mapNetworkError(error)
        }
        if let http = response as? HTTPURLResponse, http.statusCode >= 400 {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw OpenAIServiceError.requestFailed("HTTP \(http.statusCode): \(message)")
        }

        struct DetailedResponse: Decodable {
            let text: String
            let segments: [TranscriptionSegment]?
        }
        guard let decoded = try? JSONDecoder().decode(DetailedResponse.self, from: data) else {
            throw OpenAIServiceError.decodingFailed
        }
        let segs = decoded.segments ?? []
        return TranscriptionResult(text: decoded.text, segments: segs)
    }

    func extractActionItems(from transcript: String, config: OpenAIConfig) async throws -> (summary: String, actionItems: [String]) {
        guard !config.apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw OpenAIServiceError.missingAPIKey
        }
        let base = normalizedBase(config.baseURL, defaultBase: "https://api.openai.com/v1")
        guard let url = URL(string: base + "/responses") else { throw OpenAIServiceError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(config.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        struct ResponsesRequestBody: Encodable {
            let model: String
            let input: String
            let temperature: Double
        }

        let model = config.textModel.isEmpty ? "gpt-5" : config.textModel
        let prompt = """
        You are a note assistant. Summarize the transcripts concisely and extract clear, actionable items.
        Return ONLY a JSON object with keys: \"summary\" (string) and \"action_items\" (array of strings). No extra text.

        Transcript:\n\(transcript)
        """
        let body = ResponsesRequestBody(model: model, input: prompt, temperature: 0)
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw mapNetworkError(error)
        }
        if let http = response as? HTTPURLResponse, http.statusCode >= 400 {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw OpenAIServiceError.requestFailed("HTTP \(http.statusCode): \(message)")
        }

        struct ResponsesAPIResponse: Decodable {
            struct OutputItem: Decodable {
                struct ContentItem: Decodable { let type: String?; let text: String? }
                let content: [ContentItem]?
            }
            let output: [OutputItem]?
        }
        guard let top = try? JSONDecoder().decode(ResponsesAPIResponse.self, from: data),
              let text = top.output?.first?.content?.first?.text, !text.isEmpty else {
            throw OpenAIServiceError.decodingFailed
        }

        // Try to decode the assistant's JSON content
        struct Parsed: Decodable { let summary: String; let action_items: [String] }
        if let jsonData = text.data(using: .utf8),
           let parsed = try? JSONDecoder().decode(Parsed.self, from: jsonData) {
            return (summary: parsed.summary, actionItems: parsed.action_items)
        }

        // Fallback: return completion text as summary, no items parsed
        return (summary: text, actionItems: [])
    }
}
