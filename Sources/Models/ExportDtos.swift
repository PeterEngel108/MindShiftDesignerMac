import Foundation

struct ExportPackage: Codable {
    let exportedAt: Int64
    let categories: [CategoryDto]
    let suggestions: [SuggestionDto]
    let blocks: [BlockDto]
    let blockItems: [BlockItemDto]
    let sections: [SectionDto]
    let sectionBlocks: [SectionBlockDto]
    let programs: [ProgramDto]
    let programSections: [ProgramSectionDto]
    let programSectionBlocks: [ProgramSectionBlockDto]
    let disabledItems: [DisabledItemDto]
    let sectionBackgrounds: [SectionBackgroundDto]
}

struct CategoryDto: Codable {
    let id: Int64
    let name: String
    let colorHex: String
    let sortOrder: Int
    let isProtected: Bool
    let parentId: Int64?
}

struct SuggestionDto: Codable {
    let id: Int64
    let title: String
    let category: String
    let subcategory: String?
    let audioFileName: String?
    let durationMs: Int64
    let source: String
    let text: String?
    let elevenLabsVoiceId: String?
    let createdAt: Int64
}

struct BlockDto: Codable {
    let id: Int64
    let title: String
    let createdAt: Int64
}

struct BlockItemDto: Codable {
    let id: Int64
    let blockId: Int64
    let suggestionId: Int64?
    let position: Int
    let pauseBeforeMs: Int64
    let pauseAfterMs: Int64
    let pauseAfterMatchesAudio: Bool
    let repetitions: Int
    let silenceDurationMs: Int64?
    let pauseAfterExtraMs: Int64
}

struct SectionDto: Codable {
    let id: Int64
    let title: String
    let createdAt: Int64
}

struct SectionBlockDto: Codable {
    let id: Int64
    let sectionId: Int64
    let blockId: Int64
    let position: Int
}

struct ProgramDto: Codable {
    let id: Int64
    let title: String
    let createdAt: Int64
}

struct ProgramSectionDto: Codable {
    let id: Int64
    let programId: Int64
    let sectionId: Int64
    let position: Int
}

struct ProgramSectionBlockDto: Codable {
    let id: Int64
    let programId: Int64
    let sectionId: Int64
    let blockId: Int64
    let position: Int
    let isEnabled: Bool
}

struct DisabledItemDto: Codable {
    let programSectionBlockId: Int64
    let blockItemId: Int64
}

struct SectionBackgroundDto: Codable {
    let programId: Int64
    let sectionId: Int64
    let type: String
    let musicFileName: String?
    let ambientType: String?
    let binauralBeatHz: Int?
    let volume: Float?
    let fadeInMs: Int64?
    let fadeOutMs: Int64?
}
