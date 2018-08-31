import os, math
import vmath
import sound

block:
  echo "playing wav file"
  let sound = newSoundWithFile("tests/ding.wav")
  discard sound.play()
  sleep(1000)

block:
  echo "playing ogg file"
  let sound = newSoundWithFile("tests/robo.ogg")
  discard sound.play()
  sleep(1000)

block:
  # playing sound in 3d
  let sound = newSoundWithFile("tests/drums.mono.wav")
  echo "playing on the right"
  var source = sound.play()
  source.pos = vec3(1,0,0)
  sleep(1500)
  source.stop()

  sleep(500)

  echo "playing on the left"
  source = sound.play()
  source.pos = vec3(-1,0,0)
  sleep(1500)
  source.stop()

block:
  # rotate sound in 3d
  let sound = newSoundWithFile("tests/drums.mono.wav")
  var source = sound.play()
  source.looping = true
  echo "rotateing sound in 3d, 1 rotation"
  for i in 0..360:
    let a = float(i) / 180 * PI
    source.pos = vec3(sin(a), cos(a), 0)
    sleep(20)
  source.stop()
  sleep(500)

block:
  # doppler waves shift as police car pases
  let sound = newSoundWithFile("tests/siren.wav")
  var source = sound.play()
  source.looping = true
  source.pos = vec3(-100, -100, 0)
  source.vel = vec3(1, 1, 0) * 50
  source.gain = 10
  echo "setting velcoity and position"
  for i in 1..200:
    source.pos = source.pos + source.vel / 50
    echo "    ", source.pos, source.vel
    sleep(20)
  source.stop()
  sleep(500)

block:
  # set gain
  let sound = newSoundWithFile("tests/drums.sterio.wav")
  var source = sound.play()
  source.looping = true
  echo "setting gain from 0 to 2"
  for i in 0..100:
    let a = float(i)/100
    source.gain = a * a
    echo "    ", source.gain
    sleep(20)
  source.stop()
  sleep(500)

block:
  # set pitch
  let sound = newSoundWithFile("tests/ding.wav")
  # make 2 rounds
  echo "setting pitch from 1/7 to 7/7 th"
  for i in 1..7:
    var source = sound.play()
    source.pitch = float(i) / 7.0
    echo "    ", source.pitch
    sleep(1000)
    source.stop()
  sleep(500)

block:
  # reset offset
  let sound = newSoundWithFile("tests/drums.sterio.wav")
  var source = sound.play()
  # make 2 rounds
  echo "restarting source 3 times"
  for i in 0..2:
    source.offset = 0
    source.play()
    sleep(300)
    echo "    ", source.offset
    source.stop()
  sleep(500)

block:
  echo "try to play fur elise "
  let sound = newSoundWithFile("tests/ding.wav")
  proc playNote(freq: int) =
    var source = sound.play()
    source.pitch = float(freq) * 0.002
    sleep int(120.0 * 1.5)
    echo "    activeSources:", activeSources.len
  playNote(659)
  playNote(622)
  playNote(659)
  playNote(622)
  playNote(659)
  playNote(494)
  playNote(587)
  playNote(523)
  playNote(440)
  playNote(262)
  playNote(330)
  playNote(440)
  playNote(494)
  playNote(330)
  playNote(415)
  playNote(494)
  playNote(523)
  playNote(330)
  playNote(659)
  playNote(622)
  playNote(659)
  playNote(622)
  playNote(659)
  playNote(494)
  playNote(587)
  playNote(523)
  playNote(440)
  playNote(262)
  playNote(330)
  playNote(440)
  playNote(494)
  playNote(330)
  playNote(523)
  playNote(494)
  playNote(440)
  sleep 1000