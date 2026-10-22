import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland
import Quickshell.Widgets

PanelWindow {
    id: root

    anchors { top: true; right: true }
    margins { top: 8; right: 12 }
    exclusionMode: ExclusionMode.Normal // sit below the bar
    implicitWidth: 380
    implicitHeight: Math.max(1, stack.implicitHeight)
    visible: server.trackedNotifications.values.length > 0
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-notifications"

    NotificationServer {
        id: server
        actionsSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        imageSupported: true
        onNotification: n => n.tracked = true
    }

    Column {
        id: stack
        width: parent.width
        spacing: 8

        Repeater {
            model: server.trackedNotifications

            Rectangle {
                id: card
                required property Notification modelData
                readonly property bool critical: modelData.urgency === NotificationUrgency.Critical
                readonly property string iconSource: modelData.image || Quickshell.iconPath(modelData.appIcon, true)

                width: stack.width
                height: content.implicitHeight + 24
                radius: Theme.radius
                color: Theme.base
                border.color: critical ? Theme.red : Theme.cobalt
                border.width: 2

                // critical notifications stay until clicked
                Timer {
                    running: !card.critical
                    interval: 5000
                    onTriggered: card.modelData.expire()
                }

                MouseArea { anchors.fill: parent; onClicked: card.modelData.dismiss() }

                Row {
                    id: content
                    x: 12
                    y: 12
                    width: parent.width - 24
                    spacing: 12

                    IconImage {
                        id: icon
                        visible: card.iconSource !== ""
                        source: card.iconSource
                        implicitSize: 40
                    }

                    Column {
                        width: content.width - (icon.visible ? icon.width + content.spacing : 0)
                        spacing: 4

                        Text {
                            width: parent.width
                            text: card.modelData.appName
                            color: Theme.violet
                            elide: Text.ElideRight
                            font { family: Theme.font; pixelSize: 11 }
                        }

                        Text {
                            width: parent.width
                            text: card.modelData.summary
                            color: Theme.text
                            elide: Text.ElideRight
                            font { family: Theme.font; pixelSize: 14; bold: true }
                        }

                        Text {
                            width: parent.width
                            visible: text !== ""
                            text: card.modelData.body
                            textFormat: Text.StyledText
                            color: Theme.muted
                            wrapMode: Text.Wrap
                            maximumLineCount: 4
                            elide: Text.ElideRight
                            font { family: Theme.font; pixelSize: 12 }
                        }

                        Row {
                            spacing: 6
                            visible: card.modelData.actions.length > 0

                            Repeater {
                                model: card.modelData.actions

                                Rectangle {
                                    id: action
                                    required property NotificationAction modelData
                                    width: label.implicitWidth + 20
                                    height: 26
                                    radius: 6
                                    color: Theme.overlay

                                    Text {
                                        id: label
                                        anchors.centerIn: parent
                                        text: action.modelData.text
                                        color: Theme.electric
                                        font { family: Theme.font; pixelSize: 12 }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: action.modelData.invoke()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
