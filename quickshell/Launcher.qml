import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets

PanelWindow {
    id: root

    property string query: ""
    readonly property var apps: DesktopEntries.applications.values
        .filter(a => !a.noDisplay && [a.name, a.genericName ?? "", ...(a.keywords ?? [])]
            .join(" ").toLowerCase().includes(query.toLowerCase()))
        .sort((a, b) => a.name.localeCompare(b.name))

    function toggle() {
        visible = !visible;
        if (visible) {
            input.text = "";
            list.currentIndex = 0;
            input.forceActiveFocus();
        }
    }

    function launch(entry) {
        visible = false;
        entry.execute();
    }

    visible: false
    screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    color: Theme.dim
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "quickshell-launcher"

    IpcHandler {
        target: "launcher"
        function toggle(): void { root.toggle(); }
    }

    // click outside closes
    MouseArea { anchors.fill: parent; onClicked: root.visible = false }

    Rectangle {
        anchors.centerIn: parent
        width: 540
        height: 460
        radius: Theme.radius
        color: Theme.base
        border.color: Theme.cobalt
        border.width: 2

        MouseArea { anchors.fill: parent } // swallow clicks inside the panel

        Rectangle {
            id: searchBox
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 14 }
            height: 44
            radius: 10
            color: Theme.surface
            border.color: input.activeFocus ? Theme.magenta : Theme.overlay

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 14
                text: "󰍉"
                color: Theme.violet
                font { family: Theme.font; pixelSize: 16 }
            }

            TextInput {
                id: input
                anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: 40; rightMargin: 14 }
                focus: true
                color: Theme.text
                selectionColor: Theme.overlay
                font { family: Theme.font; pixelSize: 15 }
                onTextChanged: { root.query = text; list.currentIndex = 0; }

                Keys.onEscapePressed: root.visible = false
                Keys.onUpPressed: list.decrementCurrentIndex()
                Keys.onDownPressed: list.incrementCurrentIndex()
                Keys.onReturnPressed: if (root.apps.length) root.launch(root.apps[list.currentIndex])
                Keys.onEnterPressed: if (root.apps.length) root.launch(root.apps[list.currentIndex])

                Text {
                    visible: !input.text
                    text: "Search apps…"
                    color: Theme.muted
                    font: input.font
                }
            }
        }

        ListView {
            id: list
            anchors { top: searchBox.bottom; bottom: parent.bottom; left: parent.left; right: parent.right; margins: 14 }
            clip: true
            spacing: 2
            model: root.apps
            highlightMoveDuration: 80

            delegate: Rectangle {
                id: row
                required property var modelData
                required property int index
                readonly property bool current: ListView.isCurrentItem

                width: ListView.view.width
                height: 42
                radius: 8
                color: current ? Theme.overlay : "transparent"

                Rectangle {
                    visible: row.current
                    width: 3; height: 22; radius: 2
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.magenta
                }

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 14
                    spacing: 12

                    IconImage {
                        anchors.verticalCenter: parent.verticalCenter
                        source: Quickshell.iconPath(row.modelData.icon, "application-x-executable")
                        implicitSize: 24
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: row.modelData.name
                        color: row.current ? Theme.text : Theme.muted
                        font { family: Theme.font; pixelSize: 14 }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: list.currentIndex = row.index
                    onClicked: root.launch(row.modelData)
                }
            }
        }
    }
}
