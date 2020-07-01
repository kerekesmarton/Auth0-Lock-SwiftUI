import Combine
import Auth0
import Lock

public class SessionPublisher: ObservableObject {
   
    //  This will crash unless auth0 .plist values are set up correctly
    var manager = CredentialsManager(authentication: Auth0.authentication())
    
    private var credentials: Credentials?
    private var userInfo: UserInfo?
    
    public enum SessionViewModel {
        case hasSession(user: UserInfo)
        case loading
        case guest
        case error(String)
    }
    
    @Published public var viewModel: SessionViewModel
    
    private var cancellableSet: Set<AnyCancellable> = []
    
    public init() {
        viewModel = .loading
        manager.credentials { (error, credentials) in
            if let error = error {
                self.viewModel = .error(AuthError(from: error).rawValue)
            } else if let credentials = credentials {
                self.save(credentials)
                self.retrieveUserInfo(credentials: credentials)
            }  else {
                self.viewModel = .guest
            }
        }
    }
    
    public func save(_ credentials: Credentials) {
        _ = self.manager.store(credentials: credentials)
        self.credentials = credentials
    }
    
    public func save(_ userInfo: UserInfo) {
        self.userInfo = userInfo
    }
    
    public func logout() {
        _ = manager.clear()
        userInfo = nil
        credentials = nil
        viewModel = .guest
    }
    
    public func retrieveUserInfo(credentials: Credentials) {
        guard let accessToken = credentials.accessToken else {
            return
        }
        viewModel = .loading
        Auth0
            .authentication()
            .userInfo(withAccessToken: accessToken)
            .start { result in
                switch result {
                case .success( let userInfo):
                    self.save(userInfo)
                    self.publish(viewModel: .hasSession(user: userInfo))
                case .failure(let error):
                    self.publish(viewModel: .error(AuthError(from: error).rawValue))
                }
                
        }
    }
    
    private func publish(viewModel: SessionViewModel) {
        DispatchQueue.main.async {
            self.viewModel = viewModel
        }
    }
    
}

//TODO: localize
enum AuthError: String {
    case unknown = "Something went wrong"
    case multiFactorRequired = "MFA code is required to authenticate"
    case multifactorEnrollRequired = "MFA is required, you are not enrolled"
    case multifactorCodeInvalid = "MFA code sent is invalid or expired"
    case multifactorTokenInvalid = "MFA token sent is invalid or expired"
    case passwordNotStrongEnough = "password used for Sign Up does not match strength requirements"
    case passwordAlreadyUsed = "Password used for SignUp was already used before (Password history feature is enabled)"
    case ruleError = "Unauthorized"
    case invalidCredentials = "username and/or password used for authentication are invalid"
    case accessDenied = "Access Denied"
    case tooManyAttempts = "You reached the maximum amount of attemts. Try again later."
    
    case noCredentials = "No credentials found"
    case noRefreshToken = "No refresh token found"
    case failedRefresh = "Failed to refresh"
    case touchFailed = "Touch id failed"
    case revokeFailed = "Failed to revoke"
    
    init(from error: Error) {
        
        if let error = error as? AuthenticationError, let authError = AuthError.tryAuthError(from: error) {
            self = authError
        } else if let error = error as? CredentialsManagerError {
            self = AuthError.tryManagerError(from: error)
        } else {
            self = .unknown
        }
    }
    
    static func tryManagerError(from error: CredentialsManagerError) -> AuthError {
        switch error {
        case .failedRefresh:
            return .failedRefresh
        case .noCredentials:
            return .noCredentials
        case .noRefreshToken:
            return .noRefreshToken
        case .revokeFailed:
            return .revokeFailed
        case .touchFailed:
            return .touchFailed
        }
    }
    
    static func tryAuthError(from error: AuthenticationError) -> AuthError? {
        if error.isMultifactorRequired {
            return .multiFactorRequired
        } else if error.isMultifactorEnrollRequired {
            return .multifactorEnrollRequired
        } else if error.isMultifactorCodeInvalid {
            return .multifactorCodeInvalid
        } else if error.isMultifactorTokenInvalid {
            return .multifactorTokenInvalid
        } else if error.isPasswordNotStrongEnough {
            return .passwordNotStrongEnough
        } else if error.isPasswordAlreadyUsed {
            return .passwordAlreadyUsed
        } else if error.isRuleError {
            return .ruleError
        } else if error.isInvalidCredentials {
            return .invalidCredentials
        } else if error.isAccessDenied {
            return .accessDenied
        } else if error.isTooManyAttempts  {
            return .tooManyAttempts
        } else {
            return nil
        }
    }
    
}
