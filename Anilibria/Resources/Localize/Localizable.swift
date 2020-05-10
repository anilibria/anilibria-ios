// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen
// Updated by Allui

import Foundation
import Localize_Swift

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// swiftlint:disable explicit_type_interface identifier_name line_length nesting type_body_length type_name
internal enum L10n {

  internal enum Alert {

    internal enum Message {
      /// Вы действительно хотите выйти?
      internal static var exit: String {
          return L10n.tr("Localizable", "alert.message.exit")
      }
    }

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
    /// Отмена
    internal static var cancel: String {
        return L10n.tr("Localizable", "buttons.cancel")
    }
    /// Готово
    internal static var done: String {
        return L10n.tr("Localizable", "buttons.done")
    }
    /// Пропустить
    internal static var next: String {
        return L10n.tr("Localizable", "buttons.next")
    }
    /// Нет
    internal static var no: String {
        return L10n.tr("Localizable", "buttons.no")
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
    /// Да
    internal static var yes: String {
        return L10n.tr("Localizable", "buttons.yes")
    }
  }

  internal enum Common {
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
      /// Авторизация
      internal static var title: String {
          return L10n.tr("Localizable", "screen.auth.title")
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

    internal enum Feed {
      /// СЛУЧАЙНЫЙ РЕЛИЗ
      internal static var randomRelease: String {
          return L10n.tr("Localizable", "screen.feed.random_release")
      }
      /// Рассписание
      internal static var schedule: String {
          return L10n.tr("Localizable", "screen.feed.schedule")
      }
      /// Ожидается
      internal static var soonTitle: String {
          return L10n.tr("Localizable", "screen.feed.soon_title")
      }
      /// Лента
      internal static var title: String {
          return L10n.tr("Localizable", "screen.feed.title")
      }
      /// Обновления
      internal static var updatesTitle: String {
          return L10n.tr("Localizable", "screen.feed.updates_title")
      }
    }

    internal enum Filter {
      /// Жанры
      internal static var genres: String {
          return L10n.tr("Localizable", "screen.filter.genres")
      }
      /// Сезоны
      internal static var seasons: String {
          return L10n.tr("Localizable", "screen.filter.seasons")
      }
      /// Года
      internal static var years: String {
          return L10n.tr("Localizable", "screen.filter.years")
      }
    }

    internal enum News {
      /// YouTube
      internal static var title: String {
          return L10n.tr("Localizable", "screen.news.title")
      }
    }

    internal enum Series {
      /// Добавлен 
      internal static var addedDate: String {
          return L10n.tr("Localizable", "screen.series.added_date")
      }
      /// Файл %@ сохранен в папку\n~/Downloads/%@
      internal static func downloaded(_ p1: String, _ p2: String) -> String {
        return L10n.tr("Localizable", "screen.series.downloaded", p1, p2)
      }
      /// Жанр: 
      internal static var genres: String {
          return L10n.tr("Localizable", "screen.series.genres")
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
      /// Настройки
      internal static var title: String {
          return L10n.tr("Localizable", "screen.settings.title")
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
      /// Здесь будет отображаться локальная история простомра релизов
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
