public final class FilterData {
    var years: [String] = []
    var genres: [String] = []
    let seasons: [TextWithTranslation] = [
        TextWithTranslation(original: "зима", translation: L10n.Common.Seasons.winter),
        TextWithTranslation(original: "весна", translation: L10n.Common.Seasons.spring),
        TextWithTranslation(original: "лето", translation: L10n.Common.Seasons.summer),
        TextWithTranslation(original: "осень", translation: L10n.Common.Seasons.fall)
    ]
}
