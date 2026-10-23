import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Services.SystemTray
import Quickshell.Services.UPower
import Quickshell.Widgets

PanelWindow {
    id: bar
    signal powerClicked()

    anchors { top: true; left: true; right: true }
    implicitHeight: 42
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        anchors.margins: 6
        anchors.bottomMargin: 0
        radius: Theme.radius
        color: Theme.baseTranslucent
        border.color: Theme.overlay
        border.width: 1

        // Workspaces
        Row {
            anchors.left: parent.left
            anchors.leftMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6

            Repeater {
                model: Hyprland.workspaces

                Rectangle {
                    id: ws
                    required property HyprlandWorkspace modelData
                    readonly property bool focused: Hyprland.focusedWorkspace?.id === modelData.id

                    visible: modelData.id > 0 // hide special workspaces
                    width: focused ? 30 : 12
                    height: 12
                    radius: 6
                    color: modelData.urgent ? Theme.red : Theme.overlay
                    Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

                    Rectangle {
                        anchors.fill: parent
                        radius: parent.radius
                        visible: ws.focused
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0; color: Theme.cobalt }
                            GradientStop { position: 1; color: Theme.magenta }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Hyprland.dispatch("workspace " + ws.modelData.id)
                    }
                }
            }
        }

        // Clock
        Text {
            anchors.centerIn: parent
            text: Qt.formatDateTime(clock.date, "ddd dd MMM   hh:mm")
            color: Theme.text
            font { family: Theme.font; pixelSize: 13; bold: true }

            SystemClock { id: clock; precision: SystemClock.Minutes }
        }

        // Tray, volume, battery, power
        Row {
            anchors.right: parent.right
            anchors.rightMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            spacing: 14

            Repeater {
                model: SystemTray.items

                IconImage {
                    id: trayIcon
                    required property SystemTrayItem modelData
                    anchors.verticalCenter: parent.verticalCenter
                    source: modelData.icon
                    implicitSize: 16

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onClicked: mouse => {
                            if (mouse.button === Qt.LeftButton) {
                                trayIcon.modelData.activate();
                            } else if (trayIcon.modelData.hasMenu) {
                                const p = mapToItem(null, 0, height);
                                trayIcon.modelData.display(bar, p.x, p.y);
                            }
                        }
                    }
                }
            }

            Text {
                id: volume
                readonly property PwNode sink: Pipewire.defaultAudioSink

                PwObjectTracker { objects: [volume.sink] }

                visible: !!sink?.audio
                anchors.verticalCenter: parent.verticalCenter
                text: (sink?.audio?.muted ? "󰖁 " : "󰕾 ") + Math.round((sink?.audio?.volume ?? 0) * 100) + "%"
                color: sink?.audio?.muted ? Theme.muted : Theme.electric
                font { family: Theme.font; pixelSize: 13 }

                MouseArea {
                    anchors.fill: parent
                    onClicked: volume.sink.audio.muted = !volume.sink.audio.muted
                    onWheel: wheel => {
                        const step = wheel.angleDelta.y > 0 ? 0.05 : -0.05;
                        volume.sink.audio.volume = Math.max(0, Math.min(1.5, volume.sink.audio.volume + step));
                    }
                }
            }

            Text {
                readonly property var dev: UPower.displayDevice
                readonly property bool charging: dev?.state === UPowerDeviceState.Charging

                visible: dev?.isLaptopBattery ?? false
                anchors.verticalCenter: parent.verticalCenter
                text: (charging ? "󰂄 " : "󰁹 ") + Math.round((dev?.percentage ?? 0) * 100) + "%"
                color: !charging && (dev?.percentage ?? 1) < 0.2 ? Theme.coral : Theme.violet
                font { family: Theme.font; pixelSize: 13 }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "⏻"
                color: Theme.magenta
                font { family: Theme.font; pixelSize: 15; bold: true }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: bar.powerClicked()
                }
            }
        }
    }
}
