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

import Foundation

let bye = "Tchau pessoa!\n"
let musicFilesURL: URL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("Music Files", isDirectory: true)
let jsonURL = musicFilesURL.appendingPathComponent("musics.json")

func main()
{
    let menu = """

    --- Comandos do Player ---

    Reproduzir música - play
    Baixar música - download
    Salvar música - save
    Exibir músicas salvas - show
    Remover música - remove
    Descrição dos comandos - help
    Sair do Player - exit

    """
    let help = """
    --- Ajuda ---
    
    play - toca uma música de acordo com a [entrada]
    download - baixa uma música no seu sistema de arquivos
    save - salva a música contida na URL informada
    show - mostra todas as músicas salvas
    remove - remove uma música salva
    
    [entrada] - uma URL de um arquivo de música, o nome de uma música armazenada no diretório Music Files ou o nome de uma música salva com o comando save
    
    """
    
    print(menu)
    while let command = readLine() {
        clearTerminalScreen()
        print("")
        print(menu)
        switch command.lowercased() {
        case "play", "download", "save", "remove":
            print("Informe a música:\n")
            guard let musicString = readLine() else {
                print("Entrada inválida\n")
                return
            }
            if command.lowercased() == "remove" {
                let removeResult = removeMusic(withName: musicString)
                switch removeResult {
                case FileResult.readFailed:
                    print("Não foi possível ler o arquivo\n")
                case GetMusicResult.trackNotFound:
                    print("Música não encontrada\n")
                case RemoveMusicResult.removeSucceeded:
                    print("Música excluida com sucesso\n")
                case FileResult.writeFailed:
                    print("Não foi possível sobrescrever o arquivo\n")
                default:
                    print("Erro desconhecido\n")
                }
                continue
            }
            let musicOpt = loadMusic(from: musicString)
            guard let music = musicOpt else {
                print("Música inválida\n")
            }
            if command.lowercased() == "play" {
                let playResult = music.play()
                switch playResult {
                case PlayResult.playFailed:
                    print("Não foi possível tocar a música\n")
                case PlayResult.playSucceeded:
                    print("Reproduzindo \(music.artist) - \(music.title)\n")
                    print("Digite qualquer coisa para parar")
                    if let command = readLine() {
                        print("\nMúsica encerrada\n")
                    }
                }
            }
            if command.lowercased() == "download" {
                let downloadResult = music.download(to: musicFilesURL.appendPathComponent("\(musicString).mp3"))
                switch downloadResult {
                case DownloadResult.downloadSucceeded:
                    print("Música baixada com sucesso\n")
                case DownloadResult.downloadFailed:
                    print("Não foi possível baixar a música\n")
                }
            }
            if command.lowercased() == "save" {
                let saveResult = saveMusic(music, jsonURL)
                switch saveResult {
                case FileResult.readFailed:
                    print("Não foi possível ler o arquivo\n")
                case FileResult.createFailed:
                    print("Não foi possível criar o arquivo\n")
                case FileResult.writeFailed:
                    print("Não foi possível sobrescrever o arquivo\n")
                case SaveResult.saveSucceeded:
                    print("Música salva com sucesso\n")
                default:
                    print("Erro desconhecido\n")
                }
            }
        case "show":
            let tracklist = getTracklist()
            for track in tracklist {
                print("\(track.0) - \(track.1)")
            }
            print("")
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

// Limpa o terminal
func clearTerminalScreen() {
    let clear = Process()
    clear.launchPath = "/usr/bin/clear"
    clear.arguments = []
    clear.launch()
    clear.waitUntilExit()
}

main()
