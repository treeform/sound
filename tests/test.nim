import os
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