## Reads wave files
import streams

proc loadWavFile*(path: string, buffer: var pointer, len, channels, bitsPerSample, samplesPerSec: var int) =
  ## Reads wav sound file format

  # OMG is this like the easiest format to read ever?
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