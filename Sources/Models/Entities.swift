import Foundation

// ── Wizard-Hilfsklassen (leben nur im Assistenten) ────────────────────────────

@Observable
class SuggestionEntry: Identifiable {
    let id = UUID()
    var title: String = ""
    var text: String = ""
    var isGeneratingAudio: Bool = false
    var audioStatus: String = ""
    var audioData: Data? = nil
    var audioFileName: String? = nil

    var hasAudio: Bool { audioData != nil }
}

@Observable
class BlockEntry: Identifiable {
    let id = UUID()
    var title: String = ""
    var isExpanded: Bool = true
    var isAddingSuggestion: Bool = false
    var newSuggestionTitle: String = ""
    var newSuggestionText: String = ""
    var suggestions: [SuggestionEntry] = []
}

@Observable
class SectionEntry: Identifiable {
    let id = UUID()
    var title: String
    var isAddingBlock: Bool = false
    var newBlockTitle: String = ""
    var blocks: [BlockEntry] = []

    init(title: String) {
        self.title = title
    }
}

// ── Persistente Entitäten ─────────────────────────────────────────────────────

struct MsSuggestion: Identifiable {
    var id: Int64
    var title: String
    var text: String
    var createdAt: Int64 = Int64(Date().timeIntervalSince1970 * 1000)
}

struct MsBlockItem: Identifiable {
    var id: Int64
    var blockId: Int64
    var suggestionId: Int64?
    var position: Int
    var pauseBeforeMs: Int64 = 500
    var pauseAfterMs: Int64 = 1000
    var pauseAfterMatchesAudio: Bool = false
    var repetitions: Int = 1
    var silenceDurationMs: Int64? = nil
    var pauseAfterExtraMs: Int64 = 0
}

struct MsBlock: Identifiable {
    var id: Int64
    var title: String
    var createdAt: Int64 = Int64(Date().timeIntervalSince1970 * 1000)
    var items: [MsBlockItem] = []
}

struct MsSection: Identifiable {
    var id: Int64
    var title: String
    var sortOrder: Int = 0
    var createdAt: Int64 = Int64(Date().timeIntervalSince1970 * 1000)
}

struct MsProgram: Identifiable {
    var id: Int64
    var title: String
    var sortOrder: Int = 0
    var createdAt: Int64 = Int64(Date().timeIntervalSince1970 * 1000)
}

struct MsProgramSection: Identifiable {
    var id: Int64
    var programId: Int64
    var sectionId: Int64
    var position: Int
}

struct MsProgramSectionBlock: Identifiable {
    var id: Int64
    var programId: Int64
    var sectionId: Int64
    var blockId: Int64
    var position: Int
    var isEnabled: Bool = true
}

struct MsCategory: Identifiable {
    var id: Int64
    var name: String
    var colorHex: String = "#9C27B0"
    var sortOrder: Int = 0
    var isProtected: Bool = false
    var parentId: Int64? = nil
}

// ── AppData Singleton ─────────────────────────────────────────────────────────

@Observable
class AppData {
    static let shared = AppData()

    private var nextIdValue: Int64 = 1000
    func nextId() -> Int64 { defer { nextIdValue += 1 }; return nextIdValue }

    var programs: [MsProgram] = []
    var sections: [MsSection] = []
    var blocks: [MsBlock] = []
    var suggestions: [MsSuggestion] = []
    var categories: [MsCategory] = []
    var programSections: [MsProgramSection] = []
    var programSectionBlocks: [MsProgramSectionBlock] = []

    private init() {
        categories.append(MsCategory(id: nextId(), name: "Allgemein"))
    }
}
