import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: root

    readonly property var actions: [
        { icon: "󰌾", label: "Lock", color: Theme.electric, cmd: ["hyprlock"] },
        { icon: "󰍃", label: "Logout", color: Theme.violet, cmd: ["hyprctl", "dispatch", "hl.dsp.exit()"] },
        { icon: "󰜉", label: "Reboot", color: Theme.coral, cmd: ["systemctl", "reboot"] },
        { icon: "⏻", label: "Shutdown", color: Theme.magenta, cmd: ["systemctl", "poweroff"] },
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
    WlrLayershell.namespace: "quickshell-power"

    IpcHandler {
        target: "power"
        function toggle(): void { root.toggle(); }
    }

    Item {
        id: keys
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: root.visible = false
    }

    MouseArea { anchors.fill: parent; onClicked: root.visible = false }

    Row {
        anchors.centerIn: parent
        spacing: 24

        Repeater {
            model: root.actions

            Rectangle {
                id: button
                required property var modelData

                width: 130
                height: 150
                radius: Theme.radius
                color: hover.containsMouse ? Theme.overlay : Theme.base
                border.color: hover.containsMouse ? modelData.color : Theme.overlay
                border.width: 2
                Behavior on color { ColorAnimation { duration: 120 } }

                Column {
                    anchors.centerIn: parent
                    spacing: 12

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: button.modelData.icon
                        color: button.modelData.color
                        font { family: Theme.font; pixelSize: 44 }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: button.modelData.label
                        color: Theme.text
                        font { family: Theme.font; pixelSize: 14; bold: true }
                    }
                }

                MouseArea {
                    id: hover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.visible = false;
                        Quickshell.execDetached(button.modelData.cmd);
                    }
                }
            }
        }
    }
}
