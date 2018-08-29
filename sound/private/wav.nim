## Reads wave files

import streams
import print


proc loadWavFile*(path: string, buffer: var pointer, len, channels, bitsPerSample, samplesPerSec: var int) =

  var f = newFileStream(open(path))
  let
    chunkID = f.readStr(4)
    chunkSize = f.readUint32()
    format = f.readStr(4)

    subchunk1ID = f.readStr(4)
    subchunk1Size = f.readUint32()
    audioFormat = f.readUint16()
    numChannels = f.readUint16()
    sampleRate = f.readUint32()
    byteRate = f.readUint32()
    blockAlign = f.readUint16()
    bitsPerSample2 = f.readUint16()

    subchunk2ID = f.readStr(4)
    subchunk2Size = f.readUint32()

    data = f.readStr(int subchunk2Size)

  print chunkID
  print chunkSize
  print format

  print subchunk1ID
  print subchunk1Size
  print audioFormat
  print numChannels
  print sampleRate
  print byteRate
  print blockAlign
  print bitsPerSample2

  print subchunk2ID
  print subchunk2Size

  assert chunkID == "RIFF"
  assert format == "WAVE"
  assert subchunk1ID == "fmt "
  assert audioFormat == 1
  assert subchunk2ID == "data"

  buffer = unsafeAddr data[0]
  len = data.len
  channels = int numChannels
  bitsPerSample = int bitsPerSample2
  samplesPerSec = int sampleRate