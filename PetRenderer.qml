import QtQuick
import QtQuick.Shapes
import qs.Commons

Item {
  id: root

  // Animal: "cat", "capy", "dog", "bunny"
  property string animal: "cat"

  // State: "run", "music", "type", "sit", "sleep", "happy"
  property string state: "run"

  // Direction: facing left or right
  property bool facingLeft: false

  // Dynamic Theme Colors
  property color strokeColor: Color.accent
  property color fillColor: Qt.alpha(strokeColor, 0.16)
  property color secondaryColor: Color.bar ? Color.bar.active : "#fab387"
  property color pinkColor: "#f38ba8"
  property color yellowColor: "#f9e2af"
  property color orangeColor: "#fab387"
  property color greenColor: "#a6e3a1"
  property color whiteColor: "#ffffff"
  property color darkColor: "#181825"

  implicitWidth: 48
  implicitHeight: 30

  // Scaler container to fit any size while preserving 50x32 aspect ratio
  Item {
    id: petCanvas
    width: 50
    height: 32
    anchors.centerIn: parent

    scale: Math.min(root.width / 50, root.height / 32)
    transformOrigin: Item.Center

    // Flip horizontally when facing left
    transform: Scale {
      xScale: root.facingLeft ? -1 : 1
      origin.x: 25
      origin.y: 16
    }

    // =========================================================================
    // 1. KUCING (CAT)
    // =========================================================================
    Item {
      id: catContainer
      anchors.fill: parent
      visible: root.animal === "cat"

      // Body Bobbing Animation
      Item {
        id: catBobber
        anchors.fill: parent

        SequentialAnimation on y {
          running: root.animal === "cat" && (root.state === "run" || root.state === "music")
          loops: Animation.Infinite
          NumberAnimation { to: -1.5; duration: root.state === "music" ? 350 : 220; easing.type: Easing.InOutSine }
          NumberAnimation { to: 0.0; duration: root.state === "music" ? 350 : 220; easing.type: Easing.InOutSine }
        }

        // Cat Sleeping Pose
        Shape {
          anchors.fill: parent
          visible: root.state === "sleep"
          layer.enabled: true
          layer.samples: 4

          ShapePath {
            strokeColor: root.strokeColor
            strokeWidth: 1.7
            fillColor: root.fillColor
            PathSvg { path: "M25,18 m-14,0 a14,8.5 0 1,0 28,0 a14,8.5 0 1,0 -28,0" }
          }
          ShapePath {
            strokeColor: root.strokeColor
            strokeWidth: 1.8
            capStyle: ShapePath.RoundCap
            fillColor: "transparent"
            PathSvg { path: "M12,20 C8,20 7,24 11,25 C15,26 20,23 20,20" }
          }
          ShapePath {
            strokeColor: root.strokeColor
            strokeWidth: 1.6
            fillColor: root.fillColor
            PathSvg { path: "M36,17 m-6.5,0 a6.5,6.5 0 1,0 13,0 a6.5,6.5 0 1,0 -13,0" }
          }
          ShapePath {
            strokeColor: root.strokeColor
            strokeWidth: 1.2
            fillColor: Qt.alpha(root.strokeColor, 0.25)
            PathSvg { path: "M32,12 L28,6 L34,10 Z M36,11 L40,6 L42,12 Z" }
          }
          ShapePath {
            strokeColor: root.whiteColor
            strokeWidth: 1.4
            capStyle: ShapePath.RoundCap
            fillColor: "transparent"
            PathSvg { path: "M35,17 L38,17" }
          }
          ShapePath {
            strokeColor: root.strokeColor
            strokeWidth: 0.8
            capStyle: ShapePath.RoundCap
            fillColor: "transparent"
            PathSvg { path: "M40,18 L45,17 M40,19 L44,20.5" }
          }
        }

        // Cat Seated Pose (Sit or Type)
        Shape {
          anchors.fill: parent
          visible: root.state === "sit" || root.state === "type"
          layer.enabled: true
          layer.samples: 4

          ShapePath {
            strokeColor: root.strokeColor
            strokeWidth: 1.7
            fillColor: root.fillColor
            PathSvg { path: "M17,25 C14,20 16,13 24,11 C31,11 36,15 37,22 C37,26 31,26 23,26 Z" }
          }
          ShapePath {
            strokeColor: root.strokeColor
            strokeWidth: 1.2
            fillColor: Qt.alpha(root.strokeColor, 0.25)
            PathSvg { path: "M21,24 m-5.5,0 a5.5,3.2 0 1,0 11,0 a5.5,3.2 0 1,0 -11,0" }
          }
          ShapePath {
            strokeColor: root.strokeColor
            strokeWidth: 1.6
            fillColor: root.fillColor
            PathSvg { path: "M34,10 m-6.8,0 a6.8,6.8 0 1,0 13.6,0 a6.8,6.8 0 1,0 -13.6,0" }
          }
          ShapePath {
            strokeColor: root.strokeColor
            strokeWidth: 1.2
            fillColor: Qt.alpha(root.strokeColor, 0.25)
            PathSvg { path: "M30,5 L26,0 L33,4 Z M34,4 L39,0 L40,6 Z" }
          }
          ShapePath {
            strokeColor: root.strokeColor
            strokeWidth: 1.8
            capStyle: ShapePath.RoundCap
            fillColor: "transparent"
            PathSvg { path: "M16,24 C10,21 8,13 11,8 C13,4 17,5 16,9 C15,13 13,19 18,24" }
          }
          ShapePath {
            strokeColor: "transparent"
            fillColor: root.yellowColor
            PathSvg { path: "M32,16 m-1.3,0 a1.3,1.3 0 1,0 2.6,0 a1.3,1.3 0 1,0 -2.6,0" }
          }
          ShapePath {
            strokeColor: root.whiteColor
            fillColor: root.whiteColor
            PathSvg { path: "M35.5,10 m-1.4,0 a1.4,1.4 0 1,0 2.8,0 a1.4,1.4 0 1,0 -2.8,0" }
          }
          ShapePath {
            strokeColor: root.darkColor
            fillColor: root.darkColor
            PathSvg { path: "M36,9.6 m-0.6,0 a0.6,0.6 0 1,0 1.2,0 a0.6,0.6 0 1,0 -1.2,0" }
          }
        }

        // Cat Active Run & Music Body
        Shape {
          anchors.fill: parent
          visible: root.state === "run" || root.state === "music" || root.state === "happy"
          layer.enabled: true
          layer.samples: 4

          ShapePath {
            strokeColor: root.strokeColor
            strokeWidth: 1.7
            joinStyle: ShapePath.RoundJoin
            fillColor: root.fillColor
            PathSvg { path: "M14,16 C14,11 18,9 25,9 C30,9 33,11 36,13 L38,8 L42,12 L45,8 L45,14 C47,15 47,18 45,20 C42,22 38,20 35,19 C31,21 24,22 17,21 C14,21 14,18 14,16 Z" }
          }
          ShapePath {
            strokeColor: "transparent"
            fillColor: root.yellowColor
            PathSvg { path: "M36,19.5 m-1.3,0 a1.3,1.3 0 1,0 2.6,0 a1.3,1.3 0 1,0 -2.6,0" }
          }
          ShapePath {
            strokeColor: root.whiteColor
            fillColor: root.whiteColor
            PathSvg { path: "M42.5,15 m-1.2,0 a1.2,1.2 0 1,0 2.4,0 a1.2,1.2 0 1,0 -2.4,0" }
          }
          ShapePath {
            strokeColor: root.darkColor
            fillColor: root.darkColor
            PathSvg { path: "M42.8,14.7 m-0.5,0 a0.5,0.5 0 1,0 1,0 a0.5,0.5 0 1,0 -1,0" }
          }
        }

        // Animated Tail
        Item {
          id: catTail
          x: 13
          y: 16
          transformOrigin: Item.TopLeft
          visible: root.state === "run" || root.state === "music" || root.state === "happy"

          SequentialAnimation on rotation {
            running: root.animal === "cat" && (root.state === "run" || root.state === "music" || root.state === "happy")
            loops: Animation.Infinite
            NumberAnimation { to: 16; duration: root.state === "music" ? 350 : 250; easing.type: Easing.InOutSine }
            NumberAnimation { to: -10; duration: root.state === "music" ? 350 : 250; easing.type: Easing.InOutSine }
          }

          Shape {
            x: -13; y: -16
            width: 50; height: 32
            ShapePath {
              strokeColor: root.strokeColor
              strokeWidth: 1.8
              capStyle: ShapePath.RoundCap
              fillColor: "transparent"
              PathSvg { path: "M12,16 C8,12 6,6 10,3 C12,1 15,3 13,7 C12,10 12,13 14,16" }
            }
          }
        }

        // Running Legs
        Item {
          visible: root.state === "run" || root.state === "music" || root.state === "happy"
          anchors.fill: parent

          // Leg 1 (Back Left)
          Item {
            x: 18; y: 21
            transformOrigin: Item.Top
            SequentialAnimation on rotation {
            running: root.animal === "cat" && (root.state === "run" || root.state === "happy")
            loops: Animation.Infinite
            NumberAnimation { to: -20; duration: 250; easing.type: Easing.InOutSine }
            NumberAnimation { to: 20; duration: 250; easing.type: Easing.InOutSine }
          }
            Shape {
              x: -18; y: -21; width: 50; height: 32
              ShapePath { strokeColor: root.strokeColor; strokeWidth: 1.8; capStyle: ShapePath.RoundCap; PathSvg { path: "M18,21 L16,28" } }
            }
          }
          // Leg 2 (Back Right)
          Item {
            x: 22; y: 21
            transformOrigin: Item.Top
            SequentialAnimation on rotation {
            running: root.animal === "cat" && (root.state === "run" || root.state === "happy")
            loops: Animation.Infinite
            NumberAnimation { to: 20; duration: 250; easing.type: Easing.InOutSine }
            NumberAnimation { to: -20; duration: 250; easing.type: Easing.InOutSine }
          }
            Shape {
              x: -22; y: -21; width: 50; height: 32
              ShapePath { strokeColor: root.strokeColor; strokeWidth: 1.8; capStyle: ShapePath.RoundCap; PathSvg { path: "M22,21 L24,28" } }
            }
          }
          // Leg 3 (Front Left)
          Item {
            x: 32; y: 20
            transformOrigin: Item.Top
            SequentialAnimation on rotation {
            running: root.animal === "cat" && (root.state === "run" || root.state === "happy")
            loops: Animation.Infinite
            NumberAnimation { to: -20; duration: 250; easing.type: Easing.InOutSine }
            NumberAnimation { to: 20; duration: 250; easing.type: Easing.InOutSine }
          }
            Shape {
              x: -32; y: -20; width: 50; height: 32
              ShapePath { strokeColor: root.strokeColor; strokeWidth: 1.8; capStyle: ShapePath.RoundCap; PathSvg { path: "M32,20 L30,28" } }
            }
          }
          // Leg 4 (Front Right)
          Item {
            x: 36; y: 19
            transformOrigin: Item.Top
            SequentialAnimation on rotation {
            running: root.animal === "cat" && (root.state === "run" || root.state === "happy")
            loops: Animation.Infinite
            NumberAnimation { to: 20; duration: 250; easing.type: Easing.InOutSine }
            NumberAnimation { to: -20; duration: 250; easing.type: Easing.InOutSine }
          }
            Shape {
              x: -36; y: -19; width: 50; height: 32
              ShapePath { strokeColor: root.strokeColor; strokeWidth: 1.8; capStyle: ShapePath.RoundCap; PathSvg { path: "M36,19 L38,28" } }
            }
          }
        }
      }
    }

    // =========================================================================
    // 2. CAPYBARA (REFINED CONTINUOUS SILHOUETTE + YUZU ORANGE)
    // =========================================================================
    Item {
      id: capyContainer
      anchors.fill: parent
      visible: root.animal === "capy"

      Item {
        id: capyBobber
        anchors.fill: parent

        SequentialAnimation on y {
          running: root.animal === "capy" && (root.state === "run" || root.state === "music")
          loops: Animation.Infinite
          NumberAnimation { to: -1.0; duration: root.state === "music" ? 380 : 320; easing.type: Easing.InOutSine }
          NumberAnimation { to: 0.0; duration: root.state === "music" ? 380 : 320; easing.type: Easing.InOutSine }
        }

        // Yuzu Orange Perched on Head
        Item {
          id: capyYuzu
          x: 34; y: root.state === "sleep" ? 8 : (root.state === "type" ? 6 : 5.5)
          visible: true

          SequentialAnimation on rotation {
            running: root.animal === "capy" && (root.state === "run" || root.state === "music")
            loops: Animation.Infinite
            NumberAnimation { to: 8; duration: 380; easing.type: Easing.InOutSine }
            NumberAnimation { to: -6; duration: 380; easing.type: Easing.InOutSine }
          }

          Shape {
            x: -34; y: -(root.state === "sleep" ? 8 : (root.state === "type" ? 6 : 5.5))
            width: 50; height: 32
            layer.enabled: true
            layer.samples: 4

            ShapePath {
              strokeColor: root.orangeColor
              strokeWidth: 0.8
              fillColor: root.orangeColor
              PathSvg { path: "M34," + capyYuzu.y + " m-3.4,0 a3.4,3.4 0 1,0 6.8,0 a3.4,3.4 0 1,0 -6.8,0" }
            }
            ShapePath {
              strokeColor: "transparent"
              fillColor: root.greenColor
              PathSvg { path: "M34," + (capyYuzu.y - 3) + " C35.5," + (capyYuzu.y - 4.8) + " 38," + (capyYuzu.y - 3.8) + " 37," + (capyYuzu.y - 2) + " Z" }
            }
            ShapePath {
              strokeColor: "transparent"
              fillColor: Qt.alpha(root.whiteColor, 0.6)
              PathSvg { path: "M34.8," + (capyYuzu.y - 1) + " m-0.6,0 a0.6,0.6 0 1,0 1.2,0 a0.6,0.6 0 1,0 -1.2,0" }
            }
          }
        }

        // Capybara Continuous Body & Distinctive Blunt Snout
        Shape {
          anchors.fill: parent
          visible: root.state === "run" || root.state === "music" || root.state === "sit" || root.state === "happy"
          layer.enabled: true
          layer.samples: 4

          ShapePath {
            strokeColor: root.strokeColor
            strokeWidth: 1.8
            joinStyle: ShapePath.RoundJoin
            fillColor: root.fillColor
            PathSvg {
              path: "M12,25 C9,20 12,13 20,12 C24,12 27,11.5 30,10.5 L40,10.5 C43.5,10.5 45.5,12 46,15 L46,18.5 C46,21.5 43.5,22.5 39,22.5 L33,22.5 C31.5,24 30.5,25.5 28,26.5 L15,26.5 C12.5,26.5 12,25.5 12,25 Z"
            }
          }
          // Small Ear
          ShapePath {
            strokeColor: root.strokeColor
            strokeWidth: 1.4
            capStyle: ShapePath.RoundCap
            fillColor: root.strokeColor
            PathSvg { path: "M28.5,11 C28,8 31,8 31.5,10.5" }
          }
          // Nostril at upper-front tip of blunt snout
          ShapePath {
            strokeColor: root.strokeColor
            fillColor: root.strokeColor
            PathSvg { path: "M43.5,14.5 m-0.8,0 a0.8,0.8 0 1,0 1.6,0 a0.8,0.8 0 1,0 -1.6,0" }
          }
          // Eyes (Sleepy horizontal slit when run/sit, curved happy when music)
          ShapePath {
            strokeColor: root.whiteColor
            strokeWidth: 1.5
            capStyle: ShapePath.RoundCap
            fillColor: "transparent"
            PathSvg {
              path: root.state === "music" ? "M35,14.5 Q37,12.5 39,14.5" : "M34.5,14 L39,14"
            }
          }
        }

        // Capybara Sleeping Pose
        Shape {
          anchors.fill: parent
          visible: root.state === "sleep"
          layer.enabled: true
          layer.samples: 4

          ShapePath {
            strokeColor: root.strokeColor
            strokeWidth: 1.8
            fillColor: root.fillColor
            PathSvg { path: "M25,20 m-16,0 a16,8 0 1,0 32,0 a16,8 0 1,0 -32,0" }
          }
          ShapePath {
            strokeColor: root.strokeColor
            strokeWidth: 1.8
            fillColor: root.fillColor
            PathSvg { path: "M26,14 L38,14 C41,14 45,15 47,18 C48,21 46,23 43,23 L36,23 Z" }
          }
          ShapePath {
            strokeColor: root.strokeColor
            fillColor: root.strokeColor
            PathSvg { path: "M45,18.5 m-0.7,0 a0.7,0.7 0 1,0 1.4,0 a0.7,0.7 0 1,0 -1.4,0" }
          }
          ShapePath {
            strokeColor: root.strokeColor
            fillColor: root.strokeColor
            PathSvg { path: "M30,14 m-1.4,0 a1.4,1.4 0 1,0 2.8,0 a1.4,1.4 0 1,0 -2.8,0" }
          }
          ShapePath {
            strokeColor: root.whiteColor
            strokeWidth: 1.4
            capStyle: ShapePath.RoundCap
            fillColor: "transparent"
            PathSvg { path: "M38,18 L42,18" }
          }
        }

        // Capybara Typing Pose
        Shape {
          anchors.fill: parent
          visible: root.state === "type"
          layer.enabled: true
          layer.samples: 4

          ShapePath {
            strokeColor: root.strokeColor
            strokeWidth: 1.8
            fillColor: root.fillColor
            PathSvg { path: "M15,26 C12,18 16,13 24,12 C28,12 31,11 34,11 L41,11 C44,11 46,12.5 46,15.5 L46,19 C46,22 43,23 39,23 L33,23 C31,25 28,26.5 24,26.5 Z" }
          }
          ShapePath {
            strokeColor: root.strokeColor
            strokeWidth: 1.4
            fillColor: root.strokeColor
            PathSvg { path: "M29,11 C28.5,8.5 31,8.5 31.5,11" }
          }
          ShapePath {
            strokeColor: root.whiteColor
            strokeWidth: 1.5
            capStyle: ShapePath.RoundCap
            fillColor: "transparent"
            PathSvg { path: "M35,14 L39,14" }
          }
          ShapePath {
            strokeColor: root.strokeColor
            fillColor: root.strokeColor
            PathSvg { path: "M43.5,14.5 m-0.8,0 a0.8,0.8 0 1,0 1.6,0 a0.8,0.8 0 1,0 -1.6,0" }
          }
        }

        // Sturdy Pillar Legs for Capybara
        Item {
          visible: root.state === "run" || root.state === "music" || root.state === "happy"
          anchors.fill: parent

          Item {
            x: 16; y: 26
            transformOrigin: Item.Top
            SequentialAnimation on rotation {
            running: root.animal === "capy" && (root.state === "run" || root.state === "happy")
            loops: Animation.Infinite
            NumberAnimation { to: -14; duration: 320; easing.type: Easing.InOutSine }
            NumberAnimation { to: 14; duration: 320; easing.type: Easing.InOutSine }
          }
            Shape { x: -16; y: -26; width: 50; height: 32; ShapePath { strokeColor: root.strokeColor; strokeWidth: 2.2; capStyle: ShapePath.RoundCap; PathSvg { path: "M16,26 L14,33" } } }
          }
          Item {
            x: 21; y: 26
            transformOrigin: Item.Top
            SequentialAnimation on rotation {
            running: root.animal === "capy" && (root.state === "run" || root.state === "happy")
            loops: Animation.Infinite
            NumberAnimation { to: 14; duration: 320; easing.type: Easing.InOutSine }
            NumberAnimation { to: -14; duration: 320; easing.type: Easing.InOutSine }
          }
            Shape { x: -21; y: -26; width: 50; height: 32; ShapePath { strokeColor: root.strokeColor; strokeWidth: 2.2; capStyle: ShapePath.RoundCap; PathSvg { path: "M21,26 L23,33" } } }
          }
          Item {
            x: 28; y: 26
            transformOrigin: Item.Top
            SequentialAnimation on rotation {
            running: root.animal === "capy" && (root.state === "run" || root.state === "happy")
            loops: Animation.Infinite
            NumberAnimation { to: -14; duration: 320; easing.type: Easing.InOutSine }
            NumberAnimation { to: 14; duration: 320; easing.type: Easing.InOutSine }
          }
            Shape { x: -28; y: -26; width: 50; height: 32; ShapePath { strokeColor: root.strokeColor; strokeWidth: 2.2; capStyle: ShapePath.RoundCap; PathSvg { path: "M28,26 L26,33" } } }
          }
          Item {
            x: 33; y: 25
            transformOrigin: Item.Top
            SequentialAnimation on rotation {
            running: root.animal === "capy" && (root.state === "run" || root.state === "happy")
            loops: Animation.Infinite
            NumberAnimation { to: 14; duration: 320; easing.type: Easing.InOutSine }
            NumberAnimation { to: -14; duration: 320; easing.type: Easing.InOutSine }
          }
            Shape { x: -33; y: -25; width: 50; height: 32; ShapePath { strokeColor: root.strokeColor; strokeWidth: 2.2; capStyle: ShapePath.RoundCap; PathSvg { path: "M33,25 L35,33" } } }
          }
        }
      }
    }

    // =========================================================================
    // 3. ANJING (SHIBA INU)
    // =========================================================================
    Item {
      id: dogContainer
      anchors.fill: parent
      visible: root.animal === "dog"

      Item {
        id: dogBobber
        anchors.fill: parent

        SequentialAnimation on y {
          running: root.animal === "dog" && (root.state === "run" || root.state === "music")
          loops: Animation.Infinite
          NumberAnimation { to: -2.0; duration: root.state === "music" ? 340 : 200; easing.type: Easing.InOutSine }
          NumberAnimation { to: 0.0; duration: root.state === "music" ? 340 : 200; easing.type: Easing.InOutSine }
        }

        // Curled Sickle / Donut Tail
        Item {
          id: dogTail
          x: 14; y: 16
          transformOrigin: Item.BottomRight
          visible: root.state === "run" || root.state === "music" || root.state === "sit" || root.state === "happy"

          SequentialAnimation on rotation {
            running: root.animal === "dog" && (root.state === "run" || root.state === "music" || root.state === "happy")
            loops: Animation.Infinite
            NumberAnimation { to: 20; duration: 200; easing.type: Easing.InOutSine }
            NumberAnimation { to: -16; duration: 200; easing.type: Easing.InOutSine }
          }

          Shape {
            x: -14; y: -16; width: 50; height: 32
            ShapePath {
              strokeColor: root.strokeColor
              strokeWidth: 2.0
              capStyle: ShapePath.RoundCap
              fillColor: "transparent"
              PathSvg { path: "M14,16 C12,13 11,8 14,6 C17,4 20,7 18,10 C16,12 14,14 15,16" }
            }
          }
        }

        // Dog Running / Music Body & Bandana
        Shape {
          anchors.fill: parent
          visible: root.state === "run" || root.state === "music" || root.state === "happy"
          layer.enabled: true
          layer.samples: 4

          ShapePath {
            strokeColor: root.strokeColor
            strokeWidth: 1.7
            joinStyle: ShapePath.RoundJoin
            fillColor: root.fillColor
            PathSvg { path: "M15,16 C15,11 19,9 26,9 C30,9 33,10 36,12 L38,7 L41,11 L43,9 L44,13 C47,14 48,16 46,18 C44,20 40,20 37,19 C34,21 26,22 18,21 C15,21 15,18 15,16 Z" }
          }
          // Button Nose
          ShapePath {
            strokeColor: root.strokeColor
            fillColor: root.strokeColor
            PathSvg { path: "M46,15.5 m-1.1,0 a1.1,1.1 0 1,0 2.2,0 a1.1,1.1 0 1,0 -2.2,0" }
          }
          // Eye
          ShapePath {
            strokeColor: root.whiteColor
            fillColor: root.whiteColor
            PathSvg { path: "M41,13.5 m-1.2,0 a1.2,1.2 0 1,0 2.4,0 a1.2,1.2 0 1,0 -2.4,0" }
          }
          // Pink Bandana Collar
          ShapePath {
            strokeColor: root.pinkColor
            strokeWidth: 2.0
            capStyle: ShapePath.RoundCap
            PathSvg { path: "M35,17 L39,17" }
          }
        }

        // Dog Seated Pose
        Shape {
          anchors.fill: parent
          visible: root.state === "sit" || root.state === "type"
          layer.enabled: true
          layer.samples: 4

          ShapePath {
            strokeColor: root.strokeColor
            strokeWidth: 1.7
            fillColor: root.fillColor
            PathSvg { path: "M16,24 C14,18 17,11 25,10 C32,10 36,14 37,20 C37,24 31,25 23,25 Z" }
          }
          ShapePath {
            strokeColor: root.strokeColor
            strokeWidth: 1.6
            fillColor: root.fillColor
            PathSvg { path: "M35,10 m-6.5,0 a6.5,6.5 0 1,0 13,0 a6.5,6.5 0 1,0 -13,0" }
          }
          ShapePath {
            strokeColor: root.strokeColor
            strokeWidth: 1.2
            fillColor: Qt.alpha(root.strokeColor, 0.25)
            PathSvg { path: "M31,5 L29,0 L34,4 Z M35,4 L39,0 L40,6 Z" }
          }
          ShapePath {
            strokeColor: root.whiteColor
            fillColor: root.whiteColor
            PathSvg { path: "M36,9.5 m-1.2,0 a1.2,1.2 0 1,0 2.4,0 a1.2,1.2 0 1,0 -2.4,0" }
          }
          ShapePath {
            strokeColor: root.pinkColor
            strokeWidth: 2.0
            capStyle: ShapePath.RoundCap
            PathSvg { path: "M33,16 L37,16" }
          }
        }

        // Dog Sleeping Pose
        Shape {
          anchors.fill: parent
          visible: root.state === "sleep"
          layer.enabled: true
          layer.samples: 4

          ShapePath {
            strokeColor: root.strokeColor
            strokeWidth: 1.7
            fillColor: root.fillColor
            PathSvg { path: "M25,18 m-14,0 a14,8.5 0 1,0 28,0 a14,8.5 0 1,0 -28,0" }
          }
          ShapePath {
            strokeColor: root.strokeColor
            strokeWidth: 2.0
            fillColor: "transparent"
            PathSvg { path: "M15,14 m-3.5,0 a3.5,3.5 0 1,0 7,0 a3.5,3.5 0 1,0 -7,0" }
          }
          ShapePath {
            strokeColor: root.strokeColor
            strokeWidth: 1.5
            fillColor: Qt.alpha(root.strokeColor, 0.2)
            PathSvg { path: "M35,17 m-6,0 a6,6 0 1,0 12,0 a6,6 0 1,0 -12,0" }
          }
          ShapePath {
            strokeColor: root.strokeColor
            strokeWidth: 1.2
            fillColor: Qt.alpha(root.strokeColor, 0.25)
            PathSvg { path: "M32,12 L30,7 L35,11 Z M36,11 L39,7 L41,12 Z" }
          }
          ShapePath {
            strokeColor: root.whiteColor
            strokeWidth: 1.4
            capStyle: ShapePath.RoundCap
            fillColor: "transparent"
            PathSvg { path: "M34,17 L37,17" }
          }
        }

        // Dog Trotting Legs
        Item {
          visible: root.state === "run" || root.state === "music" || root.state === "happy"
          anchors.fill: parent

          Item {
            x: 19; y: 21; transformOrigin: Item.Top
            SequentialAnimation on rotation {
              running: root.animal === "dog" && (root.state === "run" || root.state === "happy")
              loops: Animation.Infinite
              NumberAnimation { to: -24; duration: 200; easing.type: Easing.InOutSine }
              NumberAnimation { to: 24; duration: 200; easing.type: Easing.InOutSine }
            }
            Shape { x: -19; y: -21; width: 50; height: 32; ShapePath { strokeColor: root.strokeColor; strokeWidth: 2.0; capStyle: ShapePath.RoundCap; PathSvg { path: "M19,21 L16,28" } } }
          }
          Item {
            x: 24; y: 21; transformOrigin: Item.Top
            SequentialAnimation on rotation {
              running: root.animal === "dog" && (root.state === "run" || root.state === "happy")
              loops: Animation.Infinite
              NumberAnimation { to: 24; duration: 200; easing.type: Easing.InOutSine }
              NumberAnimation { to: -24; duration: 200; easing.type: Easing.InOutSine }
            }
            Shape { x: -24; y: -21; width: 50; height: 32; ShapePath { strokeColor: root.strokeColor; strokeWidth: 2.0; capStyle: ShapePath.RoundCap; PathSvg { path: "M24,21 L27,28" } } }
          }
          Item {
            x: 32; y: 20; transformOrigin: Item.Top
            SequentialAnimation on rotation {
              running: root.animal === "dog" && (root.state === "run" || root.state === "happy")
              loops: Animation.Infinite
              NumberAnimation { to: -24; duration: 200; easing.type: Easing.InOutSine }
              NumberAnimation { to: 24; duration: 200; easing.type: Easing.InOutSine }
            }
            Shape { x: -32; y: -20; width: 50; height: 32; ShapePath { strokeColor: root.strokeColor; strokeWidth: 2.0; capStyle: ShapePath.RoundCap; PathSvg { path: "M32,20 L29,28" } } }
          }
          Item {
            x: 37; y: 19; transformOrigin: Item.Top
            SequentialAnimation on rotation {
              running: root.animal === "dog" && (root.state === "run" || root.state === "happy")
              loops: Animation.Infinite
              NumberAnimation { to: 24; duration: 200; easing.type: Easing.InOutSine }
              NumberAnimation { to: -24; duration: 200; easing.type: Easing.InOutSine }
            }
            Shape { x: -37; y: -19; width: 50; height: 32; ShapePath { strokeColor: root.strokeColor; strokeWidth: 2.0; capStyle: ShapePath.RoundCap; PathSvg { path: "M37,19 L40,28" } } }
          }
        }
      }
    }

    // =========================================================================
    // 4. KELINCI (BUNNY)
    // =========================================================================
    Item {
      id: bunnyContainer
      anchors.fill: parent
      visible: root.animal === "bunny"

      Item {
        id: bunnyBobber
        anchors.fill: parent

        SequentialAnimation on y {
          running: root.animal === "bunny" && (root.state === "run" || root.state === "music")
          loops: Animation.Infinite
          NumberAnimation { to: -3.0; duration: 240; easing.type: Easing.OutQuad }
          NumberAnimation { to: 0.0; duration: 280; easing.type: Easing.InQuad }
        }

        // Fluffy Round Puff Tail
        Shape {
          anchors.fill: parent
          visible: root.state !== "sleep"
          ShapePath {
            strokeColor: root.strokeColor
            fillColor: root.strokeColor
            PathSvg { path: "M12,17 m-2.4,0 a2.4,2.4 0 1,0 4.8,0 a2.4,2.4 0 1,0 -4.8,0" }
          }
        }

        // Bunny Hopping / Music Body
        Shape {
          anchors.fill: parent
          visible: root.state === "run" || root.state === "music" || root.state === "happy"
          layer.enabled: true
          layer.samples: 4

          ShapePath {
            strokeColor: root.strokeColor
            strokeWidth: 1.7
            joinStyle: ShapePath.RoundJoin
            fillColor: root.fillColor
            PathSvg { path: "M13,18 C13,12 17,9 24,9 C28,9 31,11 34,13 C36,13 38,13 40,15 C42,17 41,20 38,21 C34,22 28,23 20,22 C14,22 13,20 13,18 Z" }
          }
          // Bunny Eye & Nose
          ShapePath {
            strokeColor: root.whiteColor
            fillColor: root.whiteColor
            PathSvg { path: "M38.5,16 m-1.2,0 a1.2,1.2 0 1,0 2.4,0 a1.2,1.2 0 1,0 -2.4,0" }
          }
          ShapePath {
            strokeColor: root.pinkColor
            fillColor: root.pinkColor
            PathSvg { path: "M41.5,17.5 m-0.8,0 a0.8,0.8 0 1,0 1.6,0 a0.8,0.8 0 1,0 -1.6,0" }
          }
          // Hopping Feet
          ShapePath {
            strokeColor: root.strokeColor
            strokeWidth: 1.8
            capStyle: ShapePath.RoundCap
            fillColor: "transparent"
            PathSvg { path: "M35,21 L36,27 M18,18 C16,21 16,24 18,27 L23,27" }
          }
        }

        // Tall Upright Bunny Ears with Sway
        Item {
          id: bunnyEars
          x: 35; y: 13
          transformOrigin: Item.BottomLeft
          visible: root.state === "run" || root.state === "music" || root.state === "happy"

          SequentialAnimation on rotation {
            running: root.animal === "bunny" && (root.state === "run" || root.state === "music" || root.state === "happy")
            loops: Animation.Infinite
            NumberAnimation { to: 14; duration: 280; easing.type: Easing.InOutSine }
            NumberAnimation { to: -8; duration: 280; easing.type: Easing.InOutSine }
          }

          Shape {
            x: -35; y: -13; width: 50; height: 32
            ShapePath {
              strokeColor: root.strokeColor
              strokeWidth: 1.4
              fillColor: Qt.alpha(root.strokeColor, 0.25)
              PathSvg { path: "M34,13 C32,7 32,2 35,2 C37,2 37,7 35,13 Z M37,13 C37,6 38,1 41,1 C43,1 43,6 39,13 Z" }
            }
          }
        }

        // Bunny Seated Pose
        Shape {
          anchors.fill: parent
          visible: root.state === "sit" || root.state === "type"
          layer.enabled: true
          layer.samples: 4

          ShapePath {
            strokeColor: root.strokeColor
            strokeWidth: 1.7
            fillColor: root.fillColor
            PathSvg { path: "M16,25 C14,19 17,13 25,12 C31,12 35,15 36,21 C36,25 31,26 22,26 Z" }
          }
          ShapePath {
            strokeColor: root.strokeColor
            strokeWidth: 1.5
            fillColor: root.fillColor
            PathSvg { path: "M33,12 m-6.2,0 a6.2,6.2 0 1,0 12.4,0 a6.2,6.2 0 1,0 -12.4,0" }
          }
          ShapePath {
            strokeColor: root.strokeColor
            strokeWidth: 1.3
            fillColor: Qt.alpha(root.strokeColor, 0.25)
            PathSvg { path: "M32,7 C30,2 30,-3 33,-3 C35,-3 35,2 33,7 Z M35,7 C35,1 36,-4 39,-4 C41,-4 41,1 37,7 Z" }
          }
          ShapePath {
            strokeColor: root.whiteColor
            fillColor: root.whiteColor
            PathSvg { path: "M34.5,12 m-1.2,0 a1.2,1.2 0 1,0 2.4,0 a1.2,1.2 0 1,0 -2.4,0" }
          }
          ShapePath {
            strokeColor: root.pinkColor
            fillColor: root.pinkColor
            PathSvg { path: "M37.5,13.5 m-0.8,0 a0.8,0.8 0 1,0 1.6,0 a0.8,0.8 0 1,0 -1.6,0" }
          }
        }

        // Bunny Sleeping Pose
        Shape {
          anchors.fill: parent
          visible: root.state === "sleep"
          layer.enabled: true
          layer.samples: 4

          ShapePath {
            strokeColor: root.strokeColor
            strokeWidth: 1.7
            fillColor: root.fillColor
            PathSvg { path: "M24,19 m-13,0 a13,8 0 1,0 26,0 a13,8 0 1,0 -26,0" }
          }
          ShapePath {
            strokeColor: root.strokeColor
            fillColor: root.strokeColor
            PathSvg { path: "M12,18 m-2.4,0 a2.4,2.4 0 1,0 4.8,0 a2.4,2.4 0 1,0 -4.8,0" }
          }
          ShapePath {
            strokeColor: root.strokeColor
            strokeWidth: 1.4
            fillColor: Qt.alpha(root.strokeColor, 0.2)
            PathSvg { path: "M34,16 m-5.5,0 a5.5,5.5 0 1,0 11,0 a5.5,5.5 0 1,0 -11,0" }
          }
          // Ears Folded along Back
          ShapePath {
            strokeColor: root.strokeColor
            strokeWidth: 1.6
            capStyle: ShapePath.RoundCap
            fillColor: "transparent"
            PathSvg { path: "M32,12 C28,10 20,10 16,11 M33,13 C29,11 22,11 18,12" }
          }
          ShapePath {
            strokeColor: root.whiteColor
            strokeWidth: 1.4
            capStyle: ShapePath.RoundCap
            fillColor: "transparent"
            PathSvg { path: "M34,16 L37,16" }
          }
        }
      }
    }

    // =========================================================================
    // 5. GLOBAL ACCESSORIES & OVERLAYS (HEADPHONES, LAPTOP, PARTICLES)
    // =========================================================================

    // A. MINI GLOWING HEADPHONES (Active in "music" state)
    Shape {
      anchors.fill: parent
      visible: root.state === "music"
      layer.enabled: true
      layer.samples: 4

      // Arching Headband
      ShapePath {
        strokeColor: root.strokeColor
        strokeWidth: 1.8
        capStyle: ShapePath.RoundCap
        fillColor: "transparent"
        PathSvg {
          path: root.animal === "capy"
            ? "M29,11 C29,5 36,5 36,11"
            : (root.animal === "bunny"
                ? "M33,12 C33,6 40,6 40,12"
                : (root.animal === "dog"
                    ? "M36,9 C36,4 43,4 43,9"
                    : "M37,11 C37,5 45,5 45,11"))
        }
      }
      // Earcups (Pink Glow)
      ShapePath {
        strokeColor: root.strokeColor
        strokeWidth: 0.8
        fillColor: root.pinkColor
        PathSvg {
          path: root.animal === "capy"
            ? "M29,11.5 m-2.4,0 a2.4,2.4 0 1,0 4.8,0 a2.4,2.4 0 1,0 -4.8,0 M36,11.5 m-2.4,0 a2.4,2.4 0 1,0 4.8,0 a2.4,2.4 0 1,0 -4.8,0"
            : (root.animal === "bunny"
                ? "M33,13 m-2.2,0 a2.2,2.2 0 1,0 4.4,0 a2.2,2.2 0 1,0 -4.4,0 M40,13 m-2.2,0 a2.2,2.2 0 1,0 4.4,0 a2.2,2.2 0 1,0 -4.4,0"
                : (root.animal === "dog"
                    ? "M36,10 m-2.2,0 a2.2,2.2 0 1,0 4.4,0 a2.2,2.2 0 1,0 -4.4,0 M43,10 m-2.2,0 a2.2,2.2 0 1,0 4.4,0 a2.2,2.2 0 1,0 -4.4,0"
                    : "M37,11 m-2.4,0 a2.4,2.4 0 1,0 4.8,0 a2.4,2.4 0 1,0 -4.8,0 M45,11 m-2.4,0 a2.4,2.4 0 1,0 4.8,0 a2.4,2.4 0 1,0 -4.8,0"))
        }
      }
    }

    // B. FLOATING MUSICAL NOTES (Active in "music" state)
    Item {
      anchors.fill: parent
      visible: root.state === "music"

      Text {
        id: note1
        text: "♫"
        font.pixelSize: 9
        font.bold: true
        color: root.strokeColor
        x: 43
        y: 8

        SequentialAnimation on y {
          loops: Animation.Infinite
          running: root.state === "music"
          NumberAnimation { from: 10; to: 1; duration: 900; easing.type: Easing.OutCubic }
        }
        SequentialAnimation on opacity {
          loops: Animation.Infinite
          running: root.state === "music"
          NumberAnimation { from: 0; to: 1; duration: 250 }
          PauseAnimation { duration: 350 }
          NumberAnimation { from: 1; to: 0; duration: 300 }
        }
      }

      Text {
        id: note2
        text: "♪"
        font.pixelSize: 7
        font.bold: true
        color: root.pinkColor
        x: 47
        y: 4

        SequentialAnimation on y {
          loops: Animation.Infinite
          running: root.state === "music"
          PauseAnimation { duration: 350 }
          NumberAnimation { from: 8; to: -2; duration: 900; easing.type: Easing.OutCubic }
        }
        SequentialAnimation on opacity {
          loops: Animation.Infinite
          running: root.state === "music"
          PauseAnimation { duration: 350 }
          NumberAnimation { from: 0; to: 1; duration: 250 }
          PauseAnimation { duration: 350 }
          NumberAnimation { from: 1; to: 0; duration: 300 }
        }
      }
    }

    // C. MINI LAPTOP & TAPPING PAWS (Active in "type" state)
    Item {
      anchors.fill: parent
      visible: root.state === "type"

      // Mini Glowing Laptop
      Shape {
        anchors.fill: parent
        layer.enabled: true
        layer.samples: 4

        ShapePath {
          strokeColor: root.strokeColor
          strokeWidth: 0.8
          fillColor: "#313244"
          PathSvg { path: "M43,20 L49,20 L49,21.5 L43,21.5 Z" }
        }
        ShapePath {
          strokeColor: root.strokeColor
          strokeWidth: 0.8
          fillColor: "#181825"
          PathSvg { path: "M45,20 L47,13 L51,13 L49,20 Z" }
        }
        ShapePath {
          strokeColor: "transparent"
          fillColor: Qt.alpha(root.strokeColor, 0.85)
          PathSvg { path: "M45.5,19 L47.2,14 L50.2,14 L48.5,19 Z" }
        }
      }

      // Fast Tapping Paws
      Item {
        id: typingPaws
        anchors.fill: parent

        Item {
          id: pawLeft
          x: 40; y: 18
          SequentialAnimation on y {
            loops: Animation.Infinite
            running: root.state === "type"
            NumberAnimation { from: 18; to: 16.5; duration: 110; easing.type: Easing.InOutSine }
            NumberAnimation { from: 16.5; to: 18; duration: 110; easing.type: Easing.InOutSine }
          }
          Rectangle {
            width: 3.2; height: 3.2; radius: 1.6
            color: root.whiteColor
            border.color: root.strokeColor; border.width: 0.7
          }
        }

        Item {
          id: pawRight
          x: 43; y: 19
          SequentialAnimation on y {
            loops: Animation.Infinite
            running: root.state === "type"
            NumberAnimation { from: 17.5; to: 19; duration: 110; easing.type: Easing.InOutSine }
            NumberAnimation { from: 19; to: 17.5; duration: 110; easing.type: Easing.InOutSine }
          }
          Rectangle {
            width: 3.2; height: 3.2; radius: 1.6
            color: root.whiteColor
            border.color: root.strokeColor; border.width: 0.7
          }
        }
      }
    }

    // D. SLEEPING BREATH & "z Z" PARTICLES (Active in "sleep" state)
    Item {
      anchors.fill: parent
      visible: root.state === "sleep"

      Text {
        text: "z"
        font.pixelSize: 8
        font.bold: true
        font.family: "monospace"
        color: root.strokeColor
        x: 41; y: 10

        SequentialAnimation on y {
          loops: Animation.Infinite
          running: root.state === "sleep"
          NumberAnimation { from: 10; to: 1; duration: 1600; easing.type: Easing.OutSine }
        }
        SequentialAnimation on opacity {
          loops: Animation.Infinite
          running: root.state === "sleep"
          NumberAnimation { from: 0; to: 1; duration: 300 }
          PauseAnimation { duration: 700 }
          NumberAnimation { from: 1; to: 0; duration: 600 }
        }
      }

      Text {
        text: "Z"
        font.pixelSize: 11
        font.bold: true
        font.family: "monospace"
        color: root.strokeColor
        x: 46; y: 4

        SequentialAnimation on y {
          loops: Animation.Infinite
          running: root.state === "sleep"
          PauseAnimation { duration: 600 }
          NumberAnimation { from: 7; to: -4; duration: 1600; easing.type: Easing.OutSine }
        }
        SequentialAnimation on opacity {
          loops: Animation.Infinite
          running: root.state === "sleep"
          PauseAnimation { duration: 600 }
          NumberAnimation { from: 0; to: 1; duration: 300 }
          PauseAnimation { duration: 700 }
          NumberAnimation { from: 1; to: 0; duration: 600 }
        }
      }
    }

  }
}
