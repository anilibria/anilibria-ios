//
//  MPVPlayerPresenter.swift
//  Anilibria
//
//  Created by Ivan Morozov on 21.10.2023.
//  Copyright © 2023 Иван Морозов. All rights reserved.
//

import DITranquillity
import Combine
import UIKit

final class MPVPlayerPart: DIPart {
    static func load(container: DIContainer) {
        container.register(MPVPlayerPresenter.init)
            .as(MPVPlayerEventHandler.self)
            .lifetime(.objectGraph)
    }
}

// MARK: - Presenter

final class MPVPlayerPresenter {
    private weak var view: MPVPlayerViewBehavior!
    private var router: PlayerRoutable!
    private var series: Series!
    private var playlist: [PlaylistItem] = []
    private var bag = Set<AnyCancellable>()
    
    private var currentSubtitle: Subtitles?
    private var availableSubtitles: [Subtitles] = []
    
    private var currentAudio: AudioTrack?
    private var availableAudioTracks: [AudioTrack] = []
    
    private let playerService: PlayerService

    init(playerService: PlayerService) {
        self.playerService = playerService
    }
}

extension MPVPlayerPresenter: MPVPlayerEventHandler {
    func bind(view: MPVPlayerViewBehavior,
              router: PlayerRoutable,
              series: Series,
              playlist: [PlaylistItem]) {
        self.view = view
        self.router = router
        self.series = series
        self.playlist = playlist
    }

    func didLoad() {
//        self.playerService
//            .fetchPlayerContext(for: self.series)
//            .sink(onNext: { [weak self] context in
//                self?.run(with: context)
//            })
//            .store(in: &bag)
        self.run(with: nil)
    }
    
    func set(currentSubtitle: Subtitles?, availableSubtitles: [Subtitles]) {
        self.currentSubtitle = currentSubtitle
        self.availableSubtitles = availableSubtitles
    }
    
    func set(currentAudio: AudioTrack?, availableAudioTracks: [AudioTrack]) {
        self.currentAudio = currentAudio
        self.availableAudioTracks = availableAudioTracks
    }

    func select(playItemIndex: Int) {
        let items = self.playlist.enumerated().map { value in
            ChoiceItem(value.offset,
                       title: value.element.title,
                       isSelected: value.offset == playItemIndex)
        }
        
        let group = ChoiceGroup(items: items)
        group.choiceCompleted = { [weak self] value in
            if let index = value as? Int, index != playItemIndex {
                self?.view.set(playItemIndex: index)
            }
        }
        
        self.router.openSheet(with: [group])
    }

    func settings(quality: VideoQuality?, for item: PlaylistItem) {
        let qualities = item.supportedQualities()
        let items = qualities.compactMap { value -> ChoiceItem? in
            guard let name = value.name else { return nil }
            return ChoiceItem(value, title: name, isSelected: quality == value)
        }
        
        var groups: [ChoiceGroup] = []

        if !items.isEmpty {
            let group = ChoiceGroup(title: L10n.Screen.Settings.videoQuality, items: items)
            group.choiceCompleted = { [weak self] value in
                if let selectedQuality = value as? VideoQuality, selectedQuality != quality {
                    self?.view.set(quality: selectedQuality)
                }
            }
            
            groups.append(group)
        }
        
        if !availableAudioTracks.isEmpty {
            let items = availableAudioTracks.map { value -> ChoiceItem in
                return ChoiceItem(value, title: value.title, isSelected: currentAudio == value)
            }
            
            let group = ChoiceGroup(title: L10n.Common.audioTrack, items: items)
            group.choiceCompleted = { [weak self] value in
                if let selected = value as? AudioTrack, self?.currentAudio != selected {
                    self?.currentAudio = selected
                    self?.view.set(audio: selected)
                }
            }
            
            groups.append(group)
        }
        
        if !availableSubtitles.isEmpty {
            let items = availableSubtitles.map { value -> ChoiceItem in
                return ChoiceItem(value, title: value.title, isSelected: currentSubtitle == value)
            }
            
            let group = ChoiceGroup(title: L10n.Common.sublitleTrack, items: items)
            group.choiceCompleted = { [weak self] value in
                if let selected = value as? Subtitles, self?.currentSubtitle != selected {
                    self?.currentSubtitle = selected
                    self?.view.set(subtitle: selected)
                }
            }
            
            groups.append(group)
        }
        
        self.router.openSheet(with: groups)
    }

    func back() {
        self.router.back()
    }

    func save(quality: VideoQuality?, id: Int, time: Double) {
//        let context = PlayerContext(id: id,
//                                    time: time,
//                                    quality: quality)
//        self.playerService
//            .set(context: context, for: self.series)
//            .sink()
//            .store(in: &bag)
    }

    private func run(with context: PlayerContext?) {
        let settings = self.playerService.fetchSettings()
        let preffered = PrefferedSettings(
            quality: context?.quality ?? settings.quality,
            audioTrack: settings.audioTrack,
            subtitleTrack: settings.subtitleTrack
        )
        
        var index = context?.number ?? 0
        
        if let id = context?.id, index == 0 {
            index = playlist.firstIndex(where: { $0.id == id }) ?? 0
        }
        
        self.view.set(name: self.series.names.first ?? "",
                      playlist: self.playlist,
                      playItemIndex: index,
                      time: Double(context?.time ?? 0),
                      preffered: preffered)
    }
}
