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
  property string animal: "cat" // "cat", "capy", "dog", "bunny"
  property string skin: animal // Backwards compatibility
  property bool audioReactive: true
  property bool typingReactive: true
  property bool soundEffects: true
  property int idleSleepTimeout: 120
  property int cpuHighThreshold: 75

  // Reactive State: "run", "music", "type", "sit", "sleep", "happy", "sweat"
  property string currentState: "run"
  property bool isRoaming: true
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

  // Favorite snack metadata for active animal
  readonly property var favoriteSnack: {
    if (animal === "capy") return { id: "yuzu", name: "Yuzu", icon: "🍊", color: "#fab387" }
    if (animal === "dog") return { id: "bone", name: "Bone", icon: "🦴", color: "#f9e2af" }
    if (animal === "bunny") return { id: "carrot", name: "Carrot", icon: "🥕", color: "#fab387" }
    return { id: "fish", name: "Fish", icon: "🐟", color: "#50c8ff" }
  }

  // Mood description
  readonly property string moodText: {
    if (isHappy) {
      if (animal === "capy") return "Zen happiness ♥"
      if (animal === "dog") return "Tail wagging excitedly! ♥"
      if (animal === "bunny") return "Happy bunny binkies! ♥"
      return "Purring happily ♥"
    }
    if (coffeeActive) return "Hyper caffeine zoomies! ⚡"
    if (isSleeping) return "Napping peacefully zZz"
    if (isMusicPlaying && audioReactive) {
      if (musicTitle !== "") return "Jamming with headphones to " + musicTitle + " ♫"
      return "Grooving to the music with headphones ♫"
    }
    if (isTyping && typingReactive) return "Coding frenzy on laptop!"
    if (isHeavyLoad) return "Puffing / High CPU load!"
    if (currentState === "run") {
      if (animal === "capy") return "Waddling calmly with yuzu 🍊"
      if (animal === "dog") return "Trotting happily along runway 🐾"
      if (animal === "bunny") return "Hopping along the runway 🐇"
      return "Prowling along the bar 🐾"
    }
    if (animal === "capy") return "Resting calmly"
    if (animal === "dog") return "Sitting attentively"
    if (animal === "bunny") return "Sitting cute & alert"
    return "Sitting elegantly"
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

  // Pet action (Left / Middle Click)
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

    if (snack === "favorite" || snack === "fish" || snack === "yuzu" || snack === "bone" || snack === "carrot") {
      snackEnergyBonus = Math.min(30, snackEnergyBonus + 15)
      isHappy = true
      happyTimer.restart()
      particleTrigger(favoriteSnack.icon, favoriteSnack.color)
      petInteraction(favoriteSnack.id)
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

  function setAnimal(newAnimal) {
    root.animal = newAnimal
    root.skin = newAnimal
    playSound("click")
  }

  function rename(newName) {
    var clean = String(newName || "").trim()
    if (!clean) return
    root.petName = clean
    playSound("click")
  }

  function setSkin(newSkin) {
    // Map skins to animals if needed
    if (newSkin === "pixel_cat" || newSkin === "classic_bongo" || newSkin === "cyberpunk" || newSkin === "cat") {
      setAnimal("cat")
    } else if (newSkin === "capy" || newSkin === "capybara") {
      setAnimal("capy")
    } else if (newSkin === "shiba" || newSkin === "dog") {
      setAnimal("dog")
    } else if (newSkin === "bunny" || newSkin === "rabbit") {
      setAnimal("bunny")
    } else {
      setAnimal("cat")
    }
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
      currentState = "type"
      return
    }
    if (typingReactive && isTyping) {
      currentState = "type"
      return
    }
    if (audioReactive && isMusicPlaying) {
      currentState = "music"
      return
    }
    if (isHeavyLoad) {
      currentState = "sweat"
      return
    }
    currentState = isRoaming ? "run" : "sit"
  }

  onIsHappyChanged: updateCurrentState()
  onIsSleepingChanged: updateCurrentState()
  onCoffeeActiveChanged: updateCurrentState()
  onIsTypingChanged: updateCurrentState()
  onIsMusicPlayingChanged: updateCurrentState()
  onIsHeavyLoadChanged: updateCurrentState()
  onIsRoamingChanged: updateCurrentState()

  // Roaming & Rest Cycle Timer (Alternates roaming and sitting when idle)
  Timer {
    id: roamCycleTimer
    interval: root.isRoaming ? 12000 : 6000
    repeat: true
    running: !root.isSleeping && !root.isMusicPlaying && !root.isTyping && !root.coffeeActive
    onTriggered: {
      root.isRoaming = !root.isRoaming
      interval = root.isRoaming ? (10000 + Math.random() * 6000) : (5000 + Math.random() * 4000)
    }
  }

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
