//
//  MRPlayerContracts.swift
//  Anilibria
//
//  Created by Ivan Morozov on 21.10.2023.
//  Copyright © 2023 Иван Морозов. All rights reserved.
//

import Foundation

protocol MPVPlayerViewBehavior: AnyObject {
    func set(name: String,
             playlist: [PlaylistItem],
             playItemIndex: Int,
             time: Double,
             preffered: PrefferedSettings)
    func set(audio: AudioTrack)
    func set(subtitle: Subtitles)
    func set(quality: VideoQuality)
    func set(playItemIndex: Int)
}

protocol MPVPlayerEventHandler: ViewControllerEventHandler {
    func bind(view: MPVPlayerViewBehavior,
              router: PlayerRoutable,
              series: Series,
              playlist: [PlaylistItem])

    func settings(quality: VideoQuality?, for item: PlaylistItem)
    func set(currentAudio: AudioTrack?, availableAudioTracks: [AudioTrack])
    func set(currentSubtitle: Subtitles?, availableSubtitles: [Subtitles])
    func select(playItemIndex: Int)
    func save(quality: VideoQuality?, id: Int, time: Double)
    func back()
}
