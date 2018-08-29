import openal, data_source_al
import streams, logging

type
    Sound* = ref object
        dataSource: DataSource
        src: ALuint
        gain: ALfloat
        looping: bool

    Source* = ALuint

var activeSounds: seq[Sound]

proc finalizeSound(s: Sound) =
    if s.src != 0: alDeleteSources(1, addr s.src)

proc newSound(): Sound =
    result.new(finalizeSound)
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

proc isSourcePlaying(src: ALuint): bool {.inline.} =
    var state: ALenum
    alGetSourcei(src, AL_SOURCE_STATE, addr state)
    result = state == AL_PLAYING

proc duration*(s: Sound): float {.inline.} = s.dataSource.duration

proc stop*(src: Source) =
    alSourceStop(src)

proc setLooping*(s: Sound, flag: bool) =
    s.looping = flag
    if s.src != 0:
        alSourcei(s.src, AL_LOOPING, ALint(flag))

proc reclaimInactiveSource(): ALuint {.inline.} =
    for i in 0 ..< activeSounds.len:
        let src = activeSounds[i].src
        if not src.isSourcePlaying:
            result = src
            activeSounds[i].src = 0
            activeSounds.del(i)
            break

proc stop*(s: Sound) =
    if s.src != 0:
        alSourceStop(s.src)

proc play*(s: Sound) =
    if s.dataSource.buffer != 0:
        if s.src == 0:
            s.src = reclaimInactiveSource()
            if s.src == 0:
                alGenSources(1, addr s.src)
            alSourcei(s.src, AL_BUFFER, cast[ALint](s.dataSource.buffer))
            alSourcef(s.src, AL_GAIN, s.gain)
            alSourcei(s.src, AL_LOOPING, ALint(s.looping))
            alSourcePlay(s.src)
            if activeSounds.isNil: activeSounds = @[]
            activeSounds.add(s)
        else:
            alSourceStop(s.src)
            alSourcePlay(s.src)


proc playWithSource*(s: Sound): Source =
    if s.dataSource.channels != 1:
        echo "Only mono sounds work in 3d"
    if s.dataSource.buffer != 0:
        var src = reclaimInactiveSource()
        if src == 0:
            alGenSources(1, addr src)
            activeSounds.add(s)
        alSourcei(src, AL_BUFFER, cast[ALint](s.dataSource.buffer))
        alSourcef(src, AL_GAIN, s.gain)
        alSourcei(src, AL_LOOPING, ALint(s.looping))
        alSourcePlay(src)
        return src


proc setPos*(src: Source, x, y, z: float) =
    alSource3f(src, AL_POSITION, x, y, z)


proc `gain=`*(s: Sound, v: float) =
    s.gain = v
    if s.src != 0:
        alSourcef(s.src, AL_GAIN, v)

proc gain*(s: Sound): float {.inline.} = s.gain
