//
//  music.swift
//  Terminal Music Player
//

import AVFoundation

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
    
    enum PlayResult {
        case playSucceeded
        case playFailed
    }
    
    // Toca uma música de acordo com o valor da propriedade "url" do objeto
    public func play() -> PlayResult {
        do {
            let musicData = try Data(contentsOf: self.url)
            let musicPlayer = try AVAudioPlayer(data: musicData)
            musicPlayer.play()
            return PlayResult.playSucceeded
        } catch {
            return PlayResult.playFailed
        }
    }
            
            
//            print("\nReproduzindo \(self.artist) - \(self.title)")
//            while musicPlayer.isPlaying {
//                print("\nDigite \"stop\" para parar\n")
//                if let command = readLine(), command == "stop" {
//                    print("\nMúsica encerrada")
//                    break
//                } else {
//                    print("\nComando inválido\n", terminator: " ")
//                }
//            }
//        } catch {
//            print("\nNão foi possível reproduzir a música")
//        }
//    }
    
    enum DownloadResult {
        case downloadSucceeded
        case downloadFailed
    }
    
    // Tenta baixar uma música de um determinado URL
    public func download(to fileURL: URL) -> DownloadResult {
        do {
            let musicData = try Data(contentsOf: self.url)
            try musicData.write(to: fileURL)
            return DownloadResult.downloadSucceeded
            //print("\nMúsica baixada com sucesso")
        } catch {
            return DownloadResult.downloadFailed
            //print("\nNão foi possível baixar a música")
        }
    }
}
