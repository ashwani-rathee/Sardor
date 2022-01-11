using PortAudio, SampledSignals, LibSndFile
using HTTP
using WAV
using Statistics
using Plots
using Images
using PyCall
using DSP

function spectronew(val)
    fs = 16000
    audio_test = SampleBuf(val, 16000)
    n = length(audio_test.data)
    nw = n÷25
    spec = DSP.spectrogram(audio_test.data[:], nw, nw÷10; fs=fs)
    png(
        Plots.heatmap(spec.time, spec.freq, pow2db.(spec.power), xaxis = false, yaxis=false, legend = :none, ticks=false, margins = -1.2Plots.cm, size=(28.5,29)),
        "testcase",
    )
    img = load("testcase.png")
    img = imresize(img, (28,28))
    img = reshape(convert(Array{Float32}, Gray.(img)), (28, 28, 1));
    return img
end
function senddataup(data)
    batch = map(x->data[16000*(x-1)+1:16000*x] ,1:5)
    batch = map(x->spectronew(x), batch)
    for i in batch
        r  = HTTP.post("http://localhost:8003/adddata", [], string(i))
        # println(String(r.body))
    end
end

function sendfileup(filename)    	
    splited = split(filename, "/")
    label = splited[end-1]
    label2 = splited[end]
    img =  convert(Array{Float32}, Gray.(load("./datasetspectro2/"*label*"#"*label2)))
    println(size(img))
    batch = map(x->img , 1:5)
    #batch = map(x->spectronew(x), batch)
    for i in batch
        r  = HTTP.post("http://localhost:8003/adddata", [], string(i))
        # println(String(r.body))
    end
end

function sendsingledataup(data)
   r  = HTTP.post("http://localhost:8003/adddata", [], string(spectronew(data)))
   # println(String(r.body))
end

labeldict = Dict("left" => 0, "right" => 1, "up" => 2,  "down" => 3,""=>4)

function makeamove(mode)
    println(mode)
    py"""
    import pyautogui as autogui
    def makemode(mode):
        if mode == 3:
            autogui.press('left')
        elif mode == 4:
            autogui.press('right')
        elif mode == 5:
            autogui.press('up')  
        elif mode == 6:
            autogui.press('down')  
        else:
            print(mode)
            print("mode not yet made")
    """
    py"makemode"(mode)
end

py"""
import collections
import contextlib
import sys
import wave

import webrtcvad


def read_wave(path):
    with contextlib.closing(wave.open(path, 'rb')) as wf:
        num_channels = wf.getnchannels()
        assert num_channels == 1
        sample_width = wf.getsampwidth()
        assert sample_width == 2
        sample_rate = wf.getframerate()
        assert sample_rate in (8000, 16000, 32000, 48000)
        pcm_data = wf.readframes(wf.getnframes())
        return pcm_data, sample_rate


def write_wave(path, audio, sample_rate):
    with contextlib.closing(wave.open(path, 'wb')) as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(sample_rate)
        wf.writeframes(audio)


class Frame(object):
    def __init__(self, bytes, timestamp, duration):
        self.bytes = bytes
        self.timestamp = timestamp
        self.duration = duration


def frame_generator(frame_duration_ms, audio, sample_rate):
    n = int(sample_rate * (frame_duration_ms / 1000.0) * 2)
    offset = 0
    timestamp = 0.0
    duration = (float(n) / sample_rate) / 2.0
    while offset + n < len(audio):
        yield Frame(audio[offset:offset + n], timestamp, duration)
        timestamp += duration
        offset += n


def vad_collector(sample_rate, frame_duration_ms,
                  padding_duration_ms, vad, frames):
    num_padding_frames = int(padding_duration_ms / frame_duration_ms)
    ring_buffer = collections.deque(maxlen=num_padding_frames)
    triggered = False

    voiced_frames = []
    for frame in frames:
        is_speech = vad.is_speech(frame.bytes, sample_rate)

        sys.stdout.write('1' if is_speech else '0')
        if not triggered:
            ring_buffer.append((frame, is_speech))
            num_voiced = len([f for f, speech in ring_buffer if speech])
            if num_voiced > 0.9 * ring_buffer.maxlen:
                triggered = True
                # sys.stdout.write('+(%s)' % (ring_buffer[0][0].timestamp,))
                for f, s in ring_buffer:
                    voiced_frames.append(f)
                ring_buffer.clear()
        else:
            voiced_frames.append(frame)
            ring_buffer.append((frame, is_speech))
            num_unvoiced = len([f for f, speech in ring_buffer if not speech])
            if num_unvoiced > 0.9 * ring_buffer.maxlen:
                # sys.stdout.write('-(%s)' % (frame.timestamp + frame.duration))
                triggered = False
                yield b''.join([f.bytes for f in voiced_frames])
                ring_buffer.clear()
                voiced_frames = []
    # if triggered:
        # print("Here I arrive")
        # sys.stdout.write('-(%s)' % (frame.timestamp + frame.duration))
    #sys.stdout.write('\n')
    if voiced_frames:
        yield b''.join([f.bytes for f in voiced_frames])
    
def doyourvaejobplease(path):
    audio, sample_rate = read_wave(path)
    vad = webrtcvad.Vad(int(1))
    frames = frame_generator(30, audio, sample_rate)
    frames = list(frames)
    segments = vad_collector(sample_rate, 30, 300, vad, frames)
    for i, segment in enumerate(segments):
        path = './audios/chunk-%002d.wav' % (i,)
        # print(' Writing %s' % (path,))
        write_wave(path, segment, sample_rate)
"""


function dealwithmyissue(results)
	for i in results
		if sign(i[1]) == -1
			lowval =  abs(i[1])
			i[1] = 0
			i[2] = i[2] + lowval
		elseif i[2] > 88200
			highval = i[2]-88200
			i[2] = 88200
			i[1] = i[1] - highval
		end
	end
	return results
end
function findislands(arr)
	startindices = []
	finalindices = []
	for (i,val) in enumerate(arr)
		if i == 1
			continue
		elseif arr[i] == 0 && arr[i-1] == 1
			push!(finalindices, i-1)
		elseif arr[i-1] == 0 && arr[i] == 1
			push!(startindices, i)
		end
	end
	lengths = finalindices .- startindices .+1 
	centeralpoints = round.(Int, (startindices .+ finalindices)/2)
	results = map(x-> [x-8000,x+7999], centeralpoints)
	results = dealwithmyissue(results)
	return results
end
using Glob
while true
    stream = PortAudioStream("default", 1, 0)
    buf = read(stream, 2s).data[:]
    # #binarymask = abs.(buf .-0.02) .> 0.1 
    # #islanddetails = findislands(binarymask)
    # #interestingdata = map(x->buf[x[1]:x[2]], islanddetails)
    wavwrite(buf,  "test8final.wav", Fs=48000, nbits=16,  compression=WAVE_FORMAT_PCM)
    # mkdir("audios")
    py"doyourvaejobplease"("test8final.wav")
    close(stream)
    # y, fs = wavread("./mini_speech_commands/down/00b01445_nohash_1.wav") # works for down
    # y, fs = wavread("./mini_speech_commands/left/012c8314_nohash_0.wav") # works for left
    # y, fs = wavread("./mini_speech_commands/up/0132a06d_nohash_2.wav") # works for up
    # y, fs = wavread("./mini_speech_commands/right/ffd2ba2f_nohash_4.wav ") # works for right
    #senddataup(vec(buf.data))
    #senddataup(repeat(y, 6))
    listofwavs = glob("*.wav","./audios")
    # println(listofwavs)
    interestingdata = map(x->wavread(x)[1][:], listofwavs)
    # println(typeof(interestingdata[1]))
    for i in interestingdata
        datara = ceil(Int, length(i)/16000)
        zerosadd =  datara*16000 - length(i)
        println(zerosadd)
        zeroestobeadded = zeros(Float64, zerosadd)
        i = vcat(i, zeroestobeadded)
        batch = map(x->i[16000*(x-1)+1:16000*x] ,1:datara)
    	for j in batch
            sendsingledataup(j)
        end
    end

    # # rm("audios")
    map(x->rm(x), listofwavs)
    interestingdata = nothing
    listofwavs = nothing
    buf = nothing
    # #sendfileup("./mini_speech_commands/up/0132a06d_nohash_2.wav.png")
    # #down#00b01445_nohash_1.wav.png # for down
    # #./datasetspectro2/left#ffd2ba2f_nohash_4.wav.png" # for left
    # #./datasetspectro2/up#0132a06d_nohash_2.wav.png # for up
    # #./datasetspectro2/right#ffd2ba2f_nohash_4.wav.png for right
    r = HTTP.get("http://localhost:8003/digitreg", [])
    mode = labeldict[String(r.body)]
    makeamove(mode)
    sleep(0.1)
end
