//@ pragma UseQApplication
import Quickshell

ShellRoot {
    Variants {
        model: Quickshell.screens

        Bar {
            required property var modelData
            screen: modelData
            onPowerClicked: power.toggle()
        }
    }

    Launcher {}
    Notifications {}
    PowerMenu { id: power }
    Cheatsheet {}
}
