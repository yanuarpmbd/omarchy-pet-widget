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

  // Energy calculation: purely 1:1 based on laptop battery percentage
  readonly property bool onBattery: UPower.onBattery === true
  readonly property int batteryPercent: (UPower.displayDevice && UPower.displayDevice.ready && UPower.displayDevice.percentage >= 0)
    ? Math.round(UPower.displayDevice.percentage * 100)
    : 100
  readonly property int energy: Math.min(100, Math.max(0, batteryPercent))

  // Mood description
  readonly property string moodText: {
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

  // Sound player helper
  function playSound(name) {
    if (!root.soundEffects) return
    var resolved = Qt.resolvedUrl("assets/sounds/" + name + ".wav").toString()
    var path = resolved.indexOf("file://") === 0 ? resolved.substring(7) : resolved
    Quickshell.execDetached(["pw-play", path])
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

  onIsSleepingChanged: {
    if (!isSleeping && audioReactive && energy > 25) checkAudioState()
    updateCurrentState()
  }
  onAudioReactiveChanged: {
    if (audioReactive && !isSleeping && energy > 25) checkAudioState()
    else if (!audioReactive) isMusicPlaying = false
    updateCurrentState()
  }
  onIsTypingChanged: updateCurrentState()
  onIsMusicPlayingChanged: updateCurrentState()
  onIsHeavyLoadChanged: updateCurrentState()
  onIsRoamingChanged: updateCurrentState()

  // Roaming & Rest Cycle Timer (Scaled dynamically with 4 energy tiers & battery awareness)
  Timer {
    id: roamCycleTimer
    interval: 8000
    repeat: true
    running: !root.isSleeping && !root.isTyping && (root.energy <= 25 || !root.isMusicPlaying)
    onTriggered: {
      var e = root.energy // 10 - 100
      var batteryRestMult = root.onBattery ? 1.25 : 1.0
      var batteryRoamMult = root.onBattery ? 0.85 : 1.0

      // Tier 1: Exhausted / Critical (10 - 25%) -> Full sitting & sleeping only, no roaming
      if (e <= 25) {
        root.isRoaming = false
        if (!root.isSleeping) {
          // Fall asleep for an exhausted nap
          root.isSleeping = true
          sleepTimer.interval = (12000 + Math.random() * 4000) * batteryRestMult // 12s - 20s sleep
          sleepTimer.restart()
        }
        // Sitting duration between naps: 8s - 12s
        interval = (9000 + Math.random() * 3000) * batteryRestMult
        return
      }

      // Tier 2: Low Energy (25 - 50%) -> Sluggish, mostly sits/rests, short strolls, catnap chance
      if (e <= 50) {
        if (root.isRoaming) {
          root.isRoaming = false
          var restBaseLow = (12000 + Math.round((50 - e) * 240)) * batteryRestMult // ~12s - 22s rest
          interval = restBaseLow + Math.random() * 3000

          // Spontaneous catnap chance while sitting (35%)
          if (Math.random() < 0.35) {
            root.isSleeping = true
            sleepTimer.interval = (8000 + Math.round((50 - e) * 160)) * batteryRestMult
            sleepTimer.restart()
          }
        } else {
          root.isRoaming = true
          var roamBaseLow = (3500 + Math.round((e - 25) * 140)) * batteryRoamMult // ~3s - 7s roam
          interval = roamBaseLow + Math.random() * 2000
        }
        return
      }

      // Tier 3: Medium Energy (50 - 75%) -> Balanced activity and rest
      if (e <= 75) {
        if (root.isRoaming) {
          root.isRoaming = false
          var restBaseMed = (6000 + Math.round((75 - e) * 120)) * batteryRestMult // ~6s - 11s rest
          interval = restBaseMed + Math.random() * 2000
        } else {
          root.isRoaming = true
          var roamBaseMed = (8000 + Math.round((e - 50) * 200)) * batteryRoamMult // ~7s - 13s roam
          interval = roamBaseMed + Math.random() * 2000
        }
        return
      }

      // Tier 4: High Energy (75 - 100%) -> Energetic, brisk, roams most of the time
      if (root.isRoaming) {
        root.isRoaming = false
        var restBaseHigh = (3000 + Math.round((100 - e) * 80)) * batteryRestMult // ~3s - 6s rest
        interval = restBaseHigh + Math.random() * 1500
      } else {
        root.isRoaming = true
        var roamBaseHigh = (14000 + Math.round((e - 75) * 280)) * batteryRoamMult // ~12s - 21s roam
        interval = roamBaseHigh + Math.random() * 3000
      }
    }
  }

  // State Decay Timers
  Timer {
    id: typingDecayTimer
    interval: 380
    repeat: false
    onTriggered: {
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
    interval: 2000 // 2s polling interval reduces MPRIS/Pipewire scans
    repeat: true
    running: root.audioReactive && !root.isSleeping && (root.energy > 25)
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
