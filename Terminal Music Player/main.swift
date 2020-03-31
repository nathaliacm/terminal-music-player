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
            if musicPlayer.isPlaying{
                print("Reproduzindo \(self.artist) - \(self.title)")
                print("Digite \"stop\" para parar")
                if let command = readLine(), command == "stop" {
                    print(bye)
                } else {
                    print("erro")
                }
            }
        } catch {
            print("\(error)")
        }
    }
}

/* https://files.freemusicarchive.org/storage-freemusicarchive-org/music/ccCommunity/Chad_Crouch/Arps/Chad_Crouch_-_Shipping_Lanes.mp3
    https://files.freemusicarchive.org/storage-freemusicarchive-org/music/West_Cortez_Records/David_Hilowitz/Gradual_Sunrise/David_Hilowitz_-_Gradual_Sunrise.mp3
 */

func main()
{
     
     
    let menu = """

    --- Comandos do Player ---

    Reproduzir música - play
    Salvar música - save
    Procurar músicas - search
    Listas de Reprodução - playlists
    Lista de comandos - commands
    Sair do Player - exit

    """
    print(menu)
    while let command = readLine() {
        switch command {
        case "play", "local":
            // TODO - Devemos adaptar esse método para os 3 tipos de play
            // play online - tocar músicas de um url
            // play local - tocar músicas presentes na máquina do usuário
            // play saved - tocar músicas salvas no Player pelo comando save
            let musicOpt: Music?
            if command == "play"{
                musicOpt = loadMusic()
            } else {
                musicOpt = loadMusicLocal()
            }
            
            if let music = musicOpt {
                music.play()
            } else {
                print("erro")
            }
            print(menu)
        case "save":
            let musicOpt = loadMusic()
            if let music = musicOpt {
                saveMusic(music: music, fileURL: musicFilesURL.appendingPathComponent("Musics.json"))
            } else {
                print("erro")
            }
            print(menu)
        case "search":
            let musicOpt = searchMusicJson()
            if let music = musicOpt {
                print(music.url)
            } else {
                print("Música não encontrada.")
            }
        case "exit":
            print(bye)
            return
        case "commands":
            print(menu)
        default:
            print("\nComando inválido. Informe um comando válido (commands):\n")
        }
    }
}

func loadMusic() -> Music? {
    print("Informe a URL da música: ")
    guard let musicUrl = readLine() else {
        return nil
    }
    let urlOpt = URL(string: musicUrl)
    if let url = urlOpt {
        let music = Music(url: url)
        return music
    } else {
        return nil
    }
}

func loadMusicLocal() -> Music? {
    print("Informe o nome junto da extensão da música: ")
    guard let musicFile = readLine() else {
        return nil
    }
    let musicUrl: URL = musicFilesURL.appendingPathComponent(musicFile)
    let music = Music(url: musicUrl)
    return music
}

func searchMusicJson() -> Music? {
    print("Informe o nome da música: ")
    guard let musicName = readLine() else {
        return nil
    }
    let dictMusicOpt = getDictFromFile()
    guard let dictMusic = dictMusicOpt else {
        print("erro")
        return nil
    }
    return dictMusic[musicName]
}

// Pegar o que tá no arquivo e criar um dicionario com isso

func saveMusic(music: Music, fileURL: URL) {
    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: fileURL.path) {
        let dictMusicOpt = getDictFromFile()
        if var dictMusic = dictMusicOpt {
            dictMusic[music.title] = music
            do {
                let jsonDataOpt = musicsToJsonData(musics: dictMusic)
                if let jsonData = jsonDataOpt {
                    let fileHandle = try FileHandle(forWritingTo: musicFilesURL.appendingPathComponent("musics.json"))
                    fileHandle.write(jsonData)
                } else {
                    print("erro")
                }
            } catch {
                print("Error appending to file \(error)")
            }
        } else {
            print("erro")
        }
    } else {
        createInitialFile(initialMusic: [music.title: music], fileURL: fileURL)
    }
    
}

func getDictFromFile() -> [String: Music]? {
    do {
        let fileHandle = try FileHandle(forReadingFrom: musicFilesURL.appendingPathComponent("musics.json"))
        let jsonData = fileHandle.readDataToEndOfFile()
        let dict = jsonDataToMusics(jsonData: jsonData)
        return dict
    } catch {
        print("Error reading file \(error)")
        return nil
    }
}

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

func jsonDataToMusics(jsonData: Data) -> [String: Music]? {
    do {
        let jsonDecoder = JSONDecoder()
        let musics = try jsonDecoder.decode([String: Music].self, from: jsonData)
        return musics
    } catch {
        return nil
    }
}

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

/*func playLocalMusic(resourceUrl: String, fileExtension: String)
{
    print("\(resourceUrl) \(fileExtension)")
    //let urlOpt = Bundle.main.url(forResource: resourceUrl, withExtension: fileExtension)
    //print(Bundle.main.bundleURL.relativePath)
    
    let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    let musicURL: URL = root.appendingPathComponent("Music Files", isDirectory: true).appendingPathComponent("music.mp3")
    
    print(musicURL)
    do {
        let musicPlayer = try AVAudioPlayer(contentsOf: musicURL)
        musicPlayer.prepareToPlay()
        musicPlayer.play()
        if let command = readLine(), command == "stop" {
            print("flws")
        } else {
            print("erro")
        }
        print("Eita: \(musicPlayer.isPlaying)\(musicURL)")
    } catch {
        print("🔴 \(error)")
    }
    
    RunLoop.main.run()
}*/

//func musicToJsonData(music: Music) -> Data? {
//    do {
//        let jsonEncoder = JSONEncoder()
//        let jsonData = try jsonEncoder.encode(music)
//        return jsonData
//    } catch {
//        print("\(error)")
//        return nil
//    }
//}

//func musicToJson(music: Music) -> String? {
//    do {
//        let jsonEncoder = JSONEncoder()
//        let jsonData = try jsonEncoder.encode(music)
//        let json = String(data: jsonData, encoding: String.Encoding.utf8)
//        return json
//    } catch {
//        print("\(error)")
//        return nil
//    }
//}

//func jsonToMusic(json: String) -> Music? {
//    do {
//        let jsonDecoder = JSONDecoder()
//        if let jsonData = json.data(using: .utf8) {
//            let music = try jsonDecoder.decode(Music.self, from: jsonData)
//            return music
//        } else {
//            return nil
//        }
//    } catch {
//        print("\(error)")
//        return nil
//    }
//}
