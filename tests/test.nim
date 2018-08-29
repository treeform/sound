import os, math
import sound


block:
  # playing wav file
  let sound = newSoundWithFile("tests/ding.wav")
  sound.play()
  sleep(1000)

block:
  # playing ogg file
  let sound = newSoundWithFile("tests/robo.ogg")
  sound.play()
  sleep(1000)

block:
  # playing sound in 3d
  let sound = newSoundWithFile("tests/drums.mono.wav")
  # play on the right
  var source = sound.playWithSource()
  source.setPos(1,0,0)
  sleep(1000)
  # play on the left
  source.setPos(-1,0,0)
  sleep(1000)
  source.stop()

block:
  # rotate sound in 3d
  let sound = newSoundWithFile("tests/drums.mono.wav")
  sound.setLooping(true)
  var source = sound.playWithSource()
  # make 2 rounds
  for i in 0..360 * 2:
    let a = float(i) / 180 * PI
    source.setPos(sin(a), cos(a), 0)
    sleep(10)
  source.stop()