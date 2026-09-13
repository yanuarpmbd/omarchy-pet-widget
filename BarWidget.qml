import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "bol.bar-pet"

  readonly property string configuredPetName: String(setting("petName", "Archie"))
  readonly property string configuredSkin: String(setting("skin", "pixel_cat"))
  readonly property bool configuredAudioReactive: Boolean(setting("audioReactive", true))
  readonly property bool configuredTypingReactive: Boolean(setting("typingReactive", true))
  readonly property bool configuredSoundEffects: Boolean(setting("soundEffects", true))
  readonly property int configuredIdleSleepTimeout: Number(setting("idleSleepTimeout", 120))
  readonly property int configuredCpuHighThreshold: Number(setting("cpuHighThreshold", 75))

  property string activeSkin: configuredSkin

  PetService {
    id: petService
    petName: root.configuredPetName
    skin: root.activeSkin
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

  function open() { if (panelLoader.item) panelLoader.item.open() }
  function close() { if (panelLoader.item) panelLoader.item.close() }
  function togglePanel() { if (panelLoader.item) panelLoader.item.toggle() }
  function closeForPopoutSwitch() { if (panelLoader.item) panelLoader.item.closeForPopoutSwitch() }

  readonly property real openPanelIndicatorWidth: button.slotSize
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
    function setSkin(name: string): void {
      root.activeSkin = name
      petService.setSkin(name)
    }
    function status(): string {
      return JSON.stringify({
        name: petService.petName,
        skin: petService.skin,
        state: petService.currentState,
        mood: petService.moodText,
        energy: petService.energy,
        cpu: petService.cpuPercent,
        isTyping: petService.isTyping,
        isMusic: petService.isMusicPlaying,
        isSleeping: petService.isSleeping
      })
    }
  }

  function buildTooltip() {
    var s = "🐾 " + petService.petName + " (" + petService.skin + ")\n"
    s += "Mood: " + petService.moodText + "\n"
    s += "Energy: " + petService.energy + "%\n"
    s += "Click: Care & Wardrobe Popover | Middle-Click: Quick Pet"
    return s
  }

  visible: true
  implicitWidth: visible ? button.implicitWidth : 0
  implicitHeight: visible ? button.implicitHeight : 0
  width: implicitWidth
  height: implicitHeight

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    tooltipText: root.buildTooltip()

    onPressed: function(b) {
      if (b === Qt.MiddleButton) {
        petService.pet()
      } else {
        // Both Left-click and Right-click open the popover drawer!
        root.togglePanel()
      }
    }

    iconComponent: Component {
      Item {
        anchors.fill: parent

        // Pixel Art Sprite
        Image {
          id: spriteImg
          anchors.centerIn: parent
          width: Style.space(26)
          height: Style.space(26)
          smooth: false // CRITICAL for razor-sharp retro pixel art
          mipmap: false
          fillMode: Image.PreserveAspectFit
          source: Qt.resolvedUrl("assets/sprites/" + petService.skin + "/" + petService.currentState + ".png")

          SequentialAnimation on y {
            running: petService.currentState === "idle"
            loops: Animation.Infinite
            NumberAnimation { to: -1; duration: 900; easing.type: Easing.InOutSine }
            NumberAnimation { to: 0; duration: 900; easing.type: Easing.InOutSine }
          }

          scale: petService.isHappy ? 1.08 : 1.0
          Behavior on scale {
            NumberAnimation { duration: 150; easing.type: Easing.OutBack }
          }
        }

        // Floating Particle Overlay
        Text {
          id: floatingParticle
          anchors.horizontalCenter: parent.horizontalCenter
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
              PauseAnimation { duration: 400 }
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
}
