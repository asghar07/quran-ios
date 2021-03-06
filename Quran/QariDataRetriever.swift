//
//  QariDataRetriever.swift
//  Quran
//
//  Created by Mohamed Afifi on 4/27/16.
//  Copyright © 2016 Quran.com. All rights reserved.
//

import Foundation

struct QariDataRetriever: DataRetriever {

    func retrieve(onCompletion: @escaping ([Qari]) -> Void) {
        Queue.background.async {
            guard let readersDictionary = NSDictionary(contentsOf: Files.readers) else {
                fatalError("Couldn't load `\(Files.readers)` file")
            }

            guard let names = readersDictionary["quran_readers_name"] as? [String] else {
                fatalError("Couldn't read quran_readers_name.")
            }

            guard let haveGaplessEquivalents = readersDictionary["quran_readers_have_gapless_equivalents"] as? [Bool] else {
                fatalError("Couldn't read quran_readers_have_gapless_equivalents.")
            }

            guard let localPaths = readersDictionary["quran_readers_path"] as? [String] else {
                fatalError("Couldn't read quran_readers_path.")
            }

            guard let databaseNames = readersDictionary["quran_readers_db_name"] as? [String] else {
                fatalError("Couldn't read quran_readers_db_name.")
            }

            guard let remoteURLs = readersDictionary["quran_readers_urls"] as? [String] else {
                fatalError("Couldn't read quran_readers_urls.")
            }

            guard let images = readersDictionary["quran_readers_image"] as? [String] else {
                fatalError("Couldn't read quran_readers_image.")
            }

            guard names.count == haveGaplessEquivalents.count else {
                fatalError("Incorrect readers array count")
            }

            guard names.count == localPaths.count else {
                fatalError("Incorrect readers array count")
            }

            guard names.count == databaseNames.count else {
                fatalError("Incorrect readers array count")
            }

            guard names.count == remoteURLs.count else {
                fatalError("Incorrect readers array count")
            }

            guard names.count == images.count else {
                fatalError("Incorrect readers array count")
            }

            guard Set(localPaths).count == localPaths.count else {
                fatalError("quran_readers_path should have unique values")
            }

            var qaris: [Qari] = []

            for i in 0..<names.count {

                guard !haveGaplessEquivalents[i] else {
                    continue
                }

                let type: AudioType
                let databaseName = databaseNames[i]
                if databaseName.isEmpty {
                    type = .gapped
                } else {
                    type = .gapless(databaseName: databaseName)
                }

                let image = images[i]
                let imageName: String?
                if image.isEmpty {
                    imageName = nil
                } else {
                    imageName = image
                }

                let qari = Qari(
                    id: i,
                    name: NSLocalizedString(names[i], tableName: "Readers", comment: ""),
                    path: localPaths[i],
                    audioURL: URL(validURL: remoteURLs[i]),
                    audioType: type,
                    imageName: imageName)
                qaris.append(qari)
            }

            qaris.sort {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }


            Queue.main.async {
                onCompletion(qaris)
            }
        }
    }
}
