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
    if (isTyping && typingReactive) {
      if (energy <= 25) return "Tiredly coding on laptop... 💻🪫"
      if (energy <= 50) return "Coding steadily on laptop 💻"
      return "Coding frenzy on laptop! 💻⚡"
    }
    if (isSleeping) {
      if (energy <= 25) {
        if (isMusicPlaying && audioReactive) return "Drowsing to music in deep sleep... 🪫 zZz"
        return "Exhausted deep nap zZz 🪫"
      }
      if (energy <= 50) return "Low battery nap zZz 🪫"
      return "Napping peacefully zZz"
    }
    // Tier 1: Exhausted / Critical (10 - 25%) - Sitting / Resting
    if (energy <= 25) {
      if (isMusicPlaying && audioReactive) {
        if (musicTitle !== "") return "Too tired to dance, resting to " + musicTitle + " 🪫"
        return "Too tired to dance, resting to music 🪫"
      }
      return "Completely drained, resting 🪫"
    }
    // Audio / Music (Tiers 2, 3, 4)
    if (isMusicPlaying && audioReactive) {
      if (musicTitle !== "") {
        if (energy <= 50) return "Slowly swaying to " + musicTitle + " ♫"
        return "Jamming with headphones to " + musicTitle + " ♫"
      }
      if (energy <= 50) return "Slowly swaying to music with headphones ♫"
      return "Grooving to the music with headphones ♫"
    }
    if (isHeavyLoad) return "Puffing / High CPU load!"

    // Tier 2: Low Energy (25 - 50%)
    if (energy <= 50) {
      if (!isRoaming) return "Low battery, resting tiredly 🪫"
      return "Low battery, plodding sluggishly... 🪫"
    }

    // Tier 3: Medium Energy (50 - 75%)
    if (energy <= 75) {
      if (currentState === "run") {
        if (animal === "capy") return "Waddling calmly with yuzu 🍊"
        if (animal === "dog") return "Trotting along runway 🐾"
        if (animal === "bunny") return "Hopping along the runway 🐇"
        return "Prowling along the bar 🐾"
      }
      if (animal === "capy") return "Resting calmly"
      if (animal === "dog") return "Sitting attentively"
      if (animal === "bunny") return "Sitting cute & alert"
      return "Sitting comfortably"
    }

    // Tier 4: High Energy (75 - 100%)
    if (currentState === "run") {
      if (animal === "capy") return "Trotting energetically with yuzu! ⚡"
      if (animal === "dog") return "Trotting briskly & full of energy! ⚡"
      if (animal === "bunny") return "Brisk binkies & energetic hops! ⚡"
      return "Prowling briskly & full of energy! ⚡"
    }
    if (animal === "capy") return "Quick breather, feeling great! ⚡"
    if (animal === "dog") return "Perked up and ready to zoom! ⚡"
    if (animal === "bunny") return "Wiggling nose with high energy! ⚡"
    return "Sitting alert & full of pep! ⚡"
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
    snackEnergyBonus = Math.min(80, snackEnergyBonus + 4)
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
      snackEnergyBonus = Math.min(80, snackEnergyBonus + 15)
      isHappy = true
      happyTimer.restart()
      particleTrigger(favoriteSnack.icon, favoriteSnack.color)
      petInteraction(favoriteSnack.id)
    } else if (snack === "coffee") {
      snackEnergyBonus = Math.min(80, snackEnergyBonus + 8)
      coffeeActive = true
      coffeeTimer.restart()
      isTyping = true
      typingDecayTimer.restart()
      particleTrigger("☕", "#e09050")
      petInteraction("coffee")
    } else if (snack === "milk") {
      snackEnergyBonus = Math.min(80, snackEnergyBonus + 8)
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
    if (coffeeActive) {
      currentState = "type"
      return
    }
    if (typingReactive && isTyping) {
      currentState = "type"
      return
    }
    if (isSleeping) {
      currentState = "sleep"
      return
    }
    // Critical Exhausted Tier (10 - 25%): Full sit & sleep only.
    // Even if music is playing or CPU load is high, pet sits quietly. Typing is handled above.
    if (energy <= 25) {
      currentState = "sit"
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

  onEnergyChanged: {
    if (energy <= 25) {
      isRoaming = false
    }
    updateCurrentState()
  }

  onIsHappyChanged: updateCurrentState()
  onIsSleepingChanged: updateCurrentState()
  onCoffeeActiveChanged: updateCurrentState()
  onIsTypingChanged: updateCurrentState()
  onIsMusicPlayingChanged: updateCurrentState()
  onIsHeavyLoadChanged: updateCurrentState()
  onIsRoamingChanged: updateCurrentState()

  // Roaming & Rest Cycle Timer (Scaled dynamically with 4 energy tiers)
  Timer {
    id: roamCycleTimer
    interval: 8000
    repeat: true
    running: !root.isSleeping && !root.isTyping && !root.coffeeActive && (root.energy <= 25 || !root.isMusicPlaying)
    onTriggered: {
      var e = root.energy // 10 - 100

      // Tier 1: Exhausted / Critical (10 - 25%) -> Full sitting & sleeping only, no roaming
      if (e <= 25) {
        root.isRoaming = false
        if (!root.isSleeping) {
          // Fall asleep for an exhausted nap
          root.isSleeping = true
          sleepTimer.interval = 12000 + Math.random() * 4000 // 12s - 16s sleep
          sleepTimer.restart()
        }
        // Sitting duration between naps: 8s - 12s
        interval = 9000 + Math.random() * 3000
        return
      }

      // Tier 2: Low Energy (25 - 50%) -> Sluggish, mostly sits/rests, short strolls, catnap chance
      if (e <= 50) {
        if (root.isRoaming) {
          root.isRoaming = false
          var restBaseLow = 12000 + Math.round((50 - e) * 240) // ~12s - 18s rest
          interval = restBaseLow + Math.random() * 3000

          // Spontaneous catnap chance while sitting (35%)
          if (Math.random() < 0.35) {
            root.isSleeping = true
            sleepTimer.interval = 8000 + Math.round((50 - e) * 160)
            sleepTimer.restart()
          }
        } else {
          root.isRoaming = true
          var roamBaseLow = 3500 + Math.round((e - 25) * 140) // ~3.5s - 7s roam
          interval = roamBaseLow + Math.random() * 2000
        }
        return
      }

      // Tier 3: Medium Energy (50 - 75%) -> Balanced activity and rest
      if (e <= 75) {
        if (root.isRoaming) {
          root.isRoaming = false
          var restBaseMed = 6000 + Math.round((75 - e) * 120) // ~6s - 9s rest
          interval = restBaseMed + Math.random() * 2000
        } else {
          root.isRoaming = true
          var roamBaseMed = 8000 + Math.round((e - 50) * 200) // ~8s - 13s roam
          interval = roamBaseMed + Math.random() * 2000
        }
        return
      }

      // Tier 4: High Energy (75 - 100%) -> Energetic, brisk, roams most of the time
      if (root.isRoaming) {
        root.isRoaming = false
        var restBaseHigh = 3000 + Math.round((100 - e) * 80) // ~3s - 5s rest
        interval = restBaseHigh + Math.random() * 1500
      } else {
        root.isRoaming = true
        var roamBaseHigh = 14000 + Math.round((e - 75) * 280) // ~14s - 21s roam
        interval = roamBaseHigh + Math.random() * 3000
      }
    }
  }

  // Energy Bonus Natural Decay Timer (Every 2 minutes, gradually digest / burn snack bonus)
  Timer {
    id: energyDecayTimer
    interval: 120000 // 2 minutes
    repeat: true
    running: root.snackEnergyBonus > 0
    onTriggered: {
      if (root.snackEnergyBonus > 0) {
        root.snackEnergyBonus = Math.max(0, root.snackEnergyBonus - 2)
      }
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
