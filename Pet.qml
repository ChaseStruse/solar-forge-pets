pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland

// A tiny layer-shell companion. Omarchy loads this service when the plugin is
// enabled; there is no second Quickshell process or background daemon.
Item {
  id: pet

  property string mood: "idle"
  property string message: "awaiting input_"
  property bool hovered: false
  property int pulse: 0
  property double lastInteraction: Date.now()

  readonly property color ink: "#a6ffcb"
  readonly property color dimInk: "#649c83"
  readonly property color glow: "#55f5ad"
  readonly property color hot: "#ec79ff"

  readonly property string face: {
    if (mood === "sleep") return " (=-.-=)"
    if (mood === "happy") return " (=^.^=)"
    if (mood === "blink") return " (=-.-=)"
    if (hovered) return " (=o.o=)"
    return " (=o.o=)"
  }

  // Keep every pose on the same character grid. Centering individual lines
  // shifts the ears, body and tail away from each other.
  readonly property string artwork: [
    "  /\\_/\\      ",
    face + "     ",
    " /     \\     ",
    "(  | |  )_/~ ",
    " \\_m_m_/     "
  ].join("\n")

  function interact(action) {
    lastInteraction = Date.now()
    responseTimer.restart()
    if (action === "FEED") {
      mood = "happy"
      message = "crunching bytes... yum!"
    } else if (action === "NAP") {
      mood = "sleep"
      message = "suspending to dreamland"
      responseTimer.stop()
    } else {
      mood = "happy"
      message = "affection.exe running"
    }
  }

  Timer {
    id: responseTimer
    interval: 3200
    onTriggered: {
      if (pet.hovered) {
        pet.mood = "idle"
        pet.message = "cursor detected <3"
      } else {
        pet.mood = "idle"
        pet.message = "awaiting input_"
      }
    }
  }

  Timer {
    interval: 4200
    running: true
    repeat: true
    onTriggered: {
      pet.pulse++
      if (pet.hovered || responseTimer.running) return
      if (Date.now() - pet.lastInteraction > 90000) {
        pet.mood = "sleep"
        pet.message = "idle: dreaming in hex"
      } else {
        pet.mood = pet.pulse % 4 === 0 ? "blink" : "idle"
        pet.message = pet.pulse % 3 === 0 ? "compiling good vibes" : "awaiting input_"
      }
    }
  }

  PanelWindow {
    id: window
    visible: true
    implicitWidth: 226
    implicitHeight: 205
    anchors { right: true; bottom: true }
    margins { right: 24; bottom: 24 }
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "solar-forge-pet"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    Rectangle {
      id: card
      anchors.fill: parent
      radius: 9
      color: "#ea09131a"
      border.width: 1
      border.color: pet.hovered ? pet.hot : pet.glow

      Rectangle {
        x: 11
        y: 12
        width: 5
        height: 5
        radius: 3
        color: pet.mood === "sleep" ? pet.dimInk : pet.glow
        opacity: pet.mood === "sleep" ? 0.5 : (pet.pulse % 2 === 0 ? 1 : 0.65)
      }

      Text {
        x: 25
        y: 8
        text: "SOLAR.FORGE / PET_01"
        textFormat: Text.PlainText
        font.family: "monospace"
        font.pixelSize: 10
        font.bold: true
        color: pet.dimInk
      }

      Rectangle {
        x: 11
        y: 31
        width: parent.width - 22
        height: 1
        color: pet.dimInk
        opacity: 0.5
      }

      Item {
        id: creature
        x: 18
        y: 39
        width: parent.width - 36
        height: 100

        Text {
          anchors.centerIn: parent
          text: pet.artwork
          textFormat: Text.PlainText
          horizontalAlignment: Text.AlignLeft
          font.family: "monospace"
          font.pixelSize: 16
          font.bold: true
          lineHeight: 1.0
          color: pet.mood === "sleep" ? pet.dimInk : pet.ink
        }

        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onEntered: {
            pet.hovered = true
            if (pet.mood === "sleep") pet.mood = "idle"
            if (!responseTimer.running) pet.message = "cursor detected <3"
            pet.lastInteraction = Date.now()
          }
          onExited: {
            pet.hovered = false
            if (!responseTimer.running) pet.message = "awaiting input_"
          }
          onClicked: pet.interact("PAT")
        }
      }

      Text {
        x: 13
        y: 142
        width: parent.width - 26
        text: "> " + pet.message
        elide: Text.ElideRight
        textFormat: Text.PlainText
        font.family: "monospace"
        font.pixelSize: 10
        color: pet.mood === "happy" ? pet.hot : pet.ink
      }

      Row {
        x: 12
        y: 166
        spacing: 6

        Repeater {
          model: ["PAT", "FEED", "NAP"]
          delegate: Rectangle {
            id: actionButton
            required property string modelData
            width: 63
            height: 25
            radius: 3
            color: buttonMouse.containsMouse ? "#304a43" : "#172a2a"
            border.width: 1
            border.color: buttonMouse.containsMouse ? pet.hot : pet.dimInk

            Text {
              anchors.centerIn: parent
              text: actionButton.modelData
              textFormat: Text.PlainText
              font.family: "monospace"
              font.pixelSize: 10
              font.bold: true
              color: pet.ink
            }

            MouseArea {
              id: buttonMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: pet.interact(actionButton.modelData)
            }
          }
        }
      }
    }
  }
}
