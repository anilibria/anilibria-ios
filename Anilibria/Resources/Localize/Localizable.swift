
enum L10n {

    enum Alert {

        enum Title {
            /// Error
            static var `error`: String {
                return L10n.tr("Localizable", "alert.title.error")
            }
            /// Warning!
            static var `warning`: String {
                return L10n.tr("Localizable", "alert.title.warning")
            }

        }

    }

    enum Buttons {
        /// Apply
        static var `apply`: String {
            return L10n.tr("Localizable", "buttons.apply")
        }
        /// Cancel
        static var `cancel`: String {
            return L10n.tr("Localizable", "buttons.cancel")
        }
        /// Continue
        static var `continue`: String {
            return L10n.tr("Localizable", "buttons.continue")
        }
        /// Done
        static var `done`: String {
            return L10n.tr("Localizable", "buttons.done")
        }
        /// No
        static var `no`: String {
            return L10n.tr("Localizable", "buttons.no")
        }
        /// OK
        static var `ok`: String {
            return L10n.tr("Localizable", "buttons.ok")
        }
        /// Reset
        static var `reset`: String {
            return L10n.tr("Localizable", "buttons.reset")
        }
        /// Reset password
        static var `resetPassword`: String {
            return L10n.tr("Localizable", "buttons.reset_password")
        }
        /// Retry
        static var `retry`: String {
            return L10n.tr("Localizable", "buttons.retry")
        }
        /// Settings
        static var `settings`: String {
            return L10n.tr("Localizable", "buttons.settings")
        }
        /// Sign In
        static var `signIn`: String {
            return L10n.tr("Localizable", "buttons.signIn")
        }
        /// Sign Out
        static var `signOut`: String {
            return L10n.tr("Localizable", "buttons.signOut")
        }
        /// Sign up
        static var `signUp`: String {
            return L10n.tr("Localizable", "buttons.signUp")
        }
        /// Skip
        static var `skip`: String {
            return L10n.tr("Localizable", "buttons.skip")
        }
        /// Watch
        static var `watch`: String {
            return L10n.tr("Localizable", "buttons.watch")
        }
        /// Yes
        static var `yes`: String {
            return L10n.tr("Localizable", "buttons.yes")
        }

    }

    enum Common {

        enum Appearance {
            /// Dark
            static var `dark`: String {
                return L10n.tr("Localizable", "common.appearance.dark")
            }
            /// Light
            static var `light`: String {
                return L10n.tr("Localizable", "common.appearance.light")
            }
            /// System
            static var `system`: String {
                return L10n.tr("Localizable", "common.appearance.system")
            }

        }

        enum Collections {
            /// Abandoned
            static var `abandoned`: String {
                return L10n.tr("Localizable", "common.collections.abandoned")
            }
            /// Add to
            static var `addTo`: String {
                return L10n.tr("Localizable", "common.collections.add_to")
            }
            /// Favorites
            static var `favorites`: String {
                return L10n.tr("Localizable", "common.collections.favorites")
            }
            /// Planned
            static var `planned`: String {
                return L10n.tr("Localizable", "common.collections.planned")
            }
            /// Postponed
            static var `postponed`: String {
                return L10n.tr("Localizable", "common.collections.postponed")
            }
            /// Watched
            static var `watched`: String {
                return L10n.tr("Localizable", "common.collections.watched")
            }
            /// Watching
            static var `watching`: String {
                return L10n.tr("Localizable", "common.collections.watching")
            }

        }

        enum FilterSearch {
            /// Search by genre and year
            static var `title`: String {
                return L10n.tr("Localizable", "common.filter_search.title")
            }

        }

        enum GoogleSearch {
            /// Google "%@"
            static func query(_ arg1: String) -> String {
                return L10n.tr("Localizable", "common.google_search.query", arg1)
            }

        }

        enum Orientation {
            /// Landscape
            static var `landscape`: String {
                return L10n.tr("Localizable", "common.orientation.landscape")
            }
            /// Portrait
            static var `portrait`: String {
                return L10n.tr("Localizable", "common.orientation.portrait")
            }
            /// System
            static var `system`: String {
                return L10n.tr("Localizable", "common.orientation.system")
            }

        }

        enum Quality {
            /// 1080p
            static var `fullHd`: String {
                return L10n.tr("Localizable", "common.quality.full_hd")
            }
            /// 720p
            static var `hd`: String {
                return L10n.tr("Localizable", "common.quality.hd")
            }
            /// 480p
            static var `sd`: String {
                return L10n.tr("Localizable", "common.quality.sd")
            }

        }

        enum Search {
            /// Search by name
            static var `byName`: String {
                return L10n.tr("Localizable", "common.search.by_name")
            }

        }

        enum Seasons {
            /// Fall
            static var `fall`: String {
                return L10n.tr("Localizable", "common.seasons.fall")
            }
            /// Spring
            static var `spring`: String {
                return L10n.tr("Localizable", "common.seasons.spring")
            }
            /// Summer
            static var `summer`: String {
                return L10n.tr("Localizable", "common.seasons.summer")
            }
            /// Winter
            static var `winter`: String {
                return L10n.tr("Localizable", "common.seasons.winter")
            }

        }

        enum WeekDay {

            enum Short {
                /// Fri
                static var `fri`: String {
                    return L10n.tr("Localizable", "common.week_day.short.fri")
                }
                /// Mon
                static var `mon`: String {
                    return L10n.tr("Localizable", "common.week_day.short.mon")
                }
                /// Sat
                static var `sat`: String {
                    return L10n.tr("Localizable", "common.week_day.short.sat")
                }
                /// Sun
                static var `sun`: String {
                    return L10n.tr("Localizable", "common.week_day.short.sun")
                }
                /// Thu
                static var `thu`: String {
                    return L10n.tr("Localizable", "common.week_day.short.thu")
                }
                /// Tue
                static var `tue`: String {
                    return L10n.tr("Localizable", "common.week_day.short.tue")
                }
                /// Wed
                static var `wen`: String {
                    return L10n.tr("Localizable", "common.week_day.short.wen")
                }

            }
            /// Friday
            static var `fri`: String {
                return L10n.tr("Localizable", "common.week_day.fri")
            }
            /// Monday
            static var `mon`: String {
                return L10n.tr("Localizable", "common.week_day.mon")
            }
            /// on Friday
            static var `onFri`: String {
                return L10n.tr("Localizable", "common.week_day.on_fri")
            }
            /// on Monday
            static var `onMon`: String {
                return L10n.tr("Localizable", "common.week_day.on_mon")
            }
            /// on Saturday
            static var `onSat`: String {
                return L10n.tr("Localizable", "common.week_day.on_sat")
            }
            /// on Sunday
            static var `onSun`: String {
                return L10n.tr("Localizable", "common.week_day.on_sun")
            }
            /// on Thursday
            static var `onThu`: String {
                return L10n.tr("Localizable", "common.week_day.on_thu")
            }
            /// on Tuesday
            static var `onTue`: String {
                return L10n.tr("Localizable", "common.week_day.on_tue")
            }
            /// on Wednesday
            static var `onWen`: String {
                return L10n.tr("Localizable", "common.week_day.on_wen")
            }
            /// Saturday
            static var `sat`: String {
                return L10n.tr("Localizable", "common.week_day.sat")
            }
            /// Sunday
            static var `sun`: String {
                return L10n.tr("Localizable", "common.week_day.sun")
            }
            /// Thursday
            static var `thu`: String {
                return L10n.tr("Localizable", "common.week_day.thu")
            }
            /// Tuesday
            static var `tue`: String {
                return L10n.tr("Localizable", "common.week_day.tue")
            }
            /// Wednesday
            static var `wen`: String {
                return L10n.tr("Localizable", "common.week_day.wen")
            }

        }
        /// Ad
        static var `ad`: String {
            return L10n.tr("Localizable", "common.ad")
        }
        /// Appearance
        static var `appearance`: String {
            return L10n.tr("Localizable", "common.appearance")
        }
        /// Auto
        static var `auto`: String {
            return L10n.tr("Localizable", "common.auto")
        }
        /// Autoplay
        static var `autoPlay`: String {
            return L10n.tr("Localizable", "common.auto_play")
        }
        /// Autoplay next episode
        static var `autoPlayLong`: String {
            return L10n.tr("Localizable", "common.auto_play_long")
        }
        /// Content is blocked
        static var `contentBlocked`: String {
            return L10n.tr("Localizable", "common.content_blocked")
        }
        /// Default
        static var `default`: String {
            return L10n.tr("Localizable", "common.default")
        }
        /// Disabled
        static var `disabled`: String {
            return L10n.tr("Localizable", "common.disabled")
        }
        /// Do you like our voice acting?
        /// Please support our project :3
        static var `donatePls`: String {
            return L10n.tr("Localizable", "common.donate_pls")
        }
        /// Enabled
        static var `enabled`: String {
            return L10n.tr("Localizable", "common.enabled")
        }
        /// episode
        static var `episode`: String {
            return L10n.tr("Localizable", "common.episode")
        }
        /// Guest
        static var `guest`: String {
            return L10n.tr("Localizable", "common.guest")
        }
        /// Intern
        static var `intern`: String {
            return L10n.tr("Localizable", "common.intern")
        }
        /// Manual
        static var `manual`: String {
            return L10n.tr("Localizable", "common.manual")
        }
        /// (MSK)
        static var `mskTimeZone`: String {
            return L10n.tr("Localizable", "common.msk_time_zone")
        }
        /// Player orientation
        static var `orientation`: String {
            return L10n.tr("Localizable", "common.orientation")
        }
        /// Play a series on player startup
        static var `playOnStartup`: String {
            return L10n.tr("Localizable", "common.play_on_startup")
        }
        /// Playback rate
        static var `playbackRate`: String {
            return L10n.tr("Localizable", "common.playback_rate")
        }
        /// Quality
        static var `quality`: String {
            return L10n.tr("Localizable", "common.quality")
        }
        /// Related
        static var `related`: String {
            return L10n.tr("Localizable", "common.related")
        }
        /// Skip credits
        static var `skipCredits`: String {
            return L10n.tr("Localizable", "common.skip_credits")
        }
        /// Today
        static var `today`: String {
            return L10n.tr("Localizable", "common.today")
        }
        /// Tomorrow
        static var `tomorrow`: String {
            return L10n.tr("Localizable", "common.tomorrow")
        }
        /// Unmark all episodes as watched
        static var `unwatchAll`: String {
            return L10n.tr("Localizable", "common.unwatch_all")
        }
        /// Vacation
        static var `vacation`: String {
            return L10n.tr("Localizable", "common.vacation")
        }
        /// Mark all episodes as watched
        static var `watchAll`: String {
            return L10n.tr("Localizable", "common.watch_all")
        }
        /// Yesterday
        static var `yesterday`: String {
            return L10n.tr("Localizable", "common.yesterday")
        }

    }

    enum Error {
        /// Authorization failed :(
        static var `authorizationFailed`: String {
            return L10n.tr("Localizable", "error.authorization_failed")
        }
        /// Authorization is invalid :(
        static var `authorizationInvailid`: String {
            return L10n.tr("Localizable", "error.authorization_invailid")
        }
        /// Configuration file is broken D:
        static var `configirationBroken`: String {
            return L10n.tr("Localizable", "error.configiration_broken")
        }
        /// Loading configuration file failed :(
        static var `configirationEmpty`: String {
            return L10n.tr("Localizable", "error.configiration_empty")
        }
        /// (｡•́︿•̀｡)
        /// Unfortunately, we were unable to find the optimal configuration for you. To use the app you have to run a VPN.
        static var `configirationNotFound`: String {
            return L10n.tr("Localizable", "error.configiration_not_found")
        }
        /// OTP is not found
        static var `otpNotFound`: String {
            return L10n.tr("Localizable", "error.otp_not_found")
        }
        /// Recovery token is not correct
        static var `recoveryTokenNotFound`: String {
            return L10n.tr("Localizable", "error.recovery_token_not_found")
        }
        /// Linked account not found
        static var `socialAuthorizationFailed`: String {
            return L10n.tr("Localizable", "error.social_authorization_failed")
        }

    }

    enum Permission {
        /// To recieve push notifications you should enable it on the iOS Settings.
        static var `push`: String {
            return L10n.tr("Localizable", "permission.push")
        }
        /// Permission
        static var `title`: String {
            return L10n.tr("Localizable", "permission.title")
        }

    }

    enum Screen {

        enum Auth {

            enum Code {
                /// Leave this field empty if you didn't set up two factor authorization
                static var `description`: String {
                    return L10n.tr("Localizable", "screen.auth.code.description")
                }

            }
            /// Secret 2FA code
            static var `code`: String {
                return L10n.tr("Localizable", "screen.auth.code")
            }
            /// Login or email
            static var `login`: String {
                return L10n.tr("Localizable", "screen.auth.login")
            }
            /// Password
            static var `password`: String {
                return L10n.tr("Localizable", "screen.auth.password")
            }
            /// Sign In
            static var `title`: String {
                return L10n.tr("Localizable", "screen.auth.title")
            }

        }

        enum Catalog {
            /// Search
            static var `title`: String {
                return L10n.tr("Localizable", "screen.catalog.title")
            }

        }

        enum Comments {
            /// Comments
            static var `title`: String {
                return L10n.tr("Localizable", "screen.comments.title")
            }

        }

        enum Configuration {
            /// Configuration...
            static var `title`: String {
                return L10n.tr("Localizable", "screen.configuration.title")
            }

        }

        enum Feed {
            /// History
            static var `history`: String {
                return L10n.tr("Localizable", "screen.feed.history")
            }
            /// Randome release
            static var `randomRelease`: String {
                return L10n.tr("Localizable", "screen.feed.random_release")
            }
            /// Schedule
            static var `schedule`: String {
                return L10n.tr("Localizable", "screen.feed.schedule")
            }
            /// Coming soon
            static var `soonTitle`: String {
                return L10n.tr("Localizable", "screen.feed.soon_title")
            }
            /// Main
            static var `title`: String {
                return L10n.tr("Localizable", "screen.feed.title")
            }
            /// Updates
            static var `updatesTitle`: String {
                return L10n.tr("Localizable", "screen.feed.updates_title")
            }

        }

        enum Filter {

            enum Sotring {
                /// Newest
                static var `newest`: String {
                    return L10n.tr("Localizable", "screen.filter.Sotring.newest")
                }
                /// Popularity
                static var `popularity`: String {
                    return L10n.tr("Localizable", "screen.filter.Sotring.popularity")
                }

            }
            /// Age ratings
            static var `ageRatings`: String {
                return L10n.tr("Localizable", "screen.filter.age_ratings")
            }
            /// Complete
            static var `complete`: String {
                return L10n.tr("Localizable", "screen.filter.complete")
            }
            /// Genres
            static var `genres`: String {
                return L10n.tr("Localizable", "screen.filter.genres")
            }
            /// Production statuses
            static var `productionStatuses`: String {
                return L10n.tr("Localizable", "screen.filter.production_statuses")
            }
            /// Publish statuses
            static var `publishStatuses`: String {
                return L10n.tr("Localizable", "screen.filter.publish_statuses")
            }
            /// Seasons
            static var `seasons`: String {
                return L10n.tr("Localizable", "screen.filter.seasons")
            }
            /// Sorting
            static var `sotring`: String {
                return L10n.tr("Localizable", "screen.filter.sotring")
            }
            /// Filter
            static var `title`: String {
                return L10n.tr("Localizable", "screen.filter.title")
            }
            /// Types
            static var `types`: String {
                return L10n.tr("Localizable", "screen.filter.types")
            }
            /// Years
            static var `years`: String {
                return L10n.tr("Localizable", "screen.filter.years")
            }

        }

        enum LinkDevice {
            /// Code from a device
            static var `codePlaceholder`: String {
                return L10n.tr("Localizable", "screen.link_device.code_placeholder")
            }
            /// The device has been successfully linked
            static var `deviceLinked`: String {
                return L10n.tr("Localizable", "screen.link_device.device_linked")
            }
            /// Link a device
            static var `title`: String {
                return L10n.tr("Localizable", "screen.link_device.title")
            }

        }

        enum News {
            /// YouTube
            static var `title`: String {
                return L10n.tr("Localizable", "screen.news.title")
            }

        }

        enum Other {
            /// Donate
            static var `donate`: String {
                return L10n.tr("Localizable", "screen.other.donate")
            }
            /// Our team
            static var `team`: String {
                return L10n.tr("Localizable", "screen.other.team")
            }

        }

        enum RestorePassword {

            enum Buttons {
                /// I have a recovery token
                static var `recovery`: String {
                    return L10n.tr("Localizable", "screen.restore_password.buttons.recovery")
                }
                /// Resend email
                static var `resendEmail`: String {
                    return L10n.tr("Localizable", "screen.restore_password.buttons.resend_email")
                }

            }

            enum Success {
                /// You can now use this password to log in
                static var `message`: String {
                    return L10n.tr("Localizable", "screen.restore_password.success.message")
                }
                /// New password set
                static var `title`: String {
                    return L10n.tr("Localizable", "screen.restore_password.success.title")
                }

            }
            /// Email
            static var `email`: String {
                return L10n.tr("Localizable", "screen.restore_password.email")
            }
            /// Password
            static var `newPassword`: String {
                return L10n.tr("Localizable", "screen.restore_password.new_password")
            }
            /// You can set a new password.
            /// Please check your email box, we sent you an email with a recovery token.
            static var `newPasswordInfo`: String {
                return L10n.tr("Localizable", "screen.restore_password.new_password_info")
            }
            /// Repeat password
            static var `repeatPassword`: String {
                return L10n.tr("Localizable", "screen.restore_password.repeat_password")
            }
            /// You will be able to set a new password.
            ///  Please send us the email address you used to create your account. We will send you an email with instructions.
            static var `sendEmailInfo`: String {
                return L10n.tr("Localizable", "screen.restore_password.send_email_info")
            }
            /// New password
            static var `title`: String {
                return L10n.tr("Localizable", "screen.restore_password.title")
            }
            /// Recovery token
            static var `token`: String {
                return L10n.tr("Localizable", "screen.restore_password.token")
            }

        }

        enum Series {
            /// Added 
            static var `addedDate`: String {
                return L10n.tr("Localizable", "screen.series.added_date")
            }
            /// ~ %@ min
            static func approximalMinutes(_ arg1: String) -> String {
                return L10n.tr("Localizable", "screen.series.approximal_minutes", arg1)
            }
            /// File %@ saved into
            /// ~/Downloads/%@
            static func downloaded(_ arg1: String, _ arg2: String) -> String {
                return L10n.tr("Localizable", "screen.series.downloaded", arg1, arg2)
            }
            /// Duration
            static var `duration`: String {
                return L10n.tr("Localizable", "screen.series.duration")
            }
            /// Episodes
            static var `episodes`: String {
                return L10n.tr("Localizable", "screen.series.episodes")
            }
            /// Genres
            static var `genres`: String {
                return L10n.tr("Localizable", "screen.series.genres")
            }
            /// Season
            static var `season`: String {
                return L10n.tr("Localizable", "screen.series.season")
            }
            /// Status
            static var `status`: String {
                return L10n.tr("Localizable", "screen.series.status")
            }
            /// Description
            static var `title`: String {
                return L10n.tr("Localizable", "screen.series.title")
            }
            /// Type
            static var `type`: String {
                return L10n.tr("Localizable", "screen.series.type")
            }
            /// Voices
            static var `voices`: String {
                return L10n.tr("Localizable", "screen.series.voices")
            }
            /// Year
            static var `year`: String {
                return L10n.tr("Localizable", "screen.series.year")
            }

        }

        enum Settings {
            /// About
            static var `aboutApp`: String {
                return L10n.tr("Localizable", "screen.settings.about_app")
            }
            /// Common
            static var `common`: String {
                return L10n.tr("Localizable", "screen.settings.common")
            }
            /// Language
            static var `language`: String {
                return L10n.tr("Localizable", "screen.settings.language")
            }
            /// Settings
            static var `title`: String {
                return L10n.tr("Localizable", "screen.settings.title")
            }
            /// Video quality
            static var `videoQuality`: String {
                return L10n.tr("Localizable", "screen.settings.video_quality")
            }

        }

    }

    enum Stub {

        enum Collection {
            /// You didn't add any release yet
            static var `message`: String {
                return L10n.tr("Localizable", "stub.collection.message")
            }

        }

        enum History {
            /// Your watching history will be here
            static var `message`: String {
                return L10n.tr("Localizable", "stub.history.message")
            }

        }
        /// No results found for "%@"
        static func messageNotFound(_ arg1: String) -> String {
            return L10n.tr("Localizable", "stub.message_not_found", arg1)
        }
        /// Empty
        static var `title`: String {
            return L10n.tr("Localizable", "stub.title")
        }

    }

}
