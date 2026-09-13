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

  property bool editingName: false

  function startRename() {
    root.editingName = true
    Qt.callLater(function() {
      if (nameField) {
        nameField.text = root.service ? root.service.petName : "Archie"
        nameField.selectAll()
        nameField.forceActiveFocus()
      }
    })
  }

  function commitRename() {
    var newName = (nameField ? nameField.text : "").trim()
    if (!newName) newName = "Archie"
    if (root.service) root.service.rename(newName)
    if (root.hostWidget && typeof root.hostWidget.setName === "function") {
      root.hostWidget.setName(newName)
    }
    root.editingName = false
    keyCatcher.forceActiveFocus()
  }

  function cancelRename() {
    root.editingName = false
    keyCatcher.forceActiveFocus()
  }

  function selectAnimal(animalName) {
    if (root.service) root.service.setAnimal(animalName)
    if (root.hostWidget && typeof root.hostWidget.setAnimal === "function") {
      root.hostWidget.setAnimal(animalName)
    }
  }

  function open() {
    root.editingName = false
    root.controller.show()
    Qt.callLater(function() {
      if (root.opened) setCenterHoverRevealSuppressed(true)
      keyCatcher.forceActiveFocus()
    })
  }

  function close() {
    root.editingName = false
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
    bar: root.bar
    open: root.opened
    centerOnBar: false
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(380))
    contentHeight: panel.fittedContentHeight(mainColumn.implicitHeight + Style.space(24))

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      blocked: root.editingName
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }
      onTextKey: function(t) {
        if (root.editingName) return
        if (!root.service) return
        var k = String(t).toLowerCase()
        if (k === "p") { root.service.pet() }
        else if (k === "f") { root.service.feed("favorite") }
        else if (k === "c") { root.service.feed("coffee") }
        else if (k === "m") { root.service.feed("milk") }
        else if (k === "n" || k === "r") { root.startRename() }
        else if (k === "1") { root.selectAnimal("cat") }
        else if (k === "2") { root.selectAnimal("capy") }
        else if (k === "3") { root.selectAnimal("dog") }
        else if (k === "4") { root.selectAnimal("bunny") }
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

            // Large Animated Vector Avatar
            BorderSurface {
              width: Style.space(58)
              height: Style.space(58)
              color: Qt.rgba(Color.accent.r, Color.accent.g, Color.accent.b, 0.12)
              borderSpec: Border.controlSpec("normal", Color.accent, Color.accent)
              radius: Style.space(10)

              PetRenderer {
                anchors.centerIn: parent
                width: Style.space(50)
                height: Style.space(34)
                animal: root.service ? root.service.animal : "cat"
                state: root.service ? root.service.currentState : "run"
                strokeColor: Color.accent
              }

              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                  if (root.service) root.service.pet()
                }
              }
            }

            // Pet Info & Mood (with inline rename option)
            Column {
              anchors.verticalCenter: parent.verticalCenter
              width: parent.width - Style.space(58) - Style.space(14) - energyPill.implicitWidth - Style.space(8)
              spacing: Style.space(3)

              // Normal Display Mode
              Item {
                width: parent.width
                implicitHeight: Math.max(petTitleText.implicitHeight, editBtn.height)
                visible: !root.editingName

                Row {
                  id: titleRow
                  anchors.left: parent.left
                  anchors.right: parent.right
                  anchors.verticalCenter: parent.verticalCenter
                  spacing: Style.space(6)

                  Text {
                    id: petTitleText
                    text: root.service ? (root.service.petName + " (" + root.service.animal.toUpperCase() + ")") : "Archie"
                    color: root.contentForeground
                    font.family: root.contentFontFamily
                    font.pixelSize: Style.font.title
                    font.bold: true
                    elide: Text.ElideRight
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.min(implicitWidth, parent.width - editBtn.width - Style.space(6))
                  }

                  BorderSurface {
                    id: editBtn
                    width: Style.space(22)
                    height: Style.space(22)
                    anchors.verticalCenter: parent.verticalCenter
                    radius: Style.cornerRadius
                    color: editMouse.containsMouse ? Qt.rgba(Color.accent.r, Color.accent.g, Color.accent.b, 0.2) : "transparent"
                    borderSpec: Border.controlSpec("normal", editMouse.containsMouse ? Color.accent : Qt.rgba(root.contentForeground.r, root.contentForeground.g, root.contentForeground.b, 0.25), Color.accent)

                    Text {
                      anchors.centerIn: parent
                      text: "✎"
                      font.pixelSize: Style.font.caption
                      color: editMouse.containsMouse ? Color.accent : root.dim
                    }
                  }
                }

                MouseArea {
                  id: editMouse
                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  onClicked: root.startRename()
                }
              }

              // Rename Input Row
              Row {
                width: parent.width
                spacing: Style.space(4)
                visible: root.editingName

                TextField {
                  id: nameField
                  width: parent.width - saveBtn.width - cancelBtn.width - Style.space(8)
                  implicitHeight: Style.space(28)
                  placeholderText: "Pet name..."
                  foreground: root.contentForeground
                  font.family: root.contentFontFamily
                  font.pixelSize: Style.font.bodySmall
                  verticalPadding: Style.space(3)
                  horizontalPadding: Style.space(6)
                  maximumLength: 20

                  Keys.onPressed: function(event) {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                      root.commitRename()
                      event.accepted = true
                    } else if (event.key === Qt.Key_Escape) {
                      root.cancelRename()
                      event.accepted = true
                    }
                  }
                }

                // Save button (✓)
                BorderSurface {
                  id: saveBtn
                  width: Style.space(26)
                  height: Style.space(28)
                  radius: Style.cornerRadius
                  color: saveMouse.containsMouse ? Color.accent : Qt.rgba(Color.accent.r, Color.accent.g, Color.accent.b, 0.2)
                  borderSpec: Border.controlSpec("normal", Color.accent, Color.accent)

                  Text {
                    anchors.centerIn: parent
                    text: "✓"
                    font.pixelSize: Style.font.caption
                    font.bold: true
                    color: saveMouse.containsMouse ? Color.background : Color.accent
                  }

                  MouseArea {
                    id: saveMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.commitRename()
                  }
                }

                // Cancel button (✕)
                BorderSurface {
                  id: cancelBtn
                  width: Style.space(26)
                  height: Style.space(28)
                  radius: Style.cornerRadius
                  color: cancelMouse.containsMouse ? Qt.rgba(root.contentForeground.r, root.contentForeground.g, root.contentForeground.b, 0.15) : "transparent"
                  borderSpec: Border.controlSpec("normal", Qt.rgba(root.contentForeground.r, root.contentForeground.g, root.contentForeground.b, 0.3), Color.accent)

                  Text {
                    anchors.centerIn: parent
                    text: "✕"
                    font.pixelSize: Style.font.caption
                    color: cancelMouse.containsMouse ? Color.urgent : root.dim
                  }

                  MouseArea {
                    id: cancelMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.cancelRename()
                  }
                }
              }

              // Mood subtitle
              Text {
                text: root.service ? root.service.moodText : "Vibing"
                color: Color.accent
                font.family: root.contentFontFamily
                font.pixelSize: Style.font.caption
                elide: Text.ElideRight
                width: parent.width
                visible: !root.editingName
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
                  text: {
                    if (!root.service) return "⚡"
                    var e = root.service.energy
                    if (e > 75) return "⚡"
                    if (e > 50) return "🔋"
                    if (e > 25) return "🪫"
                    return "💤"
                  }
                  font.pixelSize: Style.font.caption
                }

                Text {
                  text: (root.service ? root.service.energy : 100) + "%"
                  color: {
                    if (!root.service) return root.contentForeground
                    var e = root.service.energy
                    if (e <= 25) return "#f38ba8"
                    if (e <= 50) return "#fab387"
                    return root.contentForeground
                  }
                  font.family: root.contentFontFamily
                  font.pixelSize: Style.font.caption
                  font.bold: true
                }
              }
            }
          }
        }

        // 2. Care & Snacks Section (Adaptive to Active Animal!)
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

          // 🐟 / 🍊 / 🦴 / 🥕 Favorite Snack (Adapts to animal)
          Button {
            width: (parent.width - Style.space(24)) / 4
            implicitHeight: Style.space(42)
            bordered: true
            onClicked: { if (root.service) root.service.feed("favorite") }

            Column {
              anchors.centerIn: parent
              spacing: Style.space(1)
              Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.service ? root.service.favoriteSnack.icon : "🐟"
                font.pixelSize: Style.font.body
              }
              Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: (root.service ? root.service.favoriteSnack.name : "Snack") + " [F]"
                color: root.contentForeground
                font.pixelSize: Style.font.caption
              }
            }
          }

          // ☕ Coffee (Hyper Zoomies)
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

          // 🥛 Milk (Nap Time)
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

        // 3. Animal Switcher (4 Distinct Animals in Style 3)
        PanelSectionHeader {
          width: parent.width
          text: "Choose Pet (Style 3 Line Art)"
        }

        Row {
          width: parent.width
          spacing: Style.space(8)

          readonly property var animals: [
            { id: "cat", name: "Cat", icon: "🐱", key: "1" },
            { id: "capy", name: "Capybara", icon: "🍊", key: "2" },
            { id: "dog", name: "Shiba", icon: "🐶", key: "3" },
            { id: "bunny", name: "Bunny", icon: "🐰", key: "4" }
          ]

          Repeater {
            model: parent.animals

            delegate: BorderSurface {
              id: animalCard
              width: (mainColumn.width - Style.space(24)) / 4
              implicitHeight: Style.space(68)
              radius: Style.cornerRadius
              readonly property bool isSelected: root.service && root.service.animal === modelData.id

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
                  root.selectAnimal(modelData.id)
                }
              }

              Column {
                anchors.centerIn: parent
                spacing: Style.space(3)

                PetRenderer {
                  anchors.horizontalCenter: parent.horizontalCenter
                  width: Style.space(34)
                  height: Style.space(22)
                  animal: modelData.id
                  state: isSelected ? (root.service ? root.service.currentState : "run") : "run"
                  strokeColor: isSelected ? Color.accent : root.contentForeground
                }

                Text {
                  anchors.horizontalCenter: parent.horizontalCenter
                  text: modelData.name + " [" + modelData.key + "]"
                  color: isSelected ? Color.accent : root.contentForeground
                  font.family: root.contentFontFamily
                  font.pixelSize: Style.font.caption
                  font.bold: isSelected
                }
              }
            }
          }
        }

        // 4. Reactivity Settings
        PanelSectionHeader {
          width: parent.width
          text: "Reactivity Settings"
        }

        Column {
          width: parent.width
          spacing: Style.space(6)

          Toggle {
            width: parent.width
            label: "Audio & Music Reactivity"
            description: "Wear glowing headphones & groove to the music beat (♫ ♪)"
            checked: root.service ? root.service.audioReactive : true
            onClicked: {
              if (root.service) root.service.audioReactive = !root.service.audioReactive
            }
          }

          Toggle {
            width: parent.width
            label: "Typing Reactivity"
            description: "Open mini laptop & tap paws when typing on keyboard"
            checked: root.service ? root.service.typingReactive : true
            onClicked: {
              if (root.service) root.service.typingReactive = !root.service.typingReactive
            }
          }

          Toggle {
            width: parent.width
            label: "Sound Effects"
            description: "Subtle purr, snack eating, and click sound effects"
            checked: root.service ? root.service.soundEffects : true
            onClicked: {
              if (root.service) root.service.soundEffects = !root.service.soundEffects
            }
          }
        }

        // 5. Footer Quick Shortcuts Bar
        BorderSurface {
          width: parent.width
          implicitHeight: shortcutColumn.implicitHeight + Style.space(12)
          color: Qt.rgba(root.contentForeground.r, root.contentForeground.g, root.contentForeground.b, 0.03)
          borderSpec: Border.controlSpec("normal", root.contentForeground, Color.accent)
          radius: Style.cornerRadius

          Column {
            id: shortcutColumn
            anchors.centerIn: parent
            spacing: Style.space(3)

            Text {
              anchors.horizontalCenter: parent.horizontalCenter
              text: "[P] Pet   •   [F] Snack   •   [C] Coffee   •   [M] Milk"
              color: root.contentForeground
              font.family: root.contentFontFamily
              font.pixelSize: Style.font.caption
            }

            Text {
              anchors.horizontalCenter: parent.horizontalCenter
              text: "[1-4] Choose Pet   •   [N] Rename   •   [Esc] Close"
              color: root.dim
              font.family: root.contentFontFamily
              font.pixelSize: Style.font.caption
            }
          }
        }
      }
    }
  }
}
