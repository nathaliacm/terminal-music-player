//
//  musicManager.swift
//  Terminal Music Player
//

import Foundation

enum PlayerOperationError: Error {
    case trackNotFound
    case loadFailed
    case emptyTracklist
}

func getMusic(withName musicTitle: String, from musics: [Music]) throws -> Music {
    let musicsFiltered = musics.filter{ $0.title == musicTitle}
    if !musicsFiltered.isEmpty {
        return musicsFiltered[0]
    }
    else {
        throw PlayerOperationError.trackNotFound
    }
}

// Solicita um arquivo de música e retorna um objeto música (optional)
func loadMusic(from musicSource: String) throws -> Music {
    // Verifica se a entrada é um arquivo existente no Music Files
    let fileURL = musicFilesURL.appendingPathComponent(musicSource)
    if FileManager.default.fileExists(atPath: fileURL.path) {
        let music = Music(url: fileURL)
        return music
    } else {
        do {
            // Verifica se a entrada é uma música salva no JSON
            let musics = try readFile()
            let music = try getMusic(withName: musicSource, from: musics)
            return music
        } catch {
            // Verifica se a entrada é um URL
            let urlOpt = URL(string: musicSource)
            if let url = urlOpt {
                let music = Music(url: url)
                return music
            } else {
                throw PlayerOperationError.loadFailed
            }
        }
    }
}

// Salva as informações de uma música em um arquivo .json
func saveMusic(music: Music, fileURL: URL) throws {
    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: fileURL.path) {
        do {
            var musics = try readFile()
            musics.append(music)
            try writeFile(in: fileURL, with: musics)
        } catch {
            throw error
        }
    } else {
        do {
            try createFile(in: fileURL, with: [])
        } catch {
            throw error
        }
    }
}

// Obtém a lista de músicas
func getTracklist() throws -> [(String, String)] {
    do {
        let musics = try readFile()
        // Checa se o dicionário é nulo ou vazio
        if musics.isEmpty {
            throw PlayerOperationError.emptyTracklist
        }
        var tracklist: [(String, String)] = []
        for music in musics {
            tracklist.append((music.artist, music.title))
        }
        return tracklist
    } catch {
        throw error
    }
}

// Solicita um nome de música e remove a referência da música que possui esse nome, caso exista
func removeMusic(withName musicTitle: String) throws {
    do {
        let musics = try readFile()
        // Checa se existe pelo menos uma música com o nome de música fornecido
        _ = try getMusic(withName: musicTitle, from: musics)
        // Remove as músicas que tem o mesmo metadado título que musicTitle
        let musicsFiltered = musics.filter({ $0.title != musicTitle })
        try writeFile(in: jsonURL, with: musicsFiltered)
    } catch {
        throw error
    }
}
