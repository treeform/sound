import openal
import stb_vorbis

type Sound* = ref object
    buffer: ALuint
    src: ALuint

var contextInited = false

proc createContext() =
    if contextInited: return
    contextInited = true
    var listenerPos = [ALfloat(0.0),0.0,4.0]
    var listenerVel = [ALfloat(0.0),0.0,0.0]
    var listenerOri = [ALfloat(0.0),0.0,1.0, 0.0,1.0,0.0]

    let device = alcOpenDevice(nil)
    if device.isNil:
        echo "Could not open device"

    let context = alcCreateContext(device, nil)
    if context.isNil:
        echo "Could not create context"

    discard alcMakeContextCurrent(context)

    #alGetError(); // clear any error messages
    alListenerfv(AL_POSITION, addr listenerPos[0])
    alListenerfv(AL_VELOCITY, addr listenerVel[0])
    alListenerfv(AL_ORIENTATION, addr listenerOri[0])

proc finalizeSound(s: Sound) =
    if s.src != 0: alDeleteSources(1, addr s.src)
    if s.buffer != 0: alDeleteBuffers(1, addr s.buffer)

proc newSoundWithFile*(path: string): Sound =
    createContext()

    let v = stb_vorbis_open_filename(path, nil, nil)
    if v.isNil: return
    let i = stb_vorbis_get_info(v)

    var format : ALenum
    if i.channels == 1:
        format = AL_FORMAT_MONO16
    else:
        format = AL_FORMAT_STEREO16

    let freq = ALsizei(i.sample_rate)

    var buffer = newSeq[uint16]() # The sound buffer data from file

    #var endian: cint = 0 # 0 for Little-Endian, 1 for Big-Endian

    #var bitStream: cint
    var bytes : clong

    const LE_OGG_BUFFER_SIZE = 32768

    var curOffset = 0
    while true:
        # Read up to a buffer's worth of decoded sound data
        buffer.setLen(curOffset + LE_OGG_BUFFER_SIZE)
        bytes = stb_vorbis_get_samples_short_interleaved(v, i.channels, addr buffer[curOffset], LE_OGG_BUFFER_SIZE) * i.channels

#        bytes = read(addr f, cast[cstring](addr buffer[curOffset]), LE_OGG_BUFFER_SIZE, endian, 2, 1, addr bitStream)
        if bytes > 0:
            curOffset += bytes
        else:
            buffer.setLen(curOffset)
            break

    stb_vorbis_close(v)

    result.new(finalizeSound)

    alGenBuffers(1, addr result.buffer)
    # Upload sound data to buffer
    alBufferData(result.buffer, format, addr buffer[0], ALsizei(buffer.len), freq)
    alGenSources(1, addr result.src)
    alSourcei(result.src, AL_BUFFER, cast[ALint](result.buffer))

proc play*(s: Sound) =
    # Attach sound buffer to source
    alSourcePlay(s.src)
