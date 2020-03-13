#!/usr/bin/swift
//
//  main.swift
//  Terminal Music Player
//
//  Created by Rodrigo Matos Aguiar on 10/03/20.
//  Copyright © 2020 Rodrigo Matos Aguiar. All rights reserved.
//

import AVFoundation

func main()
{
    playMusic(musicUrl: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3")
    //playLocalMusic(resourceUrl: "music", fileExtension: "mp3")
}

func playMusic(musicUrl: String)
{
    let urlOpt = URL(string: musicUrl)
    do {
        if let url = urlOpt
        {
            let musicData = try Data(contentsOf: url)
            let musicPlayer = try AVAudioPlayer(data: musicData)
            musicPlayer.play()
            if let command = readLine(), command == "stop" {
                print("flws")
            } else {
                print("erro")
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

main()


