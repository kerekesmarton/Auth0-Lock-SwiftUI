import UIKit
import SwiftUI
import Lock
import Auth0

public struct AuthView: UIViewControllerRepresentable {
    
    public var session: SessionPublisher
    
    public init(session: SessionPublisher) {
        self.session = session
    }
    
    public func makeUIViewController(context: Context) -> LockViewController {
        return Lock
            .classic()
            .withConnections{ connections in
                connections.database(name: "Username-Password-Authentication", requiresUsername: false)
        }
        .withStyle {
            $0.title = "Varadinum"
        }
        .withOptions {
            $0.closable = true
            $0.oidcConformant = true
            $0.scope = "openid profile"
        }
        .onAuth { credentials in
            self.session.save(credentials)
            self.session.retrieveUserInfo( credentials: credentials)
        }
        .onError(callback: { (error) in
            print(error.localizedDescription)
        }).controller
    }
    
    public func updateUIViewController(_ uiViewController: LockViewController, context: Context) {}
}
