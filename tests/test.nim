import os, math
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
  source.setPos(1,0,0)
  sleep(2500)
  source.stop()

  sleep(500)

  echo "playing on the left"
  source = sound.play()
  source.setPos(-1,0,0)
  sleep(2500)
  source.stop()

block:
  # rotate sound in 3d
  let sound = newSoundWithFile("tests/drums.mono.wav")
  sound.looping = true
  var source = sound.play()
  # make 2 rounds
  echo "rotateing sound in 3d, 2 rotations"
  for i in 0..360 * 2:
    let a = float(i) / 180 * PI
    source.setPos(sin(a), cos(a), 0)
    sleep(20)
  source.stop()
  sleep(500)