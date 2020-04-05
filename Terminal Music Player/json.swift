//
//  json.swift
//  Terminal Music Player
//

import Foundation

enum FileManipulationError: Error {
    case createFailed
    case readFailed
    case writeFailed
}

enum JsonConversionError: Error {
    case conversionFromJsonFailed
    case conversionToJsonFailed
}

// Cria um arquivo .json com uma determinada array de músicas
func createFile(in fileURL: URL, with musics: [Music]) throws {
    do {
        let jsonData = try musicsToJsonData(musics: musics)
        let fileManager = FileManager.default
        let success = fileManager.createFile(atPath: fileURL.path, contents: jsonData, attributes: [:])
        if !success {
            throw FileManipulationError.createFailed
        }
    } catch {
        throw FileManipulationError.createFailed
    }
}

// Lê o arquivo .json e retorna a array de músicas contida nele
func readFile() throws -> [Music] {
    do {
        let fileHandle = try FileHandle(forReadingFrom: musicFilesURL.appendingPathComponent("musics.json"))
        let fileData = fileHandle.readDataToEndOfFile()
        let musics = try jsonDataToMusics(jsonData: fileData)
        return musics
    } catch {
        throw FileManipulationError.readFailed
    }
}

// Escreve uma array de músicas em um arquivo .json
func writeFile(in fileURL: URL, with musics: [Music]) throws {
    do {
        let jsonData = try musicsToJsonData(musics: musics)
        try jsonData.write(to: fileURL)
    } catch {
        throw FileManipulationError.writeFailed
    }
}

// Funções auxiliares (de conversão)

// Converte json data para uma array de músicas
func jsonDataToMusics(jsonData: Data) throws -> [Music] {
    let jsonDecoder = JSONDecoder()
    do {
        let musics = try jsonDecoder.decode([Music].self, from: jsonData)
        return musics
    } catch {
        throw JsonConversionError.conversionFromJsonFailed
    }
}

// Converte uma array de músicas para json data
func musicsToJsonData(musics: [Music]) throws -> Data {
    let jsonEncoder = JSONEncoder()
    do {
        let jsonData = try jsonEncoder.encode(musics)
        return jsonData
    } catch {
        throw JsonConversionError.conversionToJsonFailed
    }
}
