import DITranquillity
import Foundation

final class UserRepositoryPart: DIPart {
    static func load(container: DIContainer) {
        container.register(UserRepositoryImp.init)
            .as(UserRepository.self)
            .as(Clearable.self)
            .lifetime(.single)
    }
}

protocol UserRepository: Clearable {
    func set(user: User)
    func getUser() -> User?
}

final class UserRepositoryImp: UserRepository {
    private let key: String = "USER_KEY"

    private var buffered: User?

    func set(user: User) {
        self.buffered = user
        UserDefaults.standard[key] = user
    }

    func getUser() -> User? {
        if let user = self.buffered {
            return user
        }

        self.buffered = UserDefaults.standard[key]
        return self.buffered
    }

    func clear() {
        self.buffered = nil
        UserDefaults.standard[key] = nil
    }
}
