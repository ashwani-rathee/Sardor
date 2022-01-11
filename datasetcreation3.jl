using Glob
using WAV
using Plots
# using SignalAnalysis
using SampledSignals
using DSP
left = glob("left/*.wav", "./mini_speech_commands")
right = glob("right/*.wav", "./mini_speech_commands")
up = glob("up/*.wav", "./mini_speech_commands")
down = glob("down/*.wav", "./mini_speech_commands")
datalist = vcat(left, right, up, down)
for i in datalist
    # println(i)
    y, fs = wavread(i)
    audio_test = SampleBuf(y,fs)
    n = length(audio_test.data)
    nw = n÷25
    spec = DSP.spectrogram(audio_test.data[:], nw, nw÷10; fs=fs)
    splited = split(i, "/")
    label = splited[end-1]
    label2 = splited[end]
    # println(label*"#"*label2)
    # splitedag = split(label*"#"*label2, "#")
    # println(splitedag)
    png(
        heatmap(spec.time, spec.freq, pow2db.(spec.power), xaxis = false, yaxis=false, legend = :none, ticks=false, margins = -1.2Plots.cm, size=(28.5,29)),
        "./datasetspectro2/"* label * "#" * label2,
    )
    # break
end
