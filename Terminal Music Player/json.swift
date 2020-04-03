//
//  json.swift
//  Terminal Music Player
//

import Foundation

enum FileResult {
    case createFailed
    case readFailed
    case writeFailed
}

// Cria um arquivo .json com determinados dados
func createFile(in fileURL: URL, with musics: [Music]) -> Bool {
    let jsonDataOpt = musicsToJsonData(musics: musics)
    guard let jsonData = jsonDataOpt else {
        return false
    }
    let fileManager = FileManager.default
    let success = fileManager.createFile(atPath: fileURL.path, contents: jsonData, attributes: [:])
    return success
}

// Lê o arquivo .json e retorna o dicionário de músicas contido nele
func readFile() -> [Music]? {
    do {
        let fileHandle = try FileHandle(forReadingFrom: musicFilesURL.appendingPathComponent("musics.json"))
        let fileData = fileHandle.readDataToEndOfFile()
        let musics = jsonDataToMusics(jsonData: fileData)
        return musics
    } catch {
        return nil
    }
}

func writeFile(in fileURL: URL, with musics: [Music]) -> Bool {
    let jsonDataOpt = musicsToJsonData(musics: musics)
    guard let jsonData = jsonDataOpt else {
        return false
    }
    do {
        try jsonData.write(to: fileURL)
        return true
    } catch {
        return false
    }
}

// Funções auxiliares (de conversão)

// Converte json data para um dicionário de música (optional)
func jsonDataToMusics(jsonData: Data) -> [Music]? {
    let jsonDecoder = JSONDecoder()
    do {
        let musics = try jsonDecoder.decode([Music].self, from: jsonData)
        return musics
    } catch {
        return nil
    }
}

// Converte um dicionário de música para json data (optional)
func musicsToJsonData(musics: [Music]) -> Data? {
    let jsonEncoder = JSONEncoder()
    do {
        let jsonData = try jsonEncoder.encode(musics)
        return jsonData
    } catch {
        return nil
    }
}
