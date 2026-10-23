import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: root

    // shortcut: hand-copied from hypr/hyprland.lua, keep in sync when binds change
    readonly property var sections: [
        { title: "Apps", color: Theme.electric, binds: [
            ["SUPER + Return", "terminal"],
            ["SUPER + Space", "launcher"],
            ["SUPER + Escape", "power menu"],
            ["SUPER + /", "this cheatsheet"],
            ["SUPER + Q", "close window"],
        ] },
        { title: "Windows", color: Theme.violet, binds: [
            ["SUPER + arrows", "move focus"],
            ["SUPER + F", "fullscreen"],
            ["SUPER + P", "pseudotile"],
            ["SUPER + J", "toggle split"],
            ["SUPER + drag", "move (L) / resize (R)"],
        ] },
        { title: "Floating", color: Theme.magenta, binds: [
            ["SUPER + V", "float (centered) / tile"],
            ["SUPER + C", "center window"],
            ["SUPER + SHIFT + P", "pin to every workspace"],
            ["SUPER + ALT + arrows", "move window"],
            ["SUPER + CTRL + arrows", "resize window"],
        ] },
        { title: "Workspaces", color: Theme.cobalt, binds: [
            ["SUPER + 1-9", "go to workspace"],
            ["SUPER + SHIFT + 1-9", "move window there"],
            ["SUPER + scroll", "next / previous"],
            ["3-finger swipe", "next / previous"],
            ["SUPER + S", "show scratchpad"],
            ["SUPER + SHIFT + S", "send to scratchpad"],
        ] },
    ]

    function toggle() {
        visible = !visible;
        if (visible) keys.forceActiveFocus();
    }

    visible: false
    screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    color: Theme.dim
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "quickshell-cheatsheet"

    IpcHandler {
        target: "cheatsheet"
        function toggle(): void { root.toggle(); }
    }

    Item {
        id: keys
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: root.visible = false
    }

    MouseArea { anchors.fill: parent; onClicked: root.visible = false }

    Rectangle {
        anchors.centerIn: parent
        width: grid.implicitWidth + 56
        height: grid.implicitHeight + heading.implicitHeight + 72
        radius: Theme.radius
        color: Theme.base
        border.color: Theme.cobalt
        border.width: 2

        Text {
            id: heading
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 24
            text: "Keybinds"
            color: Theme.text
            font { family: Theme.font; pixelSize: 20; bold: true }
        }

        Grid {
            id: grid
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: heading.bottom
            anchors.topMargin: 20
            columns: 2
            columnSpacing: 40
            rowSpacing: 24

            Repeater {
                model: root.sections

                Column {
                    id: section
                    required property var modelData
                    spacing: 8

                    Text {
                        text: section.modelData.title
                        color: section.modelData.color
                        font { family: Theme.font; pixelSize: 14; bold: true }
                    }

                    Repeater {
                        model: section.modelData.binds

                        Row {
                            id: bindRow
                            required property var modelData
                            spacing: 14

                            Rectangle {
                                width: 190
                                height: 24
                                radius: 6
                                color: Theme.surface
                                border.color: Theme.overlay

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.leftMargin: 10
                                    text: bindRow.modelData[0]
                                    color: Theme.electric
                                    font { family: Theme.font; pixelSize: 12 }
                                }
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 190
                                text: bindRow.modelData[1]
                                color: Theme.text
                                font { family: Theme.font; pixelSize: 12 }
                            }
                        }
                    }
                }
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
            text: "Esc or SUPER + / to close"
            color: Theme.muted
            font { family: Theme.font; pixelSize: 11 }
        }
    }
}
