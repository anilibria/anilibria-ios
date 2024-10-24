//
//  FilterData.swift
//  Anilibria
//
//  Created by Ivan Morozov on 05.10.2024.
//  Copyright © 2024 Иван Морозов. All rights reserved.
//


public struct FilterData {
    var ageRatings: [AgeRating] = []
    var genres: [Genre] = []
    var productionStatuses: [DescribedValue<String>] = []
    var publishStatuses: [DescribedValue<String>] = []
    var seasons: [DescribedValue<String>] = []
    var sortings: [Sorting] = []
    var releaseTypes: [DescribedValue<String>] = []
    var years: [Int] = []
}
