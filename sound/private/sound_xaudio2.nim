import winlean, streams
import stb_vorbis
import context_xaudio2, data_source_xaudio2

type Sound* = ref object
    sourceVoice: IXAudio2SourceVoice
    mDataSource: DataSource
    mGain: cfloat
    mLooping: bool

var activeSounds: seq[Sound]

proc newSound(): Sound =
    result.new()
    result.gain = 1.0

proc `dataSource=`(s: Sound, dataSource: DataSource) =
    s.dataSource = dataSource

proc newSoundWithFile*(path: string): Sound =
    createContext()
    result = newSound()
    result.dataSource = newDataSourceWithFile(path)

proc newSoundWithStream*(s: Stream): Sound =
    createContext()
    result = newSound()
    result.dataSource = newDataSourceWithStream(s)


proc isPlaying(s: IXAudio2SourceVoice): bool {.inline.} =
    var state: XAUDIO2_VOICE_STATE
    discard s.GetState(s, state, XAUDIO2_VOICE_NOSAMPLESPLAYED)
    result = state.BuffersQueued != 0

proc reclaimInactiveSource() {.inline.} =
    for i in 0 ..< activeSounds.len:
        let src = activeSounds[i].sourceVoice
        if not src.isPlaying:
            discard src.DestroyVoice(src)
            activeSounds[i].sourceVoice = nil
            activeSounds.del(i)
            break

proc submitBuffer(s: Sound) =
    var buf: XAUDIO2_BUFFER
    buf.pAudioData = addr s.dataSource.data[0]
    buf.AudioBytes = uint32(s.dataSource.data.len)
    if s.looping:
        buf.LoopCount = XAUDIO2_LOOP_INFINITE
    discard s.sourceVoice.SubmitSourceBuffer(s.sourceVoice, addr buf, nil)

proc play*(s: Sound) =
    if not s.dataSource.isNil:
        if s.sourceVoice.isNil:
            reclaimInactiveSource()
            if activeSounds.isNil: activeSounds = @[]
            activeSounds.add(s)
        else:
            discard s.sourceVoice.DestroyVoice(s.sourceVoice)
        discard ixaudio2.CreateSourceVoice(ixaudio2, addr s.sourceVoice, addr s.dataSource.wfx, 0, 0, nil, nil, nil)
        s.submitBuffer()
        discard s.sourceVoice.SetVolume(s.sourceVoice, s.gain, 0)
        discard s.sourceVoice.Start(s.sourceVoice, 0, 0)

proc stop*(s: Sound) =
    if not s.sourceVoice.isNil:
        discard s.sourceVoice.Stop(s.sourceVoice, 0, 0)

proc `gain=`*(s: Sound, v: float) =
    s.gain = v
    if not s.sourceVoice.isNil:
        discard s.sourceVoice.SetVolume(s.sourceVoice, s.gain, 0)

proc gain*(s: Sound): float {.inline.} = s.gain

proc setLooping*(s: Sound, flag: bool) =
    if s.looping != flag:
        s.looping = flag
        if not s.sourceVoice.isNil:
            s.submitBuffer()

proc duration*(s: Sound): float {.inline.} = s.dataSource.duration
