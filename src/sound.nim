import sound/openal, sound/data_source
import streams, logging, vmath

type
  Sound* = ref object
    dataSource: DataSource

  Source* = ALuint

var activeSources: seq[Source]


proc newSound(): Sound =
  result.new()

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
    alSourcePlay(src)
    return src

proc `pos=`*(src: Source, x, y, z: float32) =
  alSource3f(src, AL_POSITION, x, y, z)

proc `pos=`*(src: Source, pos: Vec3) =
  alSource3f(src, AL_POSITION, pos.x, pos.y, pos.z)

proc `gain=`*(src: Source, v: float32) =
  alSourcef(src, AL_GAIN, v)

proc `gain`*(src: Source): float32 =
  alGetSourcef(src, AL_GAIN, addr result)

proc `pitch=`*(src: Source, v: float32) =
  alSourcef(src, AL_PITCH, v)

proc `pitch`*(src: Source): float32 =
  alGetSourcef(src, AL_PITCH, addr result)

proc `offset=`*(src: Source, v: float32) =
  alSourcef(src, AL_SEC_OFFSET, v)

proc `offset`*(src: Source): float32 =
  alGetSourcef(src, AL_SEC_OFFSET, addr result)

proc `looping=`*(src: Source, v: bool) =
  var looping: ALint = 0
  if v == true: looping = 1
  alSourcei(src, AL_LOOPING, looping)

proc `looping`*(src: Source): bool =
  var looping: ALint
  alGetSourcei(src, AL_LOOPING, addr looping)
  return looping == 1