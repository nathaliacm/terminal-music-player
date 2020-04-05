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

enum IOError: Error {
    case invalidInput
}

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
    let readFailedText = "Não foi possível obter a lista de músicas salvas\n"
    let writeFailedText = "Não foi possível sobrescrever a lista de músicas salvas\n"
    let invalidInputText = "Entrada inválida\n"
    let loadFailedText = "Não foi possível carregar a música com a entrada fornecida\n"
    
    print(menu)
    while let command = readLine() {
        clearTerminalScreen()
        print("")
        print(menu)
        switch command.lowercased() {
        case "play":
            do {
                let musicString = try getUserInput()
                let music = try loadMusic(from: musicString)
                try music.play()
                print("Reproduzindo \(music.artist) - \(music.title)\n")
                print("Digite qualquer coisa para parar")
                if readLine() != nil {
                    print("\nMúsica encerrada\n")
                }
            } catch IOError.invalidInput {
                print(invalidInputText)
            } catch PlayerOperationError.loadFailed {
                print(loadFailedText)
            } catch MusicOperationError.playFailed {
                print("Não foi possível tocar a música\n")
            } catch {
                print("Erro inesperado: \(error)\n")
            }
        case "download":
            do {
                let musicString = try getUserInput()
                let music = try loadMusic(from: musicString)
                try music.download(to: musicFilesURL.appendingPathComponent("\(musicString).mp3"))
                print("Música baixada com sucesso\n")
            } catch IOError.invalidInput {
                print(invalidInputText)
            } catch PlayerOperationError.loadFailed {
                print(loadFailedText)
            } catch MusicOperationError.downloadFailed {
                print("Não foi possível baixar a música\n")
            } catch {
                print("Erro inesperado: \(error)\n")
            }
        case "save":
            do {
                let musicString = try getUserInput()
                let music = try loadMusic(from: musicString)
                try saveMusic(music: music, fileURL: jsonURL)
            } catch IOError.invalidInput {
                print(invalidInputText)
            } catch PlayerOperationError.loadFailed {
                print(loadFailedText)
            } catch FileManipulationError.readFailed {
                print(readFailedText)
            } catch FileManipulationError.writeFailed {
                print(writeFailedText)
            } catch FileManipulationError.createFailed {
                print("Não foi possível criar a lista de músicas salvas\n")
            } catch {
                print("Erro inesperado: \(error)\n")
            }
        case "show":
            do {
                let tracklist = try getTracklist()
                for track in tracklist {
                    print("\(track.0) - \(track.1)")
                }
                print("")
            } catch FileManipulationError.readFailed {
                print(readFailedText)
            } catch PlayerOperationError.emptyTracklist {
                print("Nenhuma música salva\n")
            } catch {
                print("Erro inesperado: \(error)\n")
            }
        case "remove":
            do {
                let musicString = try getUserInput()
                _ = try removeMusic(withName: musicString)
            } catch IOError.invalidInput {
                print(invalidInputText)
            } catch FileManipulationError.readFailed {
                print(readFailedText)
            } catch PlayerOperationError.trackNotFound {
                print("Não foi possível encontrar a música com o nome fornecido\n")
            } catch FileManipulationError.writeFailed {
                print(writeFailedText)
            } catch {
                print("Erro inesperado: \(error)")
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

// Limpa o terminal
func clearTerminalScreen() {
    let clear = Process()
    clear.launchPath = "/usr/bin/clear"
    clear.arguments = []
    clear.launch()
    clear.waitUntilExit()
}

// Pede input pro usuário
func getUserInput() throws -> String {
    print("Informe a música:\n")
    guard let musicString = readLine() else {
        throw IOError.invalidInput
    }
    return musicString
}

main()
