# MR: Перенос сетевого слоя из master (API v2) в tvOS-ветку

**Source branch:** `feature/test-1` → **Target:** `master` (`github.com/anilibria/anilibria-ios`, HEAD `900976b`)

## Что сделано

Сетевой слой L1 полностью синхронизирован с master (REST API v2). Конфликты решены в пользу master; устаревшие tv-реализации удалены.

### L1 — BackendRepository (ядро переноса)
- `Network/NetworkManager.swift`, `Network/NetworkProtocols.swift` — заменены на версии из master (RequestData-контракт, без встроенных ретраев/куки).
- `Request/BackendAPIRequest.swift` — новый протокол + `Request/AutorizableAPIRequest.swift` (токен-авторизация вместо сессий).
- `Interseptors/` — добавлены `MainRequestModifier`, `MainRetrier`, `SimpleRetrier` из master.
- `Extension/CodableExtension.swift`, `DictionaryExtension.swift` — добавлены из master.
- `Response/BackendResponseConverter.swift` — переписан под контракты v2.
- Удалено: `PublisherExtension.swift`, `ThreadSafeCombineLatest.swift` — **L1 больше не зависит от Combine**.
- Добавлен пакет `CombineBridge` (`AnyPromise`) — мост для уровней выше, где Combine нужен.

### L0 — Common
- Добавлена модель `AniConfigInfo` (конфиг v2).
- Обновлены `ErrorCodes`, `Constants`, `Configuration`, модели/экстеншены под новые контракты; убраны лишние импорты UIKit там, где не нужны.

### L2 / L3
- `Package.swift` обновлены: зависимости от Combine вынесены на уровни L2/L3 через CombineBridge.

## Статистика
32 файла: +726 / −722 строк.

## Проверка
- Сборка и unit-тесты чистых частей (маппинг RequestData, Codable, конвертер ответов) выполнены Swift toolchain на Linux.
- Полная tvOS-сборка и интеграционные тесты требуют Xcode — нужно проверить на маке.

## Замечания для ревьюера
- Старые запросы L2 работают через адаптер поверх нового контракта — L3 не переписывался.
- Логин переведён с cookie-сессий на токены (`AutorizableAPIRequest` + `MainRequestModifier`).
