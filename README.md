# Inject

Hot reloading framework for iOS/macOS that allows you to see code changes in real-time without recompiling the entire app. Works with `UIKit`, `AppKit`, and `SwiftUI`.

## Description

Inject is a lightweight wrapper over [InjectionIII](https://github.com/johnno1962/InjectionIII) that enables hot reloading in Swift. Save hours of development time by avoiding full compilation and app restart cycles.

**Features:**
- Zero overhead in production builds (code is automatically stripped)
- Works with UIKit, AppKit, and SwiftUI
- One-time setup per view
- No need to remove code for production

## Usage Examples

### SwiftUI

```swift
import SwiftUI
import Inject

struct ContentView: View {
    @ObserveInjection var inject
    
    var body: some View {
        VStack {
            Text("Hello, World!")
            Button("Tap me") {
                print("Tapped")
            }
        }
        .enableInjection()
    }
}
```

### UIKit

```swift
import Inject

class SplitViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let paneA = Inject.ViewControllerHost(
            PaneAViewController()
        )
        
        addChild(paneA)
        view.addSubview(paneA.view)
    }
}
```

### UIKit with Hook

```swift
let myView = Inject.ViewControllerHost(MyViewController())

myView.onInjectionHook = { viewController in
    // Re-bind after reload
    presenter.ui = viewController
}
```

### Animation (SwiftUI)

```swift
InjectConfiguration.animation = .interactiveSpring()
```
