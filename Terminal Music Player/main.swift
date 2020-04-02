#!/usr/bin/swift
//
//  main.swift
//  Terminal Music Player
//
//  Created by Rodrigo Matos and Nathália Moura on 10/03/20.
//

/* URLs de música válidas
 
 https://files.freemusicarchive.org/storage-freemusicarchive-org/music/ccCommunity/Chad_Crouch/Arps/Chad_Crouch_-_Shipping_Lanes.mp3

 https://files.freemusicarchive.org/storage-freemusicarchive-org/music/West_Cortez_Records/David_Hilowitz/Gradual_Sunrise/David_Hilowitz_-_Gradual_Sunrise.mp3

 https://files.freemusicarchive.org/storage-freemusicarchive-org/music/no_curator/Mid-Air_Machine/Vibrations__Text__Alarm_Notification_Songs/Mid-Air_Machine_-_Ampheral__Text_Notification.mp3
 
*/

import AVFoundation
import Foundation

let bye = "Tchau pessoa!\n"
let musicFilesURL: URL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("Music Files", isDirectory: true)
let jsonURL = musicFilesURL.appendingPathComponent("musics.json")

class Music: Codable {
    var url: URL
    var title: String = "Desconhecido"
    var artist: String = "Desconhecido"
    var type: String = "Desconhecido"
    
    init(url: URL) {
        self.url = url
        setMetadata()
    }
    
    // Extrai os metadados contidos em uma URL e atribui esses metadados às propriedades do objeto
    private func setMetadata() {
        
        let playerItem = AVPlayerItem(url: self.url)
        let metadataList = playerItem.asset.metadata
        
        for item in metadataList {
            if let itemKey = item.commonKey {
                switch itemKey.rawValue {
                case "title":
                    self.title = item.stringValue ?? "Desconhecido"
                    /*if self.title == "Desconhecido" {
                        print("Nome da musica:\n")
                        let musicName = readLine() ?? "Vazio"
                        self.title = musicName
                    }*/
                case "artist":
                    self.artist = item.stringValue ?? "Desconhecido"
                    /*if self.artist == "Desconhecido" {
                        print("Nome do artista:\n")
                        let artistName = readLine() ?? "Vazio"
                        self.artist = artistName
                    }*/
                case "type":
                    self.type = item.stringValue ?? "Desconhecido"
                    /*if self.type == "Desconhecido" {
                        print("Nome do gênero:\n")
                        let typeName = readLine() ?? "Vazio"
                        self.type = typeName
                    }*/
                default:
                    continue
                }
            } else {
                continue
            }
        }
    }
    
    // Toca uma música de acordo com o valor da propriedade "url" do objeto
    public func play() {
        do {
            let musicData = try Data(contentsOf: self.url)
            let musicPlayer = try AVAudioPlayer(data: musicData)
            musicPlayer.play()
            print("\nReproduzindo \(self.artist) - \(self.title)")
            while musicPlayer.isPlaying {
                print("\nDigite \"stop\" para parar\n")
                if let command = readLine(), command == "stop" {
                    print("\nMúsica encerrada")
                    break
                } else {
                    print("\nComando inválido\n", terminator: " ")
                }
            }
        } catch {
            print("\nNão foi possível reproduzir a música")
        }
    }
    
    public func download(to fileURL: URL) {
        do {
            let musicData = try Data(contentsOf: self.url)
            try musicData.write(to: fileURL)
            print("\nMúsica baixada com sucesso")
            
        } catch {
            print("\nNão foi possível baixar a música")
        }
    }
}

func main()
{
    let menu = """

    --- Comandos do Player ---

    Reproduzir música - play
    Salvar música - save
    Exibir músicas salvas - show
    Remover música - remove
    Baixar música - download
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
    let musicError = "\nMúsica não encontrada\n"
    
    print(menu)
    while let command = readLine() {
        clearTerminalScreen()
        print("")
        print(menu)
        switch command.lowercased() {
        case "play":
            let musicOpt = loadMusic()
            if let music = musicOpt {
                music.play()
                print("")
            } else {
                print(musicError)
            }
        case "save":
            let musicOpt = loadMusic()
            if let music = musicOpt {
                saveMusic(music: music, fileURL: musicFilesURL.appendingPathComponent("Musics.json"))
            } else {
                print(musicError)
            }
        case "show":
            showMusics()
            print("")
        case "remove":
            removeMusic()
            print("")
        case "download":
            let musicOpt = loadMusic()
            if let music = musicOpt {
                /*
                Mesmo que o arquivo de música fornecido não seja do tipo mp3, não terá problema. Como Mac é baseado em Unix, a extensão só servirá para o Mac atribuir um programa padrão para abrir esse arquivo.
                 */
                music.download(to:
                musicFilesURL.appendingPathComponent("\(music.artist) - \(music.title).mp3"))
                print("")
            } else {
                print(musicError)
            }
        case "help":
            print(help)
        case "exit":
            print(bye)
            return
        default:
            print("Comando inválido. Informe um comando válido (commands):\n")
        }
    }
}

// Solicita um arquivo de música e retorna um objeto música (optional)
func loadMusic() -> Music? {
    print("Informe a música:\n")
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
    let saveError = "\nNão foi possível salvar a música"
    let saveSuccess = "\nMúsica salva com sucesso\n"
    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: fileURL.path) {
        let dictMusicOpt = getDictFromFile()
        guard var dictMusic = dictMusicOpt else {
            print(saveError, "(dictConversionError)")
            return
        }
        dictMusic[music.title] = music
        let jsonDataOpt = musicsToJsonData(musics: dictMusic)
        guard let jsonData = jsonDataOpt else {
            print(saveError, "(jsonConversionError)")
            return
        }
        do {
            try jsonData.write(to: jsonURL)
            print(saveSuccess)
        } catch {
            print(saveError)
        }
    } else {
        let createSuccess = createInitialFile(initialMusic: [music.title: music], fileURL: fileURL)
        print(createSuccess ? saveSuccess : saveError)
    }
}

// Mostra todas as músicas salvas no Player
func showMusics() {
    let dictMusicOpt = getDictFromFile()
    // Checa se o dicionário é nulo ou vazio
    guard let dictMusic = dictMusicOpt, !dictMusic.isEmpty else {
        print("Nenhuma música salva")
        return
    }
    print("--- Lista de Músicas ---\n")
    for music in dictMusic.values {
        print("\(music.artist) - \(music.title)")
    }
}

// Solicita um nome de música e remove a referência da música que possui esse nome, caso exista
func removeMusic() {
    print("Informe o nome da música:\n")
    guard let musicName = readLine() else {
        return
    }
    print("")
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
            try jsonData.write(to: jsonURL)
        } catch {
            print("Não foi possível remover a música")
            return
        }
        print("Música removida com sucesso")
    } else {
        print("Música inexistente")
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
func createInitialFile(initialMusic: [String: Music], fileURL: URL) -> Bool {
    // Create file and write json
    let jsonEncoder = JSONEncoder()
    let fileManager = FileManager.default
    do {
        let jsonData = try jsonEncoder.encode(initialMusic)
        let success = fileManager.createFile(atPath: fileURL.path, contents: jsonData, attributes: [:])
        return success
    } catch {
        return false
    }
    //print("arquivo criado")
}

// Funções auxiliares (de conversão)

// Converte json data para um dicionário de música (optional)
func jsonDataToMusics(jsonData: Data) -> [String: Music]? {
    let jsonDecoder = JSONDecoder()
    do {
        let musics = try jsonDecoder.decode([String: Music].self, from: jsonData)
        return musics
    } catch {
        return nil
    }
}

// Converte um dicionário de música para json data (optional)
func musicsToJsonData(musics: [String: Music]) -> Data? {
    let jsonEncoder = JSONEncoder()
    do {
        let jsonData = try jsonEncoder.encode(musics)
        return jsonData
    } catch {
        return nil
    }
}

// Limpa o terminal
func clearTerminalScreen() {
    let clear = Process()
    clear.launchPath = "/usr/bin/clear"
    clear.arguments = []
    clear.launch()
    clear.waitUntilExit()
}

main()
