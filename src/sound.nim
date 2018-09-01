import streams, logging, vmath
import openal
import sound/data_source

type
  Sound* = ref object
    dataSource: DataSource

  Source* = ALuint

var activeSources*: seq[Source]


proc newSound(): Sound =
  result.new()

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

proc duration*(s: Sound): float {.inline.} =
  s.dataSource.duration

proc channels*(s: Sound): int {.inline.} =
  s.dataSource.channels

proc playing*(src: Source): bool {.inline.} =
  var state: ALenum
  alGetSourcei(src, AL_SOURCE_STATE, addr state)
  result = state == AL_PLAYING

proc stop*(src: Source) =
  alSourceStop(src)

proc play*(src: Source) =
  alSourcePlay(src)

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

proc `pos=`*(src: Source, pos: Vec3) =
  alSource3f(src, AL_POSITION, pos.x, pos.y, pos.z)

proc `pos`*(src: Source): Vec3 =
  var tmp = [ALfloat(0.0),0.0,0.0]
  alGetSourcefv(src, AL_POSITION, addr tmp[0])
  return vec3(tmp[0], tmp[1], tmp[2])

proc `vel=`*(src: Source, vel: Vec3) =
  alSource3f(src, AL_VELOCITY, vel.x, vel.y, vel.z)

proc `vel`*(src: Source): Vec3 =
  var tmp = [ALfloat(0.0),0.0,0.0]
  alGetSourcefv(src, AL_VELOCITY, addr tmp[0])
  return vec3(tmp[0], tmp[1], tmp[2])

proc `mat=`*(src: Source, mat: Mat4) =
  var tmp1 = [ALfloat(0.0), 0.0, 0.0]
  tmp1[0] = mat.pos.x
  tmp1[1] = mat.pos.y
  tmp1[2] = mat.pos.z
  alSourcefv(src, AL_POSITION, addr tmp1[0])
  var tmp2 = [ALfloat(0.0), 0.0, 0.0, 0.0, 0.0, 0.0]
  tmp2[0] = mat.fov.x
  tmp2[1] = mat.fov.y
  tmp2[2] = mat.fov.z
  tmp2[3] = mat.up.x
  tmp2[4] = mat.up.y
  tmp2[5] = mat.up.z
  alSourcefv(src, AL_ORIENTATION, addr tmp2[0])

proc `mat`*(src: Source): Mat4 =
  var tmp1 = [ALfloat(0.0), 0.0, 0.0]
  alGetSourcefv(src, AL_POSITION, addr tmp1[0])
  var tmp2 = [ALfloat(0.0), 0.0, 0.0, 0.0, 0.0, 0.0]
  alGetSourcefv(src, AL_ORIENTATION, addr tmp2[0])
  return lookAt(
    vec3(tmp1[0], tmp1[1], tmp1[2]),
    vec3(tmp2[0], tmp2[1], tmp2[2]),
    vec3(tmp2[3], tmp2[4], tmp2[5])
  )

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