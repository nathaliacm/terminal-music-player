#!/usr/bin/swift
//
//  main.swift
//  Terminal Music Player
//
//  Created by Rodrigo Matos Aguiar on 10/03/20.
//  Copyright © 2020 Rodrigo Matos Aguiar. All rights reserved.
//

import AVFoundation

let bye = "Tchau pessoa!"

/* https://files.freemusicarchive.org/storage-freemusicarchive-org/music/ccCommunity/Chad_Crouch/Arps/Chad_Crouch_-_Shipping_Lanes.mp3 */


func main()
{
    let menu = """

    --- Comandos do Player ---

    Reproduzir música - play
    Salvar música - save
    Sair do Player - exit
    Lista de comandos - commands

    """
    while(true) {
        print(menu)
        if let command = readLine() {
            switch command {
            case "play":
                playMusic()
            case "save":
                print("standby2")
                // saveMusic()
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
    //playLocalMusic(resourceUrl: "music", fileExtension: "mp3")
}

func playMusic()
{
    print("Insira a URL da música que deseja tocar: ")
    guard let musicUrl = readLine() else {
        print("erro")
        return
    }
    let urlOpt = URL(string: musicUrl)
    do {
        if let url = urlOpt
        {
            saveMusic(musicUrl: url)
            let musicData = try Data(contentsOf: url)
            let musicPlayer = try AVAudioPlayer(data: musicData)
            musicPlayer.play()
            if musicPlayer.isPlaying{
                print("Musica está tocando.")
                print("Digite \"stop\" para parar")
                if let command = readLine(), command == "stop" {
                    print(bye)
                } else {
                    print("erro")
                }
            }
            
        }
        else {
            print("erro")
        }
    }
    catch
    {
        print("\(error)")
    }
}

func playLocalMusic(resourceUrl: String, fileExtension: String)
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
}

func saveMusic(musicUrl: URL) {
    
    let playerItem = AVPlayerItem(url: musicUrl)
    let metadataList = playerItem.asset.metadata
    
    var musicTitle: String = "Desconhecido"
    var musicArtist: String = "Desconhecido"
    var musicType: String = "Desconhecido"
    
    for item in metadataList {
        if let itemKey = item.commonKey {
            switch itemKey.rawValue {
            case "title":
                musicTitle = item.stringValue ?? "Desconhecido"
            case "artist":
                musicArtist = item.stringValue ?? "Desconhecido"
            case "type":
                musicType = item.stringValue ?? "Desconhecido"
            default:
                continue
            }
        } else {
            continue
        }
    }
    print("Reproduzindo \(musicArtist) - \(musicTitle) - \(musicType)")
    
    
    
    
    
    
    
    
    
    
    
    
    
}

main()


