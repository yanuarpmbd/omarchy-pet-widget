import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower

Item {
  id: root

  // Settings & Configuration
  property string petName: "Archie"
  property string skin: "pixel_cat"
  property bool audioReactive: true
  property bool typingReactive: true
  property bool soundEffects: true
  property int idleSleepTimeout: 120
  property int cpuHighThreshold: 75

  // Reactive State
  property string currentState: "idle" // "idle", "typing_l", "typing_r", "bongo", "sleep", "sweat", "happy"
  property bool isTyping: false
  property string currentPaw: "l"
  property bool isMusicPlaying: false
  property string musicTitle: ""
  property string musicArtist: ""
  property bool isSleeping: false
  property bool isHeavyLoad: false
  property int cpuPercent: 0
  property bool isHappy: false
  property bool coffeeActive: false

  // Energy calculation
  readonly property int batteryPercent: (UPower.displayDevice && UPower.displayDevice.ready && UPower.displayDevice.percentage >= 0)
    ? Math.round(UPower.displayDevice.percentage * 100)
    : 100
  property int snackEnergyBonus: 0
  readonly property int energy: Math.min(100, Math.max(10, batteryPercent + snackEnergyBonus))

  // Mood description
  readonly property string moodText: {
    if (isHappy) return "Purring happily ♥"
    if (coffeeActive) return "Hyper caffeine zoomies! ⚡"
    if (isSleeping) return "Napping peacefully zZz"
    if (isMusicPlaying && audioReactive) {
      if (musicTitle !== "") return "Jamming to " + musicTitle
      return "Drumming to the beat ♫"
    }
    if (isTyping && typingReactive) return "Coding frenzy!"
    if (isHeavyLoad) return "Puffing / High CPU load!"
    return "Vibing quietly"
  }

  signal petInteraction(string type)
  signal particleTrigger(string symbol, color particleColor)

  // Sound player helper
  function playSound(name) {
    if (!root.soundEffects) return
    var resolved = Qt.resolvedUrl("assets/sounds/" + name + ".wav").toString()
    var path = resolved.indexOf("file://") === 0 ? resolved.substring(7) : resolved
    Quickshell.execDetached(["pw-play", path])
  }

  // Pet action (Left Click)
  function pet() {
    isSleeping = false
    isHappy = true
    happyTimer.restart()
    playSound("purr")
    particleTrigger("♥", "#f54472")
    petInteraction("pet")
  }

  // Feeding snacks
  function feed(snack) {
    isSleeping = false
    playSound("snack")
    if (snack === "fish") {
      snackEnergyBonus = Math.min(30, snackEnergyBonus + 15)
      isHappy = true
      happyTimer.restart()
      particleTrigger("🐟", "#50c8ff")
      petInteraction("fish")
    } else if (snack === "coffee") {
      coffeeActive = true
      coffeeTimer.restart()
      isTyping = true
      typingDecayTimer.restart()
      particleTrigger("☕", "#e09050")
      petInteraction("coffee")
    } else if (snack === "milk") {
      isSleeping = true
      sleepTimer.restart()
      particleTrigger("🥛", "#ffffff")
      petInteraction("milk")
    }
  }

  function setSkin(newSkin) {
    root.skin = newSkin
    playSound("click")
  }

  // Evaluate current state based on all system signals
  function updateCurrentState() {
    if (isHappy) {
      currentState = "happy"
      return
    }
    if (isSleeping) {
      currentState = "sleep"
      return
    }
    if (coffeeActive) {
      currentState = (currentPaw === "l" ? "typing_l" : "typing_r")
      return
    }
    if (typingReactive && isTyping) {
      currentState = (currentPaw === "l" ? "typing_l" : "typing_r")
      return
    }
    if (audioReactive && isMusicPlaying) {
      currentState = "bongo"
      return
    }
    if (isHeavyLoad) {
      currentState = "sweat"
      return
    }
    currentState = "idle"
  }

  onIsHappyChanged: updateCurrentState()
  onIsSleepingChanged: updateCurrentState()
  onCoffeeActiveChanged: updateCurrentState()
  onIsTypingChanged: updateCurrentState()
  onCurrentPawChanged: updateCurrentState()
  onIsMusicPlayingChanged: updateCurrentState()
  onIsHeavyLoadChanged: updateCurrentState()

  // State Decay Timers
  Timer {
    id: typingDecayTimer
    interval: root.coffeeActive ? 220 : 380
    repeat: false
    onTriggered: {
      if (!root.coffeeActive) {
        root.isTyping = false
      }
    }
  }

  Timer {
    id: happyTimer
    interval: 3500
    repeat: false
    onTriggered: {
      root.isHappy = false
    }
  }

  Timer {
    id: coffeeTimer
    interval: 10000
    repeat: false
    onTriggered: {
      root.coffeeActive = false
      root.isTyping = false
    }
  }

  Timer {
    id: sleepTimer
    interval: 12000
    repeat: false
    onTriggered: {
      root.isSleeping = false
    }
  }

  // Coffee jitter timer (alternates paws rapidly when hyper)
  Timer {
    id: coffeeJitterTimer
    interval: 120
    repeat: true
    running: root.coffeeActive
    onTriggered: {
      root.currentPaw = (root.currentPaw === "l" ? "r" : "l")
      root.isTyping = true
    }
  }

  // System Idle Monitor (Wayland)
  IdleMonitor {
    id: idleMonitor
    timeout: Math.max(30, root.idleSleepTimeout)
    respectInhibitors: true
    onIsIdleChanged: {
      if (idleMonitor.isIdle) {
        root.isSleeping = true
      } else {
        root.isSleeping = false
      }
    }
  }

  // Audio / MPRIS Player Monitor
  function checkAudioState() {
    var playing = false
    var title = ""
    var artist = ""

    if (Mpris.players && Mpris.players.values) {
      var players = Mpris.players.values
      for (var i = 0; i < players.length; i++) {
        var p = players[i]
        if (p && (p.isPlaying || String(p.playbackState).toLowerCase() === "playing")) {
          playing = true
          title = p.trackTitle || ""
          artist = p.trackArtist || ""
          break
        }
      }
    }

    // Pipewire active playback streams fallback
    if (!playing && Pipewire.nodes && Pipewire.nodes.values) {
      var nodes = Pipewire.nodes.values
      for (var j = 0; j < nodes.length; j++) {
        var n = nodes[j]
        if (n && n.isStream && n.audio && (n.isSink || String(n.type || "").indexOf("Output/Audio") !== -1)) {
          playing = true
          title = n.description || "Audio Stream"
          break
        }
      }
    }

    root.isMusicPlaying = playing
    root.musicTitle = title
    root.musicArtist = artist
  }

  Timer {
    id: audioPollTimer
    interval: 1000
    repeat: true
    running: true
    triggeredOnStart: true
    onTriggered: checkAudioState()
  }

  // Keyboard & CPU Watcher Process
  Process {
    id: watcherProcess
    command: ["python3", Qt.resolvedUrl("pet_watcher.py").toString().replace(/^file:\/\//, "")]
    running: true

    stdout: SplitParser {
      onRead: function(line) {
        var raw = String(line || "").trim()
        if (!raw || raw[0] !== "{") return
        try {
          var data = JSON.parse(raw)
          if (data.typed) {
            root.currentPaw = data.paw || (root.currentPaw === "l" ? "r" : "l")
            root.isTyping = true
            root.isSleeping = false
            typingDecayTimer.restart()
          }
          if (data.cpu !== undefined) {
            root.cpuPercent = Number(data.cpu)
            root.isHeavyLoad = (root.cpuPercent >= root.cpuHighThreshold)
          }
        } catch (e) {}
      }
    }

    onExited: function(code) {
      restartWatcherTimer.restart()
    }
  }

  Timer {
    id: restartWatcherTimer
    interval: 2000
    repeat: false
    onTriggered: {
      if (!watcherProcess.running) {
        watcherProcess.running = true
      }
    }
  }

  Component.onCompleted: {
    checkAudioState()
    updateCurrentState()
  }
}
