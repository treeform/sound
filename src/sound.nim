import sound/openal, sound/data_source
import streams, logging

type
  Sound* = ref object
    dataSource: DataSource
    gain*: ALfloat
    looping*: bool

  Source* = ALuint

var activeSources: seq[Source]


proc newSound(): Sound =
  result.new()
  result.gain = 1

proc `dataSource=`(s: Sound, ds: DataSource) = # Private for now. Should be public eventually
  s.dataSource = ds

proc newSoundWithPCMData*(data: pointer, dataLength, channels, bitsPerSample, samplesPerSecond: int): Sound =
  ## This function is only availbale for openal for now. Sorry.
  result = newSound()
  result.dataSource = newDataSourceWithPCMData(data, dataLength, channels, bitsPerSample, samplesPerSecond)

proc newSoundWithPCMData*(data: openarray[byte], channels, bitsPerSample, samplesPerSecond: int): Sound {.inline.} =
  ## This function is only availbale for openal for now. Sorry.
  newSoundWithPCMData(unsafeAddr data[0], data.len, channels, bitsPerSample, samplesPerSecond)

proc newSoundWithFile*(path: string): Sound =
  result = newSound()
  result.dataSource = newDataSourceWithFile(path)

proc newSoundWithStream*(s: Stream): Sound =
  result = newSound()
  result.dataSource = newDataSourceWithStream(s)

proc newSoundFromDataSource*(ds: DataSource): Sound =
  result = newSound()
  result.dataSource = ds

proc duration*(s: Sound): float {.inline.} =
  s.dataSource.duration

proc playing*(src: Source): bool {.inline.} =
  var state: ALenum
  alGetSourcei(src, AL_SOURCE_STATE, addr state)
  result = state == AL_PLAYING

proc stop*(src: Source) =
  alSourceStop(src)

proc setLooping*(src: Source, flag: bool) =
  alSourcei(src, AL_LOOPING, ALint(flag))

proc reclaimInactiveSource(): Source {.inline.} =
  for i in 0 ..< activeSources.len:
    let src = activeSources[i]
    if not src.playing:
      result = src
      activeSources.del(i)
      break

proc play*(s: Sound): Source =
  if s.dataSource.buffer != 0:
    var src = reclaimInactiveSource()
    if src == 0:
      alGenSources(1, addr src)
      activeSources.add(src)
    alSourcei(src, AL_BUFFER, cast[ALint](s.dataSource.buffer))
    alSourcef(src, AL_GAIN, s.gain)
    alSourcei(src, AL_LOOPING, ALint(s.looping))
    alSourcePlay(src)
    return src

proc setPos*(src: Source, x, y, z: float) =
  alSource3f(src, AL_POSITION, x, y, z)

proc `gain=`*(src: Source, v: float) =
  alSourcef(src, AL_GAIN, v)


