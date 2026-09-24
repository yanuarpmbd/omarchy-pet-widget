import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "bol.bar-pet"

  readonly property string configuredPetName: String(setting("petName", "Archie"))
  readonly property string configuredAnimal: String(setting("animal", setting("skin", "capy")))
  readonly property string configuredRunwayMode: String(setting("runwayMode", "auto")) // "auto", "fixed", "compact"
  readonly property int configuredRunwayWidth: Number(setting("runwayWidth", 160))
  readonly property int configuredMaxRunwayWidth: Number(setting("maxRunwayWidth", 0))
  readonly property bool configuredAudioReactive: Boolean(setting("audioReactive", true))
  readonly property bool configuredTypingReactive: Boolean(setting("typingReactive", true))
  readonly property bool configuredSoundEffects: Boolean(setting("soundEffects", true))
  readonly property int configuredIdleSleepTimeout: Number(setting("idleSleepTimeout", 120))
  readonly property int configuredCpuHighThreshold: Number(setting("cpuHighThreshold", 75))

  property string activePetName: configuredPetName
  onConfiguredPetNameChanged: activePetName = configuredPetName

  property string activeAnimal: configuredAnimal
  onConfiguredAnimalChanged: activeAnimal = configuredAnimal

  function persistSetting(name, value) {
    var entry = { id: root.moduleName }
    for (var existing in root.settings) if (existing !== "id") entry[existing] = root.settings[existing]
    entry[name] = value
    root.settings = entry
    if (root.bar && root.bar.shell && typeof root.bar.shell.updateEntryInline === "function") {
      root.bar.shell.updateEntryInline(root.moduleName, entry)
    }
  }

  function setName(name) {
    var clean = String(name || "").trim()
    if (!clean) return
    root.activePetName = clean
    petService.rename(clean)
    root.persistSetting("petName", clean)
  }

  function setAnimal(name) {
    root.activeAnimal = name
    petService.setAnimal(name)
    root.persistSetting("animal", name)
  }

  PetService {
    id: petService
    petName: root.activePetName
    animal: root.activeAnimal
    audioReactive: root.configuredAudioReactive
    typingReactive: root.configuredTypingReactive
    soundEffects: root.configuredSoundEffects
    idleSleepTimeout: root.configuredIdleSleepTimeout
    cpuHighThreshold: root.configuredCpuHighThreshold

    onParticleTrigger: function(symbol, particleColor) {
      floatingParticle.text = symbol
      floatingParticle.color = particleColor
      particleAnim.restart()
    }
  }

  // Panel coordination
  readonly property bool opened: panelLoader.item ? panelLoader.item.opened === true : false
  readonly property bool popoutSwitchClosing: panelLoader.item ? panelLoader.item.popoutSwitchClosing === true : false

  function open() {
    if (panelLoader.item && panelLoader.item.open) panelLoader.item.open()
  }
  function close() {
    if (panelLoader.item && panelLoader.item.close) panelLoader.item.close()
  }
  function togglePanel() {
    if (panelLoader.item && panelLoader.item.toggle) panelLoader.item.toggle()
  }
  function closeForPopoutSwitch() {
    if (panelLoader.item && panelLoader.item.closeForPopoutSwitch) panelLoader.item.closeForPopoutSwitch()
  }

  // Omarchy bar click router delegates through triggerPress
  function triggerPress(b) {
    if (b === Qt.MiddleButton) {
      petService.pet()
    } else {
      root.togglePanel()
    }
  }

  readonly property real openPanelIndicatorWidth: Style.space(38)
  readonly property real openPanelIndicatorHeight: Math.max(Style.space(10), Math.round(Style.bar.iconSlot * 0.55))

  function injectPanel() {
    var target = panelLoader.item
    if (!target) return
    if ("bar" in target) target.bar = root.bar
    if ("settings" in target) target.settings = root.settings
    if ("anchorItem" in target) target.anchorItem = button
    if ("hostWidget" in target) target.hostWidget = root
    if ("service" in target) target.service = petService
  }

  onBarChanged: injectPanel()
  onSettingsChanged: injectPanel()

  Loader {
    id: panelLoader
    active: true
    source: Qt.resolvedUrl("Panel.qml")
    visible: false
    onLoaded: {
      root.injectPanel()
      Qt.callLater(root.injectPanel)
    }
  }

  // CLI / Shell IPC interface
  IpcHandler {
    target: "bol.bar-pet"

    function open(): void { root.open() }
    function close(): void { root.close() }
    function toggle(): void { root.togglePanel() }
    function pet(): void { petService.pet() }
    function feed(snack: string): void { petService.feed(snack) }
    function setName(name: string): void { root.setName(name) }
    function setAnimal(name: string): void { root.setAnimal(name) }
    function setSkin(name: string): void { root.setAnimal(name) }
    function status(): string {
      var tierStr = "high"
      if (petService.energy <= 25) tierStr = "exhausted"
      else if (petService.energy <= 50) tierStr = "low"
      else if (petService.energy <= 75) tierStr = "medium"
      return JSON.stringify({
        name: petService.petName,
        animal: petService.animal,
        state: petService.currentState,
        mood: petService.moodText,
        energy: petService.energy,
        energyTier: tierStr,
        cpu: petService.cpuPercent,
        isTyping: petService.isTyping,
        isMusic: petService.isMusicPlaying,
        isSleeping: petService.isSleeping,
        isRoaming: petService.isRoaming,
        width: root.width,
        targetWidth: root.targetRunwayWidth,
        gap: root.dynamicAvailableGap,
        trayLeft: root.trayLeftEdge,
        petStartX: root.petStartX,
        rmWidth: root.rightModulesWidth
      })
    }
  }

  property bool interactive: true
  property bool pressable: true
  property bool concealed: false

  function buildTooltip() {
    var s = "🐾 " + petService.petName + " (" + petService.animal.toUpperCase() + ")\n"
    s += "Mood: " + petService.moodText + "\n"
    var tierStr = "High"
    if (petService.energy <= 25) tierStr = "Exhausted"
    else if (petService.energy <= 50) tierStr = "Low"
    else if (petService.energy <= 75) tierStr = "Medium"
    s += "Energy: " + petService.energy + "% (" + tierStr + ")"
    return s
  }

  // ===========================================================================
  // DYNAMIC ADAPTIVE RUNWAY SIZING MATH
  // Positioned in center section right after omarchy.weather, extending towards
  // RightModules which starts with omarchy.tray (<)
  // ===========================================================================
  readonly property var anchorWindow: (root.Window && root.Window.window) ? root.Window.window : null
  readonly property real windowWidth: anchorWindow ? anchorWindow.width : 1920

  TransformWatcher {
    id: layoutWatcher
    a: anchorWindow ? anchorWindow.contentItem : null
    b: root
  }

  // Walk up to find RightModules (anchored to right of bar)
  function findRightModules() {
    var p = root.parent
    while (p) {
      if (p.children) {
        for (var i = 0; i < p.children.length; i++) {
          var c = p.children[i]
          if (c && c.region === "right") {
            return c
          }
        }
      }
      p = p.parent
    }
    return null
  }

  property var rightModulesItem: null

  function updateRightModulesRef() {
    if (!rightModulesItem) {
      rightModulesItem = findRightModules()
    }
  }

  Component.onCompleted: {
    Qt.callLater(updateRightModulesRef)
  }

  Timer {
    interval: 1000
    repeat: true
    running: !root.rightModulesItem
    onTriggered: updateRightModulesRef()
  }

  // Width of all right modules (tray, tailscale, audio, wifi, battery, etc.)
  readonly property real rightModulesWidth: {
    var rm = rightModulesItem
    if (!rm) return Style.space(160)
    return rm.width > 0 ? rm.width : (rm.implicitWidth || Style.space(160))
  }

  // Left boundary of the expand widget (<) / tray on the right
  readonly property real trayLeftEdge: windowWidth - Style.space(8) - rightModulesWidth

  // Our screen X position (starts right after omarchy.weather)
  readonly property real petStartX: {
    layoutWatcher.transform
    if (!anchorWindow || !anchorWindow.contentItem) return (windowWidth / 2) + Style.space(150)
    try {
      var pt = root.mapToItem(anchorWindow.contentItem, 0, 0)
      if (pt && pt.x > 0) return pt.x
    } catch (e) {}
    return (windowWidth / 2) + Style.space(150)
  }

  // Available gap between weather right edge and tray left edge (<)
  readonly property real dynamicAvailableGap: Math.max(Style.space(64), trayLeftEdge - petStartX - Style.space(10))

  readonly property real targetRunwayWidth: {
    if (configuredRunwayMode === "compact") return Style.bar.iconSlot
    if (configuredRunwayMode === "fixed") return configuredRunwayWidth
    // Flexible adaptive mode: fills the space between weather and tray (<)
    // If configuredMaxRunwayWidth is set above 0, it acts as an upper cap; otherwise fills the gap
    if (configuredMaxRunwayWidth > 0) return Math.min(configuredMaxRunwayWidth, dynamicAvailableGap)
    return dynamicAvailableGap
  }

  visible: true
  implicitWidth: visible ? targetRunwayWidth : 0
  implicitHeight: visible ? Style.bar.sizeHorizontal : 0
  width: implicitWidth
  height: implicitHeight

  Behavior on implicitWidth {
    NumberAnimation { duration: 240; easing.type: Easing.OutCubic }
  }

  // ===========================================================================
  // ROAMING PHYSICS ALONG THE RUNWAY
  // ===========================================================================
  property real petX: Style.space(6)
  property bool facingRight: true
  readonly property real petSlotWidth: Style.space(40)
  readonly property real maxPetX: Math.max(0, root.width - petSlotWidth - Style.space(4))

  onMaxPetXChanged: {
    if (petX > maxPetX) petX = maxPetX
  }

  property real bunnyHopProgress: 0.0

  // 60 FPS Roaming Movement Timer (Active during "run" and "music" when energy > 25%)
  Timer {
    id: roamTimer
    interval: 16 // 60 FPS
    running: petService.energy > 25 && (petService.currentState === "run" || petService.currentState === "music") && root.maxPetX > Style.space(8)
    repeat: true
    onTriggered: {
      var baseSpeed = petService.currentState === "music" ? 0.65 : 0.75
      if (petService.coffeeActive) baseSpeed = 1.2

      // Tiered energy speed factor
      var e = petService.energy
      var energyFactor = 1.0
      if (e <= 25) {
        energyFactor = 0.0 // Never moves along runway
      } else if (e <= 50) {
        // Low tier (25 - 50%): 0.50 to 0.65
        energyFactor = 0.50 + ((e - 25) / 25.0) * 0.15
      } else if (e <= 75) {
        // Medium tier (50 - 75%): 0.75 to 0.88
        energyFactor = 0.75 + ((e - 50) / 25.0) * 0.13
      } else {
        // High tier (75 - 100%): 0.95 to 1.12
        energyFactor = 0.95 + ((e - 75) / 25.0) * 0.17
      }
      var speed = baseSpeed * energyFactor

      // Bunny-specific hopping kinematics (pulsed leaps + ground pause)
      if (petService.animal === "bunny") {
        root.bunnyHopProgress = (root.bunnyHopProgress + 0.0286) % 1.0
        if (root.bunnyHopProgress <= 0.75) {
          var hopT = root.bunnyHopProgress / 0.75
          speed *= Math.sin(hopT * Math.PI) * 2.5
        } else {
          speed = 0.0 // Brief touchdown pause before next jump
        }
      }

      if (root.facingRight) {
        root.petX += speed
        if (root.petX >= root.maxPetX) {
          root.petX = root.maxPetX
          root.facingRight = false
          root.bunnyHopProgress = 0.0
        }
      } else {
        root.petX -= speed
        if (root.petX <= Style.space(2)) {
          root.petX = Style.space(2)
          root.facingRight = true
          root.bunnyHopProgress = 0.0
        }
      }
    }
  }

  // ===========================================================================
  // INTERACTIVE WIDGET BUTTON & VISUAL RUNWAY
  // Built with WidgetButton to register as click target in Omarchy Bar
  // ===========================================================================
  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    tooltipText: root.buildTooltip()
    hasVisualContent: true
    labelVisible: false
    fixedWidth: root.width
    fixedHeight: root.height

    onPressed: function(b) {
      if (b === Qt.MiddleButton) {
        petService.pet()
      } else {
        root.togglePanel()
      }
    }

    // Runway Content inside WidgetButton
    Item {
      anchors.fill: parent

      // Active Drawer Indicator dot/pill when open
      Rectangle {
        visible: root.opened
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Style.space(1)
        x: root.petX + (petSlotWidth / 2) - (width / 2)
        width: Style.space(16)
        height: 2
        radius: 1
        color: Color.accent
      }

      // Main Vector Pet Renderer
      PetRenderer {
        id: petRenderer
        width: Style.space(42)
        height: Style.space(26)
        anchors.verticalCenter: parent.verticalCenter
        x: root.petX

        animal: petService.animal
        state: petService.currentState
        facingLeft: !root.facingRight
        strokeColor: root.bar ? root.bar.barForeground : Color.accent
      }

      // Floating Interaction Particle (Hearts ♥, Snacks, Notes)
      Text {
        id: floatingParticle
        x: root.petX + (petSlotWidth / 2) - (implicitWidth / 2)
        y: parent.height * 0.2
        text: "♥"
        font.pixelSize: Style.font.caption
        opacity: 0.0

        ParallelAnimation {
          id: particleAnim
          NumberAnimation {
            target: floatingParticle
            property: "y"
            from: parent.height * 0.3
            to: -Style.space(12)
            duration: 900
            easing.type: Easing.OutCubic
          }
          SequentialAnimation {
            NumberAnimation {
              target: floatingParticle
              property: "opacity"
              from: 0.0
              to: 1.0
              duration: 150
            }
            PauseAnimation { duration: 450 }
            NumberAnimation {
              target: floatingParticle
              property: "opacity"
              from: 1.0
              to: 0.0
              duration: 350
            }
          }
        }
      }
    }
  }
}
