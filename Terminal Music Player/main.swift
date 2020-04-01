#!/usr/bin/swift
//
//  main.swift
//  Terminal Music Player
//
//  Created by Rodrigo Matos Aguiar on 10/03/20.
//  Copyright © 2020 Rodrigo Matos Aguiar. All rights reserved.
//

import AVFoundation
import Foundation

let bye = "Tchau pessoa!"
let musicFilesURL: URL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("Music Files", isDirectory: true)

class Music: Codable {
    var url: URL
    var title: String = "Desconhecido"
    var artist: String = "Desconhecido"
    var type: String = "Desconhecido"
    
    init(url: URL) {
        self.url = url
        setMetadata()
    }
    
    private func setMetadata() {
        
        let playerItem = AVPlayerItem(url: self.url)
        let metadataList = playerItem.asset.metadata
        
        for item in metadataList {
            if let itemKey = item.commonKey {
                switch itemKey.rawValue {
                case "title":
                    self.title = item.stringValue ?? "Desconhecido"
                case "artist":
                    self.artist = item.stringValue ?? "Desconhecido"
                case "type":
                    self.type = item.stringValue ?? "Desconhecido"
                default:
                    continue
                }
            } else {
                continue
            }
        }
    }
    
    public func play() {
        do {
            let musicData = try Data(contentsOf: self.url)
            let musicPlayer = try AVAudioPlayer(data: musicData)
            musicPlayer.play()
            print("Reproduzindo \(self.artist) - \(self.title)")
            while musicPlayer.isPlaying {
                print("Digite \"stop\" para parar")
                if let command = readLine(), command == "stop" {
                    print("Música encerrada.")
                    break
                } else {
                    print("Comando inválido.", terminator: " ")
                }
            }
        } catch {
            print("\(error)")
        }
    }
}

/* https://files.freemusicarchive.org/storage-freemusicarchive-org/music/ccCommunity/Chad_Crouch/Arps/Chad_Crouch_-_Shipping_Lanes.mp3
    https://files.freemusicarchive.org/storage-freemusicarchive-org/music/West_Cortez_Records/David_Hilowitz/Gradual_Sunrise/David_Hilowitz_-_Gradual_Sunrise.mp3
 
 https://files.freemusicarchive.org/storage-freemusicarchive-org/music/no_curator/Mid-Air_Machine/Vibrations__Text__Alarm_Notification_Songs/Mid-Air_Machine_-_Ampheral__Text_Notification.mp3
 */

func main()
{
    let menu = """

    --- Comandos do Player ---

    Reproduzir música - play
    Salvar música - save
    Exibir músicas salvas - show
    Remover música - remove
    Descrição dos comandos - help
    Sair do Player - exit

    """
    let help = """
        
    --- Ajuda ---
    
    play - toca uma música de acordo com a [entrada]
    save - salva a música contida na URL informada
    show - mostra todas as músicas salvas
    remove - remove uma música salva
    
    [entrada] - uma URL de um arquivo de música, o nome de uma música armazenada no diretório Music Files ou o nome de uma música salva com o comando save
    
    """
    
    print(menu)
    while let command = readLine() {
        // Adiciona uma linha vazia por motivos de estética
        print("")
        switch command {
        case "play":
            let musicOpt = loadMusic()
            if let music = musicOpt {
                music.play()
            } else {
                print("Música não encontrada.")
            }
            print(menu)
        case "save":
            let musicOpt = loadMusic()
            if let music = musicOpt {
                saveMusic(music: music, fileURL: musicFilesURL.appendingPathComponent("Musics.json"))
            } else {
                print("Entrada inválida.")
            }
            print(menu)
        case "show":
            showMusics()
            print(menu)
        case "remove":
            removeMusic()
            print(menu)
        case "help":
            print(help)
        case "exit":
            print(bye)
            return
        default:
            print("\nComando inválido. Informe um comando válido (commands):\n")
        }
    }
}

func showMusics() {
    let dictMusicOpt = getDictFromFile()
    guard let dictMusic = dictMusicOpt else {
        print("Nenhuma música salva.")
        return
    }
    for music in dictMusic.values {
        print("\(music.artist) - \(music.title)")
    }
}

func removeMusic() {
    print("Informe a música: ")
    guard let musicName = readLine() else {
        return
    }
    let dictMusicOpt = getDictFromFile()
    guard var dictMusic = dictMusicOpt else {
        print("Nenhuma música salva")
        return
    }
    if dictMusic[musicName] != nil {
        dictMusic[musicName] = nil
        let jsonDataOpt = musicsToJsonData(musics: dictMusic)
        guard let jsonData = jsonDataOpt else {
            print("(jsonConversionError)")
            return
        }
        do {
            let fileHandle = try FileHandle(forWritingTo: musicFilesURL.appendingPathComponent("musics.json"))
            fileHandle.write(jsonData)
        } catch {
            print("Não foi possível remover a música")
            return
        }
        print("Música removida com sucesso")
    } else {
        print("Música inexistente")
    }
}

func loadMusic() -> Music? {
    print("Informe a música: ")
    guard let musicInput = readLine() else {
        return nil
    }
    // Verifica se a entrada é um arquivo existente no Music Files
    let fileURL = musicFilesURL.appendingPathComponent(musicInput)
    if FileManager.default.fileExists(atPath: fileURL.path) {
        let music = Music(url: fileURL)
        return music
    } else {
        // Verifica se a entrada é uma música salva no JSON
        let dictMusicOpt = getDictFromFile()
        if let dictMusic = dictMusicOpt, dictMusic.keys.contains(musicInput) {
                return dictMusic[musicInput]
        } else {
            // Verifica se a entrada é um URL
            let urlOpt = URL(string: musicInput)
            if let url = urlOpt {
                let music = Music(url: url)
                return music
            } else {
                return nil
            }
        }
    }
}

// Salva as informações de uma música em um arquivo .json
func saveMusic(music: Music, fileURL: URL) {
    let erroSave = "Não foi possível salvar a música"
    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: fileURL.path) {
        let dictMusicOpt = getDictFromFile()
        guard var dictMusic = dictMusicOpt else {
            print(erroSave, "(dictConversionError)")
            return
        }
        dictMusic[music.title] = music
        do {
            let jsonDataOpt = musicsToJsonData(musics: dictMusic)
            guard let jsonData = jsonDataOpt else {
                print(erroSave, "(jsonConversionError)")
                return
            }
            let fileHandle = try FileHandle(forWritingTo: musicFilesURL.appendingPathComponent("musics.json"))
            fileHandle.write(jsonData)
        } catch {
            print("Error appending to file \(error)")
        }
    } else {
        createInitialFile(initialMusic: [music.title: music], fileURL: fileURL)
    }
}

// Lê o arquivo .json e retorna o dicionário de músicas contido nele
func getDictFromFile() -> [String: Music]? {
    do {
        let fileHandle = try FileHandle(forReadingFrom: musicFilesURL.appendingPathComponent("musics.json"))
        let jsonData = fileHandle.readDataToEndOfFile()
        let dict = jsonDataToMusics(jsonData: jsonData)
        return dict
    } catch {
        return nil
    }
}

// Cria um arquivo .json com um dicionário de música inicial
func createInitialFile(initialMusic: [String: Music], fileURL: URL) {
    // Create file and write json
    let jsonEncoder = JSONEncoder()
    let fileManager = FileManager.default
    do {
        let jsonData = try jsonEncoder.encode(initialMusic)
        fileManager.createFile(atPath: fileURL.path, contents: jsonData, attributes: [:])
    } catch {
        print("\(error)")
    }
    //print("arquivo criado")
}

// Converte json data para um dicionário de música (optional)
func jsonDataToMusics(jsonData: Data) -> [String: Music]? {
    do {
        let jsonDecoder = JSONDecoder()
        let musics = try jsonDecoder.decode([String: Music].self, from: jsonData)
        return musics
    } catch {
        return nil
    }
}

// Converte um dicionário de música para json data (optional)
func musicsToJsonData(musics: [String: Music]) -> Data? {
    do {
        let jsonEncoder = JSONEncoder()
        let jsonData = try jsonEncoder.encode(musics)
        return jsonData
    } catch {
        print("\(error)")
        return nil
    }
}

main()

//func saveMusic(music: Music, fileURL: URL) {
//    let fileManager = FileManager.default
//    if fileManager.fileExists(atPath: fileURL.path) {
//        let dictMusicOpt = getDictFromFile()
//        if var dictMusic = dictMusicOpt {
//            dictMusic[music.title] = music
//            do {
//                let jsonDataOpt = musicsToJsonData(musics: dictMusic)
//                if let jsonData = jsonDataOpt {
//                    let fileHandle = try FileHandle(forWritingTo: musicFilesURL.appendingPathComponent("musics.json"))
//                    fileHandle.write(jsonData)
//                } else {
//                    print("erro")
//                }
//            } catch {
//                print("Error appending to file \(error)")
//            }
//        } else {
//            print("erro")
//        }
//    } else {
//        createInitialFile(initialMusic: [music.title: music], fileURL: fileURL)
//    }
//
//}
