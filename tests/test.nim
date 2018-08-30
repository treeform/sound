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
  sleep(2500)
  source.stop()

  sleep(500)

  echo "playing on the left"
  source = sound.play()
  source.pos = vec3(-1,0,0)
  sleep(2500)
  source.stop()

block:
  # rotate sound in 3d
  let sound = newSoundWithFile("tests/drums.mono.wav")
  var source = sound.play()
  source.looping = true
  # make 2 rounds
  echo "rotateing sound in 3d, 2 rotations"
  for i in 0..360 * 2:
    let a = float(i) / 180 * PI
    source.pos = vec3(sin(a), cos(a), 0)
    sleep(20)
  source.stop()
  sleep(500)

block:
  # set gain
  let sound = newSoundWithFile("tests/drums.sterio.wav")
  var source = sound.play()
  source.looping = true
  # make 2 rounds
  echo "setting gain from 0 to 2"
  for i in 0..100:
    source.gain = float(i)/100
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
  source.looping = true
  # make 2 rounds
  echo "setting gain from 0 to 2"
  for i in 0..3:
    source.offset = 0
    sleep(300)
    echo "    ", source.offset
  source.stop()
  sleep(500)