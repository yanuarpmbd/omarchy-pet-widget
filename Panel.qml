import QtQuick
import Quickshell
import qs.Commons
import qs.Ui

Panel {
  id: root
  moduleName: "bol.bar-pet"
  ipcTarget: "bol.bar-pet"
  manageIpc: false

  property var anchorItem: null
  property var hostWidget: null
  property var service: null
  readonly property var barIdentity: hostWidget || root

  readonly property color contentForeground: bar ? bar.foreground : Color.foreground
  readonly property color contentUrgent: bar ? bar.urgent : Color.urgent
  readonly property string contentFontFamily: bar ? bar.fontFamily : Style.font.family
  readonly property color dim: Qt.darker(contentForeground, 1.45)

  function open() {
    root.controller.show()
    Qt.callLater(function() {
      if (root.opened) setCenterHoverRevealSuppressed(true)
      keyCatcher.forceActiveFocus()
    })
  }

  function close() {
    setCenterHoverRevealSuppressed(false)
    root.controller.hide()
  }

  function toggle() {
    if (root.opened) root.close()
    else root.open()
  }

  function switchPanel(direction) {
    if (root.bar && typeof root.bar.switchPanelFrom === "function")
      return root.bar.switchPanelFrom(root.barIdentity, direction)
    return false
  }

  function setCenterHoverRevealSuppressed(value) {
    if (root.bar && typeof root.bar.setCenterHoverRevealSuppressed === "function")
      root.bar.setCenterHoverRevealSuppressed(value)
    else if (root.bar && "centerHoverRevealSuppressed" in root.bar)
      root.bar.centerHoverRevealSuppressed = value
  }

  function getBarClickTargets() {
    var win = root.anchorItem ? (root.anchorItem.QsWindow ? root.anchorItem.QsWindow.window : null) : null
    if (!win || !win.contentItem) {
      return (root.bar && root.bar.clickTargets) ? root.bar.clickTargets : []
    }
    var targets = []
    function walk(item) {
      if (!item) return
      if (typeof item.triggerPress === "function" && item.visible !== false && item.opacity > 0) {
        targets.push(item)
      }
      var children = item.children
      if (children && children.length) {
        for (var i = 0; i < children.length; i++) {
          walk(children[i])
        }
      }
    }
    try {
      walk(win.contentItem)
    } catch (e) {}
    return targets.length > 0 ? targets : ((root.bar && root.bar.clickTargets) ? root.bar.clickTargets : [])
  }

  QtObject {
    id: barProxy

    readonly property color foreground: root.bar ? root.bar.foreground : "transparent"
    readonly property color barForeground: root.bar ? root.bar.barForeground : "transparent"
    readonly property color background: root.bar ? root.bar.background : "transparent"
    readonly property color urgent: root.bar ? root.bar.urgent : "transparent"
    readonly property string fontFamily: root.bar ? root.bar.fontFamily : ""
    readonly property string position: root.bar ? root.bar.position : "top"
    readonly property bool vertical: root.bar ? root.bar.vertical : false
    readonly property int barSize: root.bar ? root.bar.barSize : 0
    readonly property var activePopout: root.bar ? root.bar.activePopout : null

    readonly property var clickTargets: {
      if (root.opened) {}
      return root.getBarClickTargets()
    }

    function targetBelongsToWindow(target, window) {
      if (root.bar && typeof root.bar.targetBelongsToWindow === "function") {
        return root.bar.targetBelongsToWindow(target, window)
      }
      return !!target && !!window && target.QsWindow && target.QsWindow.window === window
    }

    function requestPopout(owner) {
      if (root.bar && typeof root.bar.requestPopout === "function") {
        root.bar.requestPopout(owner)
      }
    }

    function releasePopout(owner) {
      if (root.bar && typeof root.bar.releasePopout === "function") {
        root.bar.releasePopout(owner)
      }
    }

    function switchPanelFrom(owner, direction) {
      if (root.bar && typeof root.bar.switchPanelFrom === "function") {
        return root.bar.switchPanelFrom(owner, direction)
      }
      return false
    }

    function setCenterHoverRevealSuppressed(value) {
      if (root.bar && typeof root.bar.setCenterHoverRevealSuppressed === "function") {
        root.bar.setCenterHoverRevealSuppressed(value)
      }
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem
    owner: root.barIdentity
    bar: barProxy
    open: root.opened
    centerOnBar: false
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(380))
    contentHeight: panel.fittedContentHeight(mainColumn.implicitHeight + Style.space(24))

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }
      onTextKey: function(t) {
        if (!root.service) return
        var k = String(t).toLowerCase()
        if (k === "p") { root.service.pet() }
        else if (k === "f") { root.service.feed("fish") }
        else if (k === "c") { root.service.feed("coffee") }
        else if (k === "m") { root.service.feed("milk") }
        else if (k === "1") { root.service.setSkin("pixel_cat") }
        else if (k === "2") { root.service.setSkin("classic_bongo") }
        else if (k === "3") { root.service.setSkin("shiba") }
        else if (k === "4") { root.service.setSkin("cyberpunk") }
      }

      Column {
        id: mainColumn
        width: parent.width
        spacing: Style.space(12)

        // 1. Header Card with Large Pet Avatar
        BorderSurface {
          width: parent.width
          implicitHeight: headerRow.implicitHeight + Style.space(20)
          color: Qt.rgba(root.contentForeground.r, root.contentForeground.g, root.contentForeground.b, 0.04)
          borderSpec: Border.controlSpec("normal", root.contentForeground, Color.accent)
          radius: Style.cornerRadius

          Row {
            id: headerRow
            width: parent.width - Style.space(24)
            anchors.centerIn: parent
            spacing: Style.space(14)

            // Large Animated Avatar
            BorderSurface {
              width: Style.space(56)
              height: Style.space(56)
              color: Qt.rgba(Color.accent.r, Color.accent.g, Color.accent.b, 0.12)
              borderSpec: Border.controlSpec("normal", Color.accent, Color.accent)
              radius: Style.space(8)

              Image {
                anchors.centerIn: parent
                width: Style.space(48)
                height: Style.space(48)
                smooth: false // razor sharp retro pixels
                fillMode: Image.PreserveAspectFit
                source: root.service ? Qt.resolvedUrl("assets/sprites/" + root.service.skin + "/" + root.service.currentState + ".png") : ""

                MouseArea {
                  anchors.fill: parent
                  cursorShape: Qt.PointingHandCursor
                  onClicked: {
                    if (root.service) root.service.pet()
                  }
                }
              }
            }

            // Pet Info & Mood
            Column {
              anchors.verticalCenter: parent.verticalCenter
              width: parent.width - Style.space(56) - Style.space(14) - energyPill.implicitWidth - Style.space(8)
              spacing: Style.space(3)

              Text {
                text: root.service ? root.service.petName : "Archie"
                color: root.contentForeground
                font.family: root.contentFontFamily
                font.pixelSize: Style.font.title
                font.bold: true
              }

              Text {
                text: root.service ? root.service.moodText : "Vibing"
                color: Color.accent
                font.family: root.contentFontFamily
                font.pixelSize: Style.font.caption
                elide: Text.ElideRight
                width: parent.width
              }
            }

            // Energy Pill
            BorderSurface {
              id: energyPill
              anchors.verticalCenter: parent.verticalCenter
              implicitHeight: Style.space(26)
              implicitWidth: energyRow.implicitWidth + Style.space(14)
              color: "transparent"
              borderSpec: Border.controlSpec("normal", root.contentForeground, Color.accent)
              radius: Style.cornerRadius

              Row {
                id: energyRow
                anchors.centerIn: parent
                spacing: Style.space(5)

                Text {
                  text: (root.service && root.service.energy > 50) ? "⚡" : "🪫"
                  font.pixelSize: Style.font.caption
                }

                Text {
                  text: (root.service ? root.service.energy : 100) + "%"
                  color: root.contentForeground
                  font.family: root.contentFontFamily
                  font.pixelSize: Style.font.caption
                  font.bold: true
                }
              }
            }
          }
        }

        // 2. Care & Snacks Section
        PanelSectionHeader {
          width: parent.width
          text: "Care & Snacks"
        }

        Row {
          width: parent.width
          spacing: Style.space(8)

          // 💖 Pet
          Button {
            width: (parent.width - Style.space(24)) / 4
            implicitHeight: Style.space(42)
            bordered: true
            onClicked: { if (root.service) root.service.pet() }

            Column {
              anchors.centerIn: parent
              spacing: Style.space(1)
              Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "💖"
                font.pixelSize: Style.font.body
              }
              Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Pet [P]"
                color: root.contentForeground
                font.pixelSize: Style.font.caption
              }
            }
          }

          // 🐟 Fish
          Button {
            width: (parent.width - Style.space(24)) / 4
            implicitHeight: Style.space(42)
            bordered: true
            onClicked: { if (root.service) root.service.feed("fish") }

            Column {
              anchors.centerIn: parent
              spacing: Style.space(1)
              Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "🐟"
                font.pixelSize: Style.font.body
              }
              Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Fish [F]"
                color: root.contentForeground
                font.pixelSize: Style.font.caption
              }
            }
          }

          // ☕ Coffee
          Button {
            width: (parent.width - Style.space(24)) / 4
            implicitHeight: Style.space(42)
            bordered: true
            onClicked: { if (root.service) root.service.feed("coffee") }

            Column {
              anchors.centerIn: parent
              spacing: Style.space(1)
              Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "☕"
                font.pixelSize: Style.font.body
              }
              Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Coffee [C]"
                color: root.contentForeground
                font.pixelSize: Style.font.caption
              }
            }
          }

          // 🥛 Milk
          Button {
            width: (parent.width - Style.space(24)) / 4
            implicitHeight: Style.space(42)
            bordered: true
            onClicked: { if (root.service) root.service.feed("milk") }

            Column {
              anchors.centerIn: parent
              spacing: Style.space(1)
              Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "🥛"
                font.pixelSize: Style.font.body
              }
              Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Milk [M]"
                color: root.contentForeground
                font.pixelSize: Style.font.caption
              }
            }
          }
        }

        // 3. Wardrobe / Skin Switcher
        PanelSectionHeader {
          width: parent.width
          text: "Wardrobe & Skins"
        }

        Row {
          width: parent.width
          spacing: Style.space(8)

          readonly property var skins: [
            { id: "pixel_cat", name: "Pixel Cat", key: "1" },
            { id: "classic_bongo", name: "Bongo Cat", key: "2" },
            { id: "shiba", name: "Shiba Inu", key: "3" },
            { id: "cyberpunk", name: "Cyber Cat", key: "4" }
          ]

          Repeater {
            model: parent.skins

            delegate: BorderSurface {
              id: skinCard
              width: (mainColumn.width - Style.space(24)) / 4
              implicitHeight: Style.space(66)
              radius: Style.cornerRadius
              readonly property bool isSelected: root.service && root.service.skin === modelData.id

              color: isSelected
                ? Qt.rgba(Color.accent.r, Color.accent.g, Color.accent.b, 0.16)
                : (cardMouse.containsMouse ? Qt.rgba(root.contentForeground.r, root.contentForeground.g, root.contentForeground.b, 0.08) : "transparent")
              borderSpec: Border.controlSpec(isSelected ? "focus" : "normal", root.contentForeground, Color.accent)

              MouseArea {
                id: cardMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                  if (root.service) root.service.setSkin(modelData.id)
                }
              }

              Column {
                anchors.centerIn: parent
                spacing: Style.space(4)

                Image {
                  anchors.horizontalCenter: parent.horizontalCenter
                  width: Style.space(28)
                  height: Style.space(28)
                  smooth: false
                  fillMode: Image.PreserveAspectFit
                  source: Qt.resolvedUrl("assets/sprites/" + modelData.id + "/idle.png")
                }

                Text {
                  anchors.horizontalCenter: parent.horizontalCenter
                  text: modelData.name
                  color: isSelected ? Color.accent : root.contentForeground
                  font.family: root.contentFontFamily
                  font.pixelSize: Style.font.caption
                  font.bold: isSelected
                }
              }
            }
          }
        }

        // 4. Reactive Toggles
        PanelSectionHeader {
          width: parent.width
          text: "Reactivity Settings"
        }

        Column {
          width: parent.width
          spacing: Style.space(6)

          Toggle {
            width: parent.width
            label: "Typing Reactivity"
            description: "Animate paws tapping desk when typing"
            checked: root.service ? root.service.typingReactive : true
            onClicked: {
              if (root.service) root.service.typingReactive = !root.service.typingReactive
            }
          }

          Toggle {
            width: parent.width
            label: "Audio & Bongo Reactivity"
            description: "Play bongos when music or video audio is playing"
            checked: root.service ? root.service.audioReactive : true
            onClicked: {
              if (root.service) root.service.audioReactive = !root.service.audioReactive
            }
          }

          Toggle {
            width: parent.width
            label: "Sound Effects"
            description: "Play subtle purr, snack, and click sounds"
            checked: root.service ? root.service.soundEffects : true
            onClicked: {
              if (root.service) root.service.soundEffects = !root.service.soundEffects
            }
          }
        }

        // 5. Footer Quick Shortcuts Bar
        BorderSurface {
          width: parent.width
          implicitHeight: Style.space(28)
          color: Qt.rgba(root.contentForeground.r, root.contentForeground.g, root.contentForeground.b, 0.03)
          borderSpec: Border.controlSpec("normal", root.contentForeground, Color.accent)
          radius: Style.cornerRadius

          Text {
            anchors.centerIn: parent
            text: "Shortcuts: [P] Pet  [F] Fish  [C] Coffee  [M] Milk  [1-4] Skins  [Esc] Close"
            color: root.dim
            font.family: root.contentFontFamily
            font.pixelSize: Style.font.caption
          }
        }
      }
    }
  }
}
