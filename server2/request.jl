using HTTP
using JSON
using WAV
using Images
using SignalAnalysis

function read_audio(filepath)
	val, fs = wavread(filepath)
	lengthneed= 1600 
	y = SignalAnalysis.power(tfd(x, Spectrogram(nfft=128+64)))
        y = imresize(Gray.(y), (28, 28));
        y = reshape(convert(Array{Float32},y ), (28,28,1));
	return y
end
y = read_audio("./../mini_speech_commands/down/0a9f9af7_nohash_0.wav")
# y = reshape(convert(Array{Float64},y ), (28,28));
# y = round.(y; digits=5)
# y = [[1.0,2.0,3,4,5],[6,7,8,9,10]]
# y = collect(Iterators.flatten(y))
# println(length(y))
y = string(y)
# println(y)
# data = [1,2,3,4]
# url = "http://localhost:8001/digitreg"
# params = Dict("user"=>"j")

# send the request
# r = HTTP.request("POST", url, [("Content-Type", "application/json")], JSON.json(params))

# query_dict = Dict("retmax" => [1.0,2.0])
# body = HTTP.escapeuri(query_dict)
# HTTP.request("POST", "http://localhost:8001/digitreg", [], body=body)
r = HTTP.post("http://localhost:8001/digitreg", [], y)
println(String(r.body))
# HTTP.post("http://localhost:8001/digitreg", [], body)