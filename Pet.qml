pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland

// A tiny layer-shell companion. Omarchy loads this service when the plugin is
// enabled; there is no second Quickshell process or background daemon.
Item {
  id: pet

  property string mood: "idle"
  property string message: "guarding tiny treasures"
  property bool hovered: false
  property int pulse: 0
  property double lastInteraction: Date.now()

  readonly property color ink: "#a6ffcb"
  readonly property color dimInk: "#649c83"
  readonly property color glow: "#55f5ad"
  readonly property color hot: "#ec79ff"

  // The original transparent sheet has four equal 627px cells.
  readonly property int spriteFrame: mood === "sleep" ? 3
    : mood === "happy" ? 2 : mood === "blink" ? 1 : 0

  function interact(action) {
    lastInteraction = Date.now()
    responseTimer.restart()
    if (action === "FEED") {
      mood = "happy"
      message = "mmm... toasted berries!"
    } else if (action === "NAP") {
      mood = "sleep"
      message = "dreaming of dragon gold"
      responseTimer.stop()
    } else {
      mood = "happy"
      message = "a happy little rumble"
    }
  }

  Timer {
    id: blinkTimer
    interval: 180
    onTriggered: {
      if (pet.mood === "blink") pet.mood = "idle"
    }
  }

  Timer {
    id: responseTimer
    interval: 3200
    onTriggered: {
      if (pet.hovered) {
        pet.mood = "idle"
        pet.message = "a visitor! <3"
      } else {
        pet.mood = "idle"
        pet.message = "guarding tiny treasures"
      }
    }
  }

  Timer {
    interval: 4200
    running: true
    repeat: true
    onTriggered: {
      pet.pulse++
      if (pet.hovered || responseTimer.running || pet.mood === "sleep") return
      if (Date.now() - pet.lastInteraction > 90000) {
        pet.mood = "sleep"
        pet.message = "curled up on the hoard"
      } else {
        pet.mood = pet.pulse % 4 === 0 ? "blink" : "idle"
        if (pet.mood === "blink") blinkTimer.restart()
        pet.message = pet.pulse % 3 === 0 ? "one day I'll fly!" : "guarding tiny treasures"
      }
    }
  }

  PanelWindow {
    id: window
    visible: true
    implicitWidth: 226
    implicitHeight: 285
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
        text: "EMBER / HATCHLING"
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
        height: 180

        Image {
          anchors.centerIn: parent
          width: 180
          height: 180
          source: Qt.resolvedUrl("assets/ember-sprites.png")
          sourceSize: Qt.size(1254, 1254)
          sourceClipRect: Qt.rect((pet.spriteFrame % 2) * 627,
                                 Math.floor(pet.spriteFrame / 2) * 627, 627, 627)
          fillMode: Image.PreserveAspectFit
          smooth: true
          scale: pet.hovered ? 1.035 : 1
          Behavior on scale { NumberAnimation { duration: 140 } }
        }

        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onEntered: {
            pet.hovered = true
            if (pet.mood === "sleep") pet.mood = "idle"
            if (!responseTimer.running) pet.message = "a visitor! <3"
            pet.lastInteraction = Date.now()
          }
          onExited: {
            pet.hovered = false
            if (!responseTimer.running) pet.message = "guarding tiny treasures"
          }
          onClicked: pet.interact("PAT")
        }
      }

      Text {
        x: 13
        y: 222
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
        y: 246
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
