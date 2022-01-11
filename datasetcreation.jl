using Glob
using WAV
using Plots
using SignalAnalysis
datalist = glob("**/*.wav", "./mini_speech_commands")

for i in datalist
    println(i)
    y, fs = wavread(i)
    test1 = tfd(y[:], SignalAnalysis.Spectrogram())
    splited = split(i, "/")
    label = splited[end-1]
    label2 = splited[end]
    # println(label*"#"*label2)
    # splitedag = split(label*"#"*label2, "#")
    # println(splitedag)
    png(
        plot(test1, legend = :none, ticks=false, xaxis =false, yaxis=false, margins = -1.0Plots.cm, size=(28,28)),
        "./datasetspectro/"* label * "#" * label2,
    )
    # break
end
