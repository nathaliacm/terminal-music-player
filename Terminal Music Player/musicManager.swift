//
//  musicManager.swift
//  Terminal Music Player
//

import Foundation

class MusicManager {
    
    enum GetMusicResult {
        case trackNotFound
    }
    
    func getMusic(withName musicTitle: String, from musics: [Music]) -> Music? {
        let musicsFiltered = musics.filter{ $0.title == musicTitle}
        if !musicsFiltered.isEmpty {
            return musicsFiltered[0]
        }
        else {
            return nil
        }
    }
    
    // Solicita um arquivo de música e retorna um objeto música (optional)
    func loadMusic(from musicSource: String) -> Music? {
        // Verifica se a entrada é um arquivo existente no Music Files
        let fileURL = musicFilesURL.appendingPathComponent(musicSource)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            let music = Music(url: fileURL)
            return music
        } else {
            // Verifica se a entrada é uma música salva no JSON
            let musicsOpt = readFile()
            if let musics = musicsOpt, let musicTitle = getMusic(withName: musicSource, from: musics) {
                    return musicTitle
            } else {
                // Verifica se a entrada é um URL
                let urlOpt = URL(string: musicSource)
                if let url = urlOpt {
                    let music = Music(url: url)
                    return music
                } else {
                    return nil
                }
            }
        }
    }

    enum SaveMusicResult {
        case saveSucceeded
    }
    
    // Salva as informações de uma música em um arquivo .json
    func saveMusic(music: Music, fileURL: URL) -> Any {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: fileURL.path) {
            let musicsOpt = readFile()
            guard var musics = musicsOpt else {
                return FileResult.readFailed
            }
            musics.append(music)
            let writeSuccess = writeFile(in: fileURL, with: musics)
            if !writeSuccess {
                return FileResult.writeFailed
            } else {
                return SaveMusicResult.saveSucceeded
            }
        } else {
            let createSuccess = createFile(in: fileURL, with: [])
            if !createSuccess {
                return FileResult.createFailed
            } else {
                return SaveMusicResult.saveSucceeded
            }
            
        }
    }

    // Obtém a lista de músicas
    func getTracklist() -> [(String, String)] {
        let musicsOpt = readFile()
        // Checa se o dicionário é nulo ou vazio
        guard let musics = musicsOpt, !musics.isEmpty else {
            return []
        }
        var tracklist: [(String, String)] = []
        for music in musics {
            tracklist.append((music.artist, music.title))
        }
        return tracklist
    }
    
    enum RemoveMusicResult {
        case removeSucceeded
    }
    
    // Solicita um nome de música e remove a referência da música que possui esse nome, caso exista
    func removeMusic(withName musicTitle: String) -> Any {
        let musicsOpt = readFile()
        guard let musics = musicsOpt else {
            return FileResult.readFailed
        }
        if getMusic(withName: musicTitle, from: musics) == nil {
            return GetMusicResult.trackNotFound
        }
        // Remove as músicas que tem o mesmo metadado título que musicTitle
        let musicsFiltered = musics.filter({ $0.title != musicTitle })
        let writeSuccess = writeFile(in: jsonURL, with: musicsFiltered)
        if !writeSuccess {
            return FileResult.writeFailed
        } else {
            return RemoveMusicResult.removeSucceeded
        }
    }
}
