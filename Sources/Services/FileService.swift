import Foundation
import ZIPFoundation

struct FileService {
    private static let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.outputFormatting = [.prettyPrinted, .sortedKeys]
        return e
    }()
    private static let decoder = JSONDecoder()

    // ── Import ────────────────────────────────────────────────────────────────

    static func importFile(from url: URL, into data: AppData) throws {
        guard let archive = Archive(url: url, accessMode: .read) else {
            throw NSError(domain: "FileService", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Datei konnte nicht geöffnet werden."])
        }
        guard let entry = archive["data.json"] else {
            throw NSError(domain: "FileService", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Keine data.json in der Datei gefunden."])
        }
        var jsonData = Data()
        _ = try archive.extract(entry, consumer: { jsonData.append($0) })
        let pkg = try decoder.decode(ExportPackage.self, from: jsonData)
        applyImport(pkg, into: data)
    }

    // ── Wizard-Export ────────────────────────────────────────────────────────

    static func exportWizardProgram(title: String, sections: [SectionEntry], to url: URL) throws {
        var nextId: Int64 = 1
        func nid() -> Int64 { defer { nextId += 1 }; return nextId }

        let now = Int64(Date().timeIntervalSince1970 * 1000)
        let defCat = AppData.shared.categories.first?.name ?? "Allgemein"
        let categories = AppData.shared.categories.map {
            CategoryDto(id: $0.id, name: $0.name, colorHex: $0.colorHex,
                        sortOrder: $0.sortOrder, isProtected: $0.isProtected, parentId: $0.parentId)
        }

        var suggDtos   = [SuggestionDto]()
        var blockDtos  = [BlockDto]()
        var itemDtos   = [BlockItemDto]()
        var sectionDtos = [SectionDto]()
        var programDtos = [ProgramDto]()
        var psDtos     = [ProgramSectionDto]()
        var psbDtos    = [ProgramSectionBlockDto]()
        var audioFiles = [String: Data]()

        let programId = nid()
        programDtos.append(ProgramDto(id: programId, title: title, createdAt: now))

        for (sIdx, se) in sections.enumerated() {
            let sectionId = nid()
            sectionDtos.append(SectionDto(id: sectionId, title: se.title, createdAt: now))
            psDtos.append(ProgramSectionDto(id: nid(), programId: programId, sectionId: sectionId, position: sIdx))

            for (bIdx, be) in se.blocks.enumerated() {
                let blockId = nid()
                blockDtos.append(BlockDto(id: blockId, title: be.title, createdAt: now))
                psbDtos.append(ProgramSectionBlockDto(id: nid(), programId: programId,
                                                      sectionId: sectionId, blockId: blockId,
                                                      position: bIdx, isEnabled: true))

                for (iIdx, sugg) in be.suggestions.enumerated() {
                    let suggId = nid()
                    var audioFileName: String? = nil
                    var source = "TTS"
                    if let audioData = sugg.audioData, let fn = sugg.audioFileName {
                        let uniqueFn = makeUnique(fn, in: audioFiles)
                        audioFiles[uniqueFn] = audioData
                        audioFileName = "audio/\(uniqueFn)"
                        source = "RECORDED"
                    }
                    suggDtos.append(SuggestionDto(id: suggId, title: sugg.title, category: defCat,
                                                  subcategory: nil, audioFileName: audioFileName,
                                                  durationMs: 0, source: source,
                                                  text: sugg.text.isEmpty ? nil : sugg.text,
                                                  elevenLabsVoiceId: nil, createdAt: now))
                    itemDtos.append(BlockItemDto(id: nid(), blockId: blockId, suggestionId: suggId,
                                                 position: iIdx, pauseBeforeMs: 500, pauseAfterMs: 1000,
                                                 pauseAfterMatchesAudio: false, repetitions: 1,
                                                 silenceDurationMs: nil, pauseAfterExtraMs: 0))
                }
            }
        }

        let sectionBlocks = psbDtos
            .reduce(into: [(SectionBlockDto, (Int64, Int64))]()) { acc, p in
                let key = (p.sectionId, p.blockId)
                if !acc.contains(where: { $0.1 == key }) {
                    acc.append((SectionBlockDto(id: nextId + Int64(acc.count),
                                                sectionId: p.sectionId, blockId: p.blockId,
                                                position: p.position), key))
                }
            }
            .map(\.0)

        let pkg = ExportPackage(exportedAt: now, categories: categories, suggestions: suggDtos,
                                blocks: blockDtos, blockItems: itemDtos, sections: sectionDtos,
                                sectionBlocks: sectionBlocks, programs: programDtos,
                                programSections: psDtos, programSectionBlocks: psbDtos,
                                disabledItems: [], sectionBackgrounds: [])
        try writeZip(pkg: pkg, audioFiles: audioFiles, to: url)
    }

    // ── Einzel-Programm-Export ────────────────────────────────────────────────

    static func exportProgram(_ program: MsProgram, from data: AppData, to url: URL) throws {
        let now = Int64(Date().timeIntervalSince1970 * 1000)

        let psSections = data.programSections.filter { $0.programId == program.id }
        let sectionIds = Set(psSections.map(\.sectionId))
        let psBlocks   = data.programSectionBlocks.filter { $0.programId == program.id }
        let blockIds   = Set(psBlocks.map(\.blockId))

        let blocks     = data.blocks.filter { blockIds.contains($0.id) }
        let blockItems = blocks.flatMap(\.items)
        let suggIds    = Set(blockItems.compactMap(\.suggestionId))
        let suggestions = data.suggestions.filter { suggIds.contains($0.id) }
        let sections   = data.sections.filter { sectionIds.contains($0.id) }

        let categories  = data.categories.map {
            CategoryDto(id: $0.id, name: $0.name, colorHex: $0.colorHex,
                        sortOrder: $0.sortOrder, isProtected: $0.isProtected, parentId: $0.parentId)
        }
        let defCat = categories.first?.name ?? "Allgemein"

        let suggDtos   = suggestions.map { s in
            SuggestionDto(id: s.id, title: s.title, category: defCat, subcategory: nil,
                          audioFileName: nil, durationMs: 0, source: "TTS",
                          text: s.text.isEmpty ? nil : s.text, elevenLabsVoiceId: nil, createdAt: s.createdAt)
        }
        let blockDtos  = blocks.map { BlockDto(id: $0.id, title: $0.title, createdAt: $0.createdAt) }
        let itemDtos   = blockItems.map {
            BlockItemDto(id: $0.id, blockId: $0.blockId, suggestionId: $0.suggestionId,
                         position: $0.position, pauseBeforeMs: $0.pauseBeforeMs,
                         pauseAfterMs: $0.pauseAfterMs, pauseAfterMatchesAudio: $0.pauseAfterMatchesAudio,
                         repetitions: $0.repetitions, silenceDurationMs: $0.silenceDurationMs,
                         pauseAfterExtraMs: $0.pauseAfterExtraMs)
        }
        let sectionDtos = sections.map { SectionDto(id: $0.id, title: $0.title, createdAt: $0.createdAt) }
        let sectionBlocks = psBlocks
            .reduce(into: [(SectionBlockDto, (Int64, Int64))]()) { acc, p in
                let key = (p.sectionId, p.blockId)
                if !acc.contains(where: { $0.1 == key }) {
                    acc.append((SectionBlockDto(id: data.nextId(), sectionId: p.sectionId,
                                                blockId: p.blockId, position: p.position), key))
                }
            }
            .map(\.0)
        let programDto    = [ProgramDto(id: program.id, title: program.title, createdAt: program.createdAt)]
        let psDtos        = psSections.map { ProgramSectionDto(id: $0.id, programId: $0.programId, sectionId: $0.sectionId, position: $0.position) }
        let psbDtos       = psBlocks.map   { ProgramSectionBlockDto(id: $0.id, programId: $0.programId, sectionId: $0.sectionId, blockId: $0.blockId, position: $0.position, isEnabled: $0.isEnabled) }

        let pkg = ExportPackage(exportedAt: now, categories: categories, suggestions: suggDtos,
                                blocks: blockDtos, blockItems: itemDtos, sections: sectionDtos,
                                sectionBlocks: sectionBlocks, programs: programDto,
                                programSections: psDtos, programSectionBlocks: psbDtos,
                                disabledItems: [], sectionBackgrounds: [])
        try writeZip(pkg: pkg, audioFiles: [:], to: url)
    }

    // ── ZIP schreiben ─────────────────────────────────────────────────────────

    private static func writeZip(pkg: ExportPackage, audioFiles: [String: Data], to url: URL) throws {
        let jsonData = try encoder.encode(pkg)
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
        guard let archive = Archive(url: url, accessMode: .create) else {
            throw NSError(domain: "FileService", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "ZIP-Datei konnte nicht erstellt werden."])
        }
        try archive.addEntry(with: "data.json", type: .file,
                             uncompressedSize: Int64(jsonData.count)) { position, size in
            jsonData.subdata(in: position..<(position + size))
        }
        for (filename, data) in audioFiles {
            try archive.addEntry(with: "audio/\(filename)", type: .file,
                                 uncompressedSize: Int64(data.count)) { position, size in
                data.subdata(in: position..<(position + size))
            }
        }
    }

    // ── Import anwenden ───────────────────────────────────────────────────────

    private static func applyImport(_ pkg: ExportPackage, into data: AppData) {
        var catMap     = [Int64: Int64]()
        var suggMap    = [Int64: Int64]()
        var blockMap   = [Int64: Int64]()
        var sectionMap = [Int64: Int64]()
        var programMap = [Int64: Int64]()

        for c in pkg.categories {
            if let existing = data.categories.first(where: { $0.name == c.name }) {
                catMap[c.id] = existing.id
            } else {
                let newId = data.nextId(); catMap[c.id] = newId
                data.categories.append(MsCategory(id: newId, name: c.name, colorHex: c.colorHex, sortOrder: c.sortOrder))
            }
        }
        for s in pkg.suggestions {
            let newId = data.nextId(); suggMap[s.id] = newId
            data.suggestions.append(MsSuggestion(id: newId, title: s.title, text: s.text ?? "", createdAt: s.createdAt))
        }
        for b in pkg.blocks {
            let newId = data.nextId(); blockMap[b.id] = newId
            let items = pkg.blockItems.filter { $0.blockId == b.id }.sorted { $0.position < $1.position }.map { item in
                MsBlockItem(id: data.nextId(), blockId: newId,
                            suggestionId: item.suggestionId.flatMap { suggMap[$0] },
                            position: item.position, pauseBeforeMs: item.pauseBeforeMs,
                            pauseAfterMs: item.pauseAfterMs, pauseAfterMatchesAudio: item.pauseAfterMatchesAudio,
                            repetitions: item.repetitions, silenceDurationMs: item.silenceDurationMs)
            }
            data.blocks.append(MsBlock(id: newId, title: b.title, createdAt: b.createdAt, items: items))
        }
        for s in pkg.sections {
            let newId = data.nextId(); sectionMap[s.id] = newId
            data.sections.append(MsSection(id: newId, title: s.title, createdAt: s.createdAt))
        }
        for p in pkg.programs {
            let newId = data.nextId(); programMap[p.id] = newId
            data.programs.append(MsProgram(id: newId, title: p.title, createdAt: p.createdAt))
        }
        for ps in pkg.programSections {
            guard let pId = programMap[ps.programId], let sId = sectionMap[ps.sectionId] else { continue }
            data.programSections.append(MsProgramSection(id: data.nextId(), programId: pId, sectionId: sId, position: ps.position))
        }
        for psb in pkg.programSectionBlocks {
            guard let pId = programMap[psb.programId],
                  let sId = sectionMap[psb.sectionId],
                  let bId = blockMap[psb.blockId] else { continue }
            data.programSectionBlocks.append(MsProgramSectionBlock(id: data.nextId(), programId: pId, sectionId: sId, blockId: bId, position: psb.position, isEnabled: psb.isEnabled))
        }
    }

    // ── Hilfsmethoden ─────────────────────────────────────────────────────────

    private static func makeUnique(_ name: String, in existing: [String: Data]) -> String {
        if existing[name] == nil { return name }
        let base = URL(fileURLWithPath: name).deletingPathExtension().lastPathComponent
        let ext  = URL(fileURLWithPath: name).pathExtension
        var i = 2
        var candidate: String
        repeat { candidate = "\(base)_\(i).\(ext)"; i += 1 } while existing[candidate] != nil
        return candidate
    }

    static func sanitizeFileName(_ name: String) -> String {
        let invalid = CharacterSet(charactersIn: "/\\:*?\"<>|")
        let result = name.components(separatedBy: invalid).joined(separator: "_")
        return result.trimmingCharacters(in: .whitespaces).isEmpty ? "Programm" : result
    }
}
