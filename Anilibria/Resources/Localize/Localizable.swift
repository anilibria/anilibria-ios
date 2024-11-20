// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen
// Updated by Allui

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// swiftlint:disable explicit_type_interface identifier_name line_length nesting type_body_length type_name
internal enum L10n {

  internal enum Alert {

    internal enum Title {
      /// Ошибка
      internal static var error: String {
          return L10n.tr("Localizable", "alert.title.error")
      }
      /// Внимание!
      internal static var warning: String {
          return L10n.tr("Localizable", "alert.title.warning")
      }
    }
  }

  internal enum Buttons {
    /// Применить
    internal static var apply: String {
        return L10n.tr("Localizable", "buttons.apply")
    }
    /// Отмена
    internal static var cancel: String {
        return L10n.tr("Localizable", "buttons.cancel")
    }
    /// Готово
    internal static var done: String {
        return L10n.tr("Localizable", "buttons.done")
    }
    /// Нет
    internal static var no: String {
        return L10n.tr("Localizable", "buttons.no")
    }
    /// Сброс
    internal static var reset: String {
        return L10n.tr("Localizable", "buttons.reset")
    }
    /// Повторить
    internal static var retry: String {
        return L10n.tr("Localizable", "buttons.retry")
    }
    /// Настройки
    internal static var settings: String {
        return L10n.tr("Localizable", "buttons.settings")
    }
    /// Войти
    internal static var signIn: String {
        return L10n.tr("Localizable", "buttons.signIn")
    }
    /// Выйти
    internal static var signOut: String {
        return L10n.tr("Localizable", "buttons.signOut")
    }
    /// Пропустить
    internal static var skip: String {
        return L10n.tr("Localizable", "buttons.skip")
    }
    /// Да
    internal static var yes: String {
        return L10n.tr("Localizable", "buttons.yes")
    }
  }

  internal enum Common {
    /// По умолчанию
    internal static var `default`: String {
        return L10n.tr("Localizable", "common.default")
    }
    /// Понравилась озвучка?\nПоддержи проект :3
    internal static var donatePls: String {
        return L10n.tr("Localizable", "common.donate_pls")
    }
    /// Гость
    internal static var guest: String {
        return L10n.tr("Localizable", "common.guest")
    }
    /// (по МСК)
    internal static var mskTimeZone: String {
        return L10n.tr("Localizable", "common.msk_time_zone")
    }
    /// Сегодня
    internal static var today: String {
        return L10n.tr("Localizable", "common.today")
    }
    /// Завтра
    internal static var tomorrow: String {
        return L10n.tr("Localizable", "common.tomorrow")
    }
    /// Вчера
    internal static var yesterday: String {
        return L10n.tr("Localizable", "common.yesterday")
    }

    internal enum FilterSearch {
      /// Искать по жанрам и годам
      internal static var title: String {
          return L10n.tr("Localizable", "common.filter_search.title")
      }
    }

    internal enum GoogleSearch {
      /// Найти в гугле "%@"
      internal static func query(_ p1: String) -> String {
        return L10n.tr("Localizable", "common.google_search.query", p1)
      }
    }

    internal enum Quality {
      /// 1080p
      internal static var fullHd: String {
          return L10n.tr("Localizable", "common.quality.full_hd")
      }
      /// 720p
      internal static var hd: String {
          return L10n.tr("Localizable", "common.quality.hd")
      }
      /// 480p
      internal static var sd: String {
          return L10n.tr("Localizable", "common.quality.sd")
      }
    }

    internal enum Search {
      /// Поиск по названию
      internal static var byName: String {
          return L10n.tr("Localizable", "common.search.by_name")
      }
    }

    internal enum Seasons {
      /// Осень
      internal static var fall: String {
          return L10n.tr("Localizable", "common.seasons.fall")
      }
      /// Весна
      internal static var spring: String {
          return L10n.tr("Localizable", "common.seasons.spring")
      }
      /// Лето
      internal static var summer: String {
          return L10n.tr("Localizable", "common.seasons.summer")
      }
      /// Зима
      internal static var winter: String {
          return L10n.tr("Localizable", "common.seasons.winter")
      }
    }

    internal enum WeekDay {
      /// Пятница
      internal static var fri: String {
          return L10n.tr("Localizable", "common.week_day.fri")
      }
      /// Понедельник
      internal static var mon: String {
          return L10n.tr("Localizable", "common.week_day.mon")
      }
      /// в пятницу
      internal static var onFri: String {
          return L10n.tr("Localizable", "common.week_day.on_fri")
      }
      /// в понедельник
      internal static var onMon: String {
          return L10n.tr("Localizable", "common.week_day.on_mon")
      }
      /// в субботу
      internal static var onSat: String {
          return L10n.tr("Localizable", "common.week_day.on_sat")
      }
      /// в воскресенье
      internal static var onSun: String {
          return L10n.tr("Localizable", "common.week_day.on_sun")
      }
      /// в четверг
      internal static var onThu: String {
          return L10n.tr("Localizable", "common.week_day.on_thu")
      }
      /// во вторник
      internal static var onTue: String {
          return L10n.tr("Localizable", "common.week_day.on_tue")
      }
      /// в среду
      internal static var onWen: String {
          return L10n.tr("Localizable", "common.week_day.on_wen")
      }
      /// Суббота
      internal static var sat: String {
          return L10n.tr("Localizable", "common.week_day.sat")
      }
      /// Воскресенье
      internal static var sun: String {
          return L10n.tr("Localizable", "common.week_day.sun")
      }
      /// Четверг
      internal static var thu: String {
          return L10n.tr("Localizable", "common.week_day.thu")
      }
      /// Вторник
      internal static var tue: String {
          return L10n.tr("Localizable", "common.week_day.tue")
      }
      /// Среда
      internal static var wen: String {
          return L10n.tr("Localizable", "common.week_day.wen")
      }

      internal enum Short {
        /// Пт
        internal static var fri: String {
            return L10n.tr("Localizable", "common.week_day.short.fri")
        }
        /// Пн
        internal static var mon: String {
            return L10n.tr("Localizable", "common.week_day.short.mon")
        }
        /// Сб
        internal static var sat: String {
            return L10n.tr("Localizable", "common.week_day.short.sat")
        }
        /// Вс
        internal static var sun: String {
            return L10n.tr("Localizable", "common.week_day.short.sun")
        }
        /// Чт
        internal static var thu: String {
            return L10n.tr("Localizable", "common.week_day.short.thu")
        }
        /// Вт
        internal static var tue: String {
            return L10n.tr("Localizable", "common.week_day.short.tue")
        }
        /// Ср
        internal static var wen: String {
            return L10n.tr("Localizable", "common.week_day.short.wen")
        }
      }
    }
  }

  internal enum Error {
    /// Не удалось авторизоваться :(
    internal static var authorizationFailed: String {
        return L10n.tr("Localizable", "error.authorization_failed")
    }
    /// Вы больше не авторизованы :(
    internal static var authorizationInvailid: String {
        return L10n.tr("Localizable", "error.authorization_invailid")
    }
    /// Файл кофигурации поврежден D:
    internal static var configirationBroken: String {
        return L10n.tr("Localizable", "error.configiration_broken")
    }
    /// Невозможно загрузить файл кофигурации :(
    internal static var configirationEmpty: String {
        return L10n.tr("Localizable", "error.configiration_empty")
    }
    /// (｡•́︿•̀｡)\nК сожалению, мы не смогли подобрать для вас оптимальную конфигурацию для работы приложения. Для дальнейшей работы приложения вам понадобится VPN.
    internal static var configirationNotFound: String {
        return L10n.tr("Localizable", "error.configiration_not_found")
    }
    /// Не найден связанный аккаунт
    internal static var socialAuthorizationFailed: String {
        return L10n.tr("Localizable", "error.social_authorization_failed")
    }
  }

  internal enum Permission {
    /// Для работы уведомлений вы должны разрешить "Допуск уведомлений".\nРазрешение можно установить через "Настройки"
    internal static var push: String {
        return L10n.tr("Localizable", "permission.push")
    }
    /// Разрешение
    internal static var title: String {
        return L10n.tr("Localizable", "permission.title")
    }
  }

  internal enum Screen {

    internal enum Auth {
      /// Секретный код 2FA
      internal static var code: String {
          return L10n.tr("Localizable", "screen.auth.code")
      }
      /// Логин или email
      internal static var login: String {
          return L10n.tr("Localizable", "screen.auth.login")
      }
      /// Пароль
      internal static var password: String {
          return L10n.tr("Localizable", "screen.auth.password")
      }
      /// Авторизация
      internal static var title: String {
          return L10n.tr("Localizable", "screen.auth.title")
      }

      internal enum Code {
        /// Оставьте поле пустым, если вы не настроили двухфакторную аутентификацию
        internal static var description: String {
            return L10n.tr("Localizable", "screen.auth.code.description")
        }
      }
    }

    internal enum Catalog {
      /// Поиск
      internal static var title: String {
          return L10n.tr("Localizable", "screen.catalog.title")
      }
    }

    internal enum Comments {
      /// Комментарии
      internal static var title: String {
          return L10n.tr("Localizable", "screen.comments.title")
      }
    }

    internal enum Configuration {
      /// Обновление конфигурации
      internal static var title: String {
          return L10n.tr("Localizable", "screen.configuration.title")
      }
    }

    internal enum Feed {
      /// История
      internal static var history: String {
          return L10n.tr("Localizable", "screen.feed.history")
      }
      /// Случайный релиз
      internal static var randomRelease: String {
          return L10n.tr("Localizable", "screen.feed.random_release")
      }
      /// Расписание
      internal static var schedule: String {
          return L10n.tr("Localizable", "screen.feed.schedule")
      }
      /// Ожидается
      internal static var soonTitle: String {
          return L10n.tr("Localizable", "screen.feed.soon_title")
      }
      /// Главная
      internal static var title: String {
          return L10n.tr("Localizable", "screen.feed.title")
      }
      /// Обновления
      internal static var updatesTitle: String {
          return L10n.tr("Localizable", "screen.feed.updates_title")
      }
    }

    internal enum Filter {
      /// Возрастной рейтинг
      internal static var ageRatings: String {
          return L10n.tr("Localizable", "screen.filter.age_ratings")
      }
      /// Релиз завершен
      internal static var complete: String {
          return L10n.tr("Localizable", "screen.filter.complete")
      }
      /// Жанры
      internal static var genres: String {
          return L10n.tr("Localizable", "screen.filter.genres")
      }
      /// Статус озвучки
      internal static var productionStatuses: String {
          return L10n.tr("Localizable", "screen.filter.production_statuses")
      }
      /// Статус выхода
      internal static var publishStatuses: String {
          return L10n.tr("Localizable", "screen.filter.publish_statuses")
      }
      /// Сезоны
      internal static var seasons: String {
          return L10n.tr("Localizable", "screen.filter.seasons")
      }
      /// Сортировка
      internal static var sotring: String {
          return L10n.tr("Localizable", "screen.filter.sotring")
      }
      /// Фильтр
      internal static var title: String {
          return L10n.tr("Localizable", "screen.filter.title")
      }
      /// Тип
      internal static var types: String {
          return L10n.tr("Localizable", "screen.filter.types")
      }
      /// Года
      internal static var years: String {
          return L10n.tr("Localizable", "screen.filter.years")
      }

      internal enum Sotring {
        /// Новизна
        internal static var newest: String {
            return L10n.tr("Localizable", "screen.filter.Sotring.newest")
        }
        /// Популярность
        internal static var popularity: String {
            return L10n.tr("Localizable", "screen.filter.Sotring.popularity")
        }
      }
    }

    internal enum News {
      /// YouTube
      internal static var title: String {
          return L10n.tr("Localizable", "screen.news.title")
      }
    }

    internal enum Other {
      /// Поддержать
      internal static var donate: String {
          return L10n.tr("Localizable", "screen.other.donate")
      }
      /// Список команды
      internal static var team: String {
          return L10n.tr("Localizable", "screen.other.team")
      }
    }

    internal enum Series {
      /// Добавлен 
      internal static var addedDate: String {
          return L10n.tr("Localizable", "screen.series.added_date")
      }
      /// ~ %@ мин
      internal static func approximalMinutes(_ p1: String) -> String {
        return L10n.tr("Localizable", "screen.series.approximal_minutes", p1)
      }
      /// Файл %@ сохранен в папку\n~/Downloads/%@
      internal static func downloaded(_ p1: String, _ p2: String) -> String {
        return L10n.tr("Localizable", "screen.series.downloaded", p1, p2)
      }
      /// Длительность: 
      internal static var duration: String {
          return L10n.tr("Localizable", "screen.series.duration")
      }
      /// Всего эпизодов: 
      internal static var episodes: String {
          return L10n.tr("Localizable", "screen.series.episodes")
      }
      /// Жанр: 
      internal static var genres: String {
          return L10n.tr("Localizable", "screen.series.genres")
      }
      /// Сезон: 
      internal static var season: String {
          return L10n.tr("Localizable", "screen.series.season")
      }
      /// Состояние релиза: 
      internal static var status: String {
          return L10n.tr("Localizable", "screen.series.status")
      }
      /// Описание
      internal static var title: String {
          return L10n.tr("Localizable", "screen.series.title")
      }
      /// Тип: 
      internal static var type: String {
          return L10n.tr("Localizable", "screen.series.type")
      }
      /// Голоса: 
      internal static var voices: String {
          return L10n.tr("Localizable", "screen.series.voices")
      }
      /// Год: 
      internal static var year: String {
          return L10n.tr("Localizable", "screen.series.year")
      }
    }

    internal enum Settings {
      /// О приложении
      internal static var aboutApp: String {
          return L10n.tr("Localizable", "screen.settings.about_app")
      }
      /// Общие
      internal static var common: String {
          return L10n.tr("Localizable", "screen.settings.common")
      }
      /// Язык
      internal static var language: String {
          return L10n.tr("Localizable", "screen.settings.language")
      }
      /// Настройки
      internal static var title: String {
          return L10n.tr("Localizable", "screen.settings.title")
      }
      /// Качество видео
      internal static var videoQuality: String {
          return L10n.tr("Localizable", "screen.settings.video_quality")
      }
    }
  }

  internal enum Stub {
    /// По запросу "%@" ничего не найдено
    internal static func messageNotFound(_ p1: String) -> String {
      return L10n.tr("Localizable", "stub.message_not_found", p1)
    }
    /// Нет данных
    internal static var title: String {
        return L10n.tr("Localizable", "stub.title")
    }

    internal enum Favorite {
      /// Здесь будут отображаться ваши избранные релизы
      internal static var message: String {
          return L10n.tr("Localizable", "stub.favorite.message")
      }
    }

    internal enum History {
      /// Здесь будет отображаться локальная история просмотра релизов
      internal static var message: String {
          return L10n.tr("Localizable", "stub.history.message")
      }
    }
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length nesting type_body_length type_name

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    return String(format: key.localized(using: table), arguments: args)
  }
}

private final class BundleToken {}
