### A Pluto.jl notebook ###
# v0.17.4

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 2edd755e-6973-11ec-27c6-4f0531f047a0
using WAV, PortAudio, SampledSignals, LibSndFile, Plots,PlutoUI

# ╔═╡ 4b6fbff4-7239-4501-b070-529460a54ed9
using DSP, UnicodePlots, PyCall, Glob

# ╔═╡ 731b6d2f-99f2-47d1-a145-c8f36b742fc2
md"
# Introduction to Audio in Julia
Project Sardor- Part 1
"

# ╔═╡ a00b47a5-2757-4d55-9781-8ef06bf65211
md"![](https://i.imgur.com/k2qKXDd.png)"

# ╔═╡ 2d308cf3-6f29-4696-8ef2-043c61723af9
md"![](https://www.nicepng.com/png/full/16-169858_frequency-and-wavelength-in-sound-waves-sound-molecules.png)"

# ╔═╡ aef4ccd9-9382-438f-9ff7-144a11b62200
wavread("piano-phrase.wav")

# ╔═╡ 12d9ed29-26f8-4c26-92f5-ec1ef087f5a9
audio_data, sample_rate = wavread("piano-phrase.wav"); # reading an audio

# ╔═╡ 8bd55615-9aaf-4839-91ff-bb71d58da589
wavplay(audio_data, sample_rate) # let's play audio now

# ╔═╡ 86ce8edc-842e-474e-8142-c9e1d4a6470d
md"""
#### Let's change these parameters 
`Amplitude = ` $(@bind A Slider(.1:.1:1,default=.8,show_value=true))
`PhaseAngle = ` $(@bind phi Slider(0:pi/6:2pi,default=pi/2,show_value=true))
`Frequency = ` $(@bind f0 Slider(0:1000:10000,default=1000,show_value=true))
`Sample Rate = ` $(@bind fs3 Slider(0:1000:50000,default=44100,show_value=true))
"""

# ╔═╡ ccd3ef9e-b5f7-4e29-9b3a-12d9b1e62dc4
begin
t1 = -0.002:1/fs3:0.002
ycos = A*cos.(2*pi*f0*t1 .+ phi)
wavplay(ycos, fs3)	
end

# ╔═╡ 73ce2a7c-d4d8-450f-95d3-f9da0e361808
lineplot(t1, ycos)

# ╔═╡ 954c097e-7ee5-4de4-ad0f-6ab3f204d357
begin

# writing an audio
fs = 8e3
t = 0.0:1/fs:prevfloat(1.0)
f = 1e3
y = sin.(2pi * f * t) * 0.1
wavwrite(y, "example.wav", Fs=fs)

end

# ╔═╡ bba5212d-abfe-4aab-a270-0a60cff0f305
begin
# add silence this could be useful, or make a audio data array of a certain length
y2 = sin.(2pi * 2f * t) * 0.1
wavappend(y2, "example.wav")
end

# ╔═╡ 128105e4-0a32-4c61-b285-ac11af8f9bec
begin
auddata, fsd = wavread("example.wav");
data1 = zeros(Float64, 100000- length(auddata[:])) # silence added at end
wavappend(data1, "example.wav")
end

# ╔═╡ bcc7a1d1-59e0-413f-831d-6132bb0158e7
result = vcat(auddata[:], data1)

# ╔═╡ b73c4181-858f-42cc-ad44-140406eb9231
begin
y1, fs1 = wavread("example.wav")
wavplay(y1, fs1)
end

# ╔═╡ 3235909b-9f5c-4a52-971e-979aa0a7b0fc
md"""
#### Say hi to portaudio
PortAudio is an open-source computer library for audio playback and recording written in C. PortAudio.jl is a wrapper to use the api in Julia.
"""

# ╔═╡ 3bb905f4-5fba-4327-8d80-fa625f8501ab
PortAudio.devices()

# ╔═╡ 75d09f1c-ed03-45fc-b107-b403f71c5cff
stream = PortAudioStream("default", 1, 0)

# ╔═╡ cbd0ac62-125f-419f-9458-33f76768ae36
buf = read(stream, 5s).data[:]

# ╔═╡ 90e79652-438f-4796-a10e-713b68fca189
length(buf)/44100

# ╔═╡ 89ebc526-8e5d-465b-817b-87c3d49d6472
close(stream)

# ╔═╡ d87cfc7d-b17d-4925-b7b9-7f95d56fff14
wavplay(buf, 44100)

# ╔═╡ 225030d2-e2fc-497d-96ba-1ba0b6153567
wavwrite(buf,  "streaminput.wav", Fs=48000, nbits=16,  compression=WAVE_FORMAT_PCM)

# ╔═╡ 71b0e49a-f96d-463e-bc73-37b7e5fa79cd
md"
### WAV Plot
- Ys = sin.(2pi * f * t) * A
- Xs = 0.0:1/fs:prevfloat(1.0)
"

# ╔═╡ 00e1e3df-8f51-4e66-b73f-0e0caa2da0e1
plot(0:1/fs:(length(buf)-1)/fs, buf, xlabel = "Time [s]")

# ╔═╡ 1daba4c9-78d4-4030-918e-62e29f473f1a


# ╔═╡ 093e2227-72e5-4111-916b-60565c83be1e


# ╔═╡ 6ab497d8-8f9d-4a1a-b7d9-c0c0e48d38e6
md"
### Spectrogram
A spectrogram is a visual way of representing the signal strength, or “loudness”, of a signal over time at various frequencies present in a particular waveform.  Not only can one see whether there is more or less energy at, for example, 2 Hz vs 10 Hz, but one can also see how energy levels vary over time.
"

# ╔═╡ e1ea44a9-7af8-47b3-8970-551e021bcb0b
spec= spectrogram(buf, 255, 128; fs=fs);

# ╔═╡ 00ec9153-045c-4e88-af10-d615a6a55603
Plots.heatmap(spec.time, spec.freq, pow2db.(spec.power), xguide="Time [s]", yguide="Frequency [Hz]", legend = :none)

# ╔═╡ 785367e4-b839-4123-afe8-91c6e681512a


# ╔═╡ 926b3aa7-69ae-45f8-9a98-95b3bf8425d0


# ╔═╡ f954b047-0191-4bf6-8542-79ee28a0e5b2
md"
## Real Time Inputs
Two ways:
- Using PortAudio
- Using Javacript(This one is picked from Ellihu Garett's github)
"

# ╔═╡ 5f36b4b3-b071-49e0-8160-ad3d4945756f
@bind go Clock()

# ╔═╡ c5231ebd-33a7-4bb5-a94c-c961f23f4823
let
	go
	stream = PortAudioStream("default", 1, 0)
	buf = read(stream, 2s).data[:]
	close(stream)
	spec1 = spectrogram(buf, 255, 128; fs=fs);
	global a = Plots.heatmap(spec1.time, spec1.freq, pow2db.(spec1.power), xguide="Time [s]", yguide="Frequency [Hz]", legend = :none)
	plot(0:1/fs:(length(buf)-1)/fs, buf, xlabel = "Time [s]", ylims=(-1,1))
end

# ╔═╡ d1430b88-0dbe-41e3-a362-d37889e436e7
a

# ╔═╡ c841ce52-a946-4d9d-82c7-c4349f22a46e
@bind audio HTML("""
<audio id="player"></audio>
<button class="button" id="stopButton">Stop</button>
<script>
  const player = document.getElementById('player');
  const stop = document.getElementById('stopButton');
  const handleSuccess = function(stream) {
    const context = new AudioContext({ sampleRate: 44100 });
    const analyser = context.createAnalyser();
    const source = context.createMediaStreamSource(stream);
    source.connect(analyser);
    
    const bufferLength = analyser.frequencyBinCount;
    
    let dataArray = new Float32Array(bufferLength);
    let animFrame;
    
    const streamAudio = () => {
      animFrame = requestAnimationFrame(streamAudio);
      analyser.getFloatTimeDomainData(dataArray);
      player.value = dataArray;
      player.dispatchEvent(new CustomEvent("input"));
    }
    streamAudio();
    stop.onclick = e => {
      source.disconnect(analyser);
      cancelAnimationFrame(animFrame);
    }
  }
  navigator.mediaDevices.getUserMedia({ audio: true, video: false })
    .then(handleSuccess)
</script>
<style>
.button {
  background-color: darkred;
  border: none;
  border-radius: 12px;
  color: white;
  padding: 15px 32px;
  text-align: center;
  text-decoration: none;
  display: inline-block;
  font-size: 16px;
  font-family: "Alegreya Sans", sans-serif;
  margin: 4px 2px;
  cursor: pointer;
}
</style>
""")

# ╔═╡ a3370c94-3806-4f25-8d11-c159b1317586
plot(domain(SampleBuf(Array(audio), 44100)), SampleBuf(Array(audio), 44100), legend=false, ylims=(-1,1),xlabel="Time(s)", ylabel="Y")

# ╔═╡ ae8cc93e-3e4e-4b95-8758-f982f9d2e573
md"""
#### Using PyCall 
I use it because it opens up a world of work of python developers for me as I use python quite often. Sometime one language has speed, other provides the knowhow to use that speed because of experience. I meant I couldn't find a audio activity detector in Julia, so I use python for that in this project.

"""

# ╔═╡ bdeeadfa-0ee0-41c7-acdf-c31a1c63eb0b
begin
# to use python directly but with a different type of syntax
math = pyimport("math")
math.sin(math.pi *2/ 4)
end

# ╔═╡ 4f8d137d-3b42-4496-83c7-7edca075a422
begin

# to code in python only and then able to interact with that python
py"""
import numpy as np
def testfunc(val):
	print(val)
	return np.sin(np.pi * val / 4)
"""
py"testfunc"(2)
end

# ╔═╡ ccdc4295-432c-4c96-b5c7-82b5d13d892d
begin

# to create a  way between julian function and python function
py"""
import numpy as np
def testfunc1(val):
	print(val)
	return np.sin(np.pi * val / 4)
"""
testfunc1 = py"testfunc1"
testfunc1(1)
end

# ╔═╡ c558365b-8207-440b-9cc0-4d4eb86ef9df
md"""
#### Last but not the least
using  our friend glob.jl to prepare dataset list

"""

# ╔═╡ 777be32e-f5c2-4817-b921-5864613494a7
datalist = glob("**/*.wav","./mini_speech_commands") 
# check it here: https://github.com/vtjnash/Glob.jl

# ╔═╡ 26f03e01-9bbc-43b1-8b69-4c0c1d144843
html"""<style>
footer {
    display:None;
}
"""

# ╔═╡ 2edd7540-6973-11ec-1a21-273536e0bc2c
html"""
<!-- <div id="snow"></div> -->
<style>
	body:not(.disable_ui):not(.more-specificity) {
        background-color:#e9ecff;
    }
	pluto-output{
		border-radius: 0px 8px 0px 0px;
        background-color:#e9ecff;
	}
	#snow {
        position: fixed;
    	top: 0;
    	left: 0;
    	right: 0;
    	bottom: 0;
    	pointer-events: none;
    	z-index: 1000;
	}
</style>
<script src="https://cdn.jsdelivr.net/particles.js/2.0.0/particles.min.js"></script>
<script>
        setTimeout(() => window.particlesJS("snow", {
            "particles": {
                "number": {
                    "value": 70,
                    "density": {
                        "enable": true,
                        "value_area": 800
                    }
                },
                "color": {
                    "value": "#ffffff"
                },
                "opacity": {
                    "value": 0.7,
                    "random": false,
                    "anim": {
                        "enable": false
                    }
                },
                "size": {
                    "value": 5,
                    "random": true,
                    "anim": {
                        "enable": false
                    }
                },
                "line_linked": {
                    "enable": false
                },
                "move": {
                    "enable": true,
                    "speed": 5,
                    "direction": "bottom",
                    "random": true,
                    "straight": false,
                    "out_mode": "out",
                    "bounce": false,
                    "attract": {
                        "enable": true,
                        "rotateX": 300,
                        "rotateY": 1200
                    }
                }
            },
            "interactivity": {
                "events": {
                    "onhover": {
                        "enable": false
                    },
                    "onclick": {
                        "enable": false
                    },
                    "resize": false
                }
            },
            "retina_detect": true
        }), 3000);
	</script>
"""


# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DSP = "717857b8-e6f2-59f4-9121-6e50c889abd2"
Glob = "c27321d9-0574-5035-807b-f59d2c89b15c"
LibSndFile = "b13ce0c6-77b0-50c6-a2db-140568b8d1a5"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
PortAudio = "80ea8bcb-4634-5cb3-8ee8-a132660d1d2d"
PyCall = "438e738f-606a-5dbb-bf0a-cddfbfd45ab0"
SampledSignals = "bd7594eb-a658-542f-9e75-4c4d8908c167"
UnicodePlots = "b8865327-cd53-5732-bb35-84acbb429228"
WAV = "8149f6b0-98f6-5db9-b78f-408fbbb8ef88"

[compat]
DSP = "~0.6.10"
Glob = "~1.3.0"
LibSndFile = "~2.4.0"
Plots = "~1.25.4"
PlutoUI = "~0.7.27"
PortAudio = "~1.1.2"
PyCall = "~1.93.0"
SampledSignals = "~2.1.2"
UnicodePlots = "~2.5.1"
WAV = "~1.2.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractFFTs]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "485ee0867925449198280d4af84bdb46a2a404d0"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.0.1"

[[AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "9faf218ea18c51fcccaf956c8d39614c9d30fe8b"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.2"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[ArrayInterface]]
deps = ["Compat", "IfElse", "LinearAlgebra", "Requires", "SparseArrays", "Static"]
git-tree-sha1 = "265b06e2b1f6a216e0e8f183d28e4d354eab3220"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "3.2.1"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[BerkeleyDB_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "OpenSSL_jll", "Pkg"]
git-tree-sha1 = "f48d60e42490ce5516a52b2963254a4732ba9942"
uuid = "cd00e070-8fe2-570d-8212-aefc8f89bd06"
version = "18.1.40+0"

[[BlueZ_jll]]
deps = ["Artifacts", "Dbus_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libical_jll", "Pkg", "Readline_jll", "eudev_jll"]
git-tree-sha1 = "d4c413db1759fa113135800ff2993ee01206126b"
uuid = "471b5b61-da80-5748-8755-67d5084d21f2"
version = "5.54.0+1"

[[Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "d711603452231bad418bd5e0c91f1abd650cba71"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.11.3"

[[ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "bf98fa45a0a4cee295de98d4c1462be26345b9a1"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.2"

[[Check_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b5d7d180125b8d0f24bc4196f7fd53b7a0f48ea9"
uuid = "491db154-c145-5abe-9c32-446728d60cce"
version = "0.15.2+0"

[[ColorSchemes]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "a851fec56cb73cfdf43762999ec72eff5b86882a"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.15.0"

[[ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "44c37b4636bc54afac5c574d2d02b625349d6582"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.41.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[Conda]]
deps = ["Downloads", "JSON", "VersionParsing"]
git-tree-sha1 = "6cdc8832ba11c7695f494c9d9a1c31e90959ce0f"
uuid = "8f4d0f93-b110-5947-807f-2305c1781a2d"
version = "1.6.0"

[[ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f74e9d5388b8620b4cee35d4c5a618dd4dc547f4"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.3.0"

[[Contour]]
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

[[Crayons]]
git-tree-sha1 = "3f71217b538d7aaee0b69ab47d9b7724ca8afa0d"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.0.4"

[[DSP]]
deps = ["FFTW", "IterTools", "LinearAlgebra", "Polynomials", "Random", "Reexport", "SpecialFunctions", "Statistics"]
git-tree-sha1 = "2a63cb5fc0e8c1f0f139475ef94228c7441dc7d0"
uuid = "717857b8-e6f2-59f4-9121-6e50c889abd2"
version = "0.6.10"

[[DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "3daef5523dd2e769dad2365274f760ff5f282c7d"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.11"

[[DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[Dbus_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "97f1325c10bd02b1cc1882e9c2bf6407ba630ace"
uuid = "ee1fde0b-3d02-5ea6-8484-8dfef6360eab"
version = "1.12.16+3"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3f3a2501fa7236e9b911e0f7a588c657e822bb6d"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.3+0"

[[Elfutils_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "XZ_jll", "Zlib_jll", "argp_standalone_jll", "fts_jll", "obstack_jll"]
git-tree-sha1 = "8f9fcde6d89b0a3ca51cb2028beab462705c5436"
uuid = "ab5a07f8-06af-567f-a878-e8bb879eba5a"
version = "0.182.0+0"

[[EllipsisNotation]]
deps = ["ArrayInterface"]
git-tree-sha1 = "3fe985505b4b667e1ae303c9ca64d181f09d5c05"
uuid = "da5c29d0-fa7d-589e-88eb-ea29b0a81949"
version = "1.1.3"

[[Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b3bfd02e98aedfa5cf885665493c5598c350cd2f"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.2.10+0"

[[ExprTools]]
git-tree-sha1 = "b7e3d17636b348f005f11040025ae8c6f645fe92"
uuid = "e2ba6199-217a-4e67-a87a-7c52f15ade04"
version = "0.1.6"

[[FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "Pkg", "Zlib_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "d8a578692e3077ac998b50c0217dfd67f21d1e5f"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.0+0"

[[FFTW]]
deps = ["AbstractFFTs", "FFTW_jll", "LinearAlgebra", "MKL_jll", "Preferences", "Reexport"]
git-tree-sha1 = "463cb335fa22c4ebacfd1faba5fde14edb80d96c"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.4.5"

[[FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c6033cc3892d0ef5bb9cd29b7f2f0331ea5184ea"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.10+0"

[[FLAC_jll]]
deps = ["Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "cd528d5083a589aab69dc6de73a901efa9d69586"
uuid = "1d38b3a6-207b-531b-80e8-c83f48dafa73"
version = "1.3.3+2"

[[FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "2db648b6712831ecb333eae76dbfd1c156ca13bb"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.11.2"

[[FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "0c603255764a1fa0b61752d2bec14cfbd18f7fe8"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.5+1"

[[GMP_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "781609d7-10c4-51f6-84f2-b8444358ff6d"

[[GR]]
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Printf", "Random", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "b9a93bcdf34618031891ee56aad94cfff0843753"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.63.0"

[[GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "f97acd98255568c3c9b416c5a3cf246c1315771b"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.63.0+0"

[[GSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9a6d2b6c33aa7061654d2f1b31d9f7e1c2bd2dbc"
uuid = "1b77fbbe-d8ee-58f0-85f9-836ddc23a7a4"
version = "2.7.1+0"

[[GStreamer_jll]]
deps = ["Artifacts", "Elfutils_jll", "GMP_jll", "GSL_jll", "Glib_jll", "JLLWrappers", "LibUnwind_jll", "Libdl", "Pkg", "libcap_jll"]
git-tree-sha1 = "a1d35530fb854beac4efa219c1987fb99fd3ff77"
uuid = "aaaaf01e-2457-52c6-9fe8-886f7267d736"
version = "1.18.3+0"

[[Gdbm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Readline_jll"]
git-tree-sha1 = "0f2a7b90790988ed644f28ae0e1d9069b1f345f4"
uuid = "54ca2031-c8dd-5cab-9ed4-295edde1660f"
version = "1.18.1+1"

[[GeometryBasics]]
deps = ["EarCut_jll", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "58bcdf5ebc057b085e58d95c138725628dd7453c"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.1"

[[Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "a32d672ac2c967f3deb8a81d828afc739c838a06"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.68.3+2"

[[Glob]]
git-tree-sha1 = "4df9f7e06108728ebf00a0a11edee4b29a482bb2"
uuid = "c27321d9-0574-5035-807b-f59d2c89b15c"
version = "1.3.0"

[[Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[HTTP]]
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "0fa77022fe4b511826b39c894c90daf5fce3334a"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.17"

[[HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[HypertextLiteral]]
git-tree-sha1 = "2b078b5a615c6c0396c77810d92ee8c6f470d238"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.3"

[[ICU_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6b1e49820922eca7bfc862442da6e54173a075b4"
uuid = "a51ab1cf-af8e-5615-a023-bc2c838bba6b"
version = "68.2.0+0"

[[IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[IfElse]]
git-tree-sha1 = "debdd00ffef04665ccbb3e150747a77560e8fad1"
uuid = "615f187c-cbe4-4ef1-ba3b-2fcf58d6d173"
version = "0.1.1"

[[IniFile]]
deps = ["Test"]
git-tree-sha1 = "098e4d2c533924c921f9f9847274f2ad89e018b8"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.0"

[[InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "8d70835a3759cdd75881426fced1508bb7b7e1b6"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.1.1"

[[IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d979e54b71da82f3a65b62553da4fc3d18c9004c"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2018.0.3+2"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[IntervalSets]]
deps = ["Dates", "EllipsisNotation", "Statistics"]
git-tree-sha1 = "3cc368af3f110a767ac786560045dceddfc16758"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.5.3"

[[Intervals]]
deps = ["Dates", "Printf", "RecipesBase", "Serialization", "TimeZones"]
git-tree-sha1 = "323a38ed1952d30586d0fe03412cde9399d3618b"
uuid = "d8418881-c3e1-53bb-8760-2df7ec849ed5"
version = "1.5.0"

[[InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "a7254c0acd8e62f1ac75ad24d5db43f5f19f3c65"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.2"

[[IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[IterTools]]
git-tree-sha1 = "fa6287a4469f5e048d763df38279ee729fbd44e5"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.4.0"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "642a199af8b68253517b80bd3bfd17eb4e84df6e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.3.0"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d735490ac75c5cb9f1b00d8b5509c11984dc6943"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.0+0"

[[LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "Printf", "Requires"]
git-tree-sha1 = "a8f4f279b6fa3c3c4f1adadd78a621b13a506bce"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.9"

[[LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[LibSndFile]]
deps = ["FileIO", "Libdl", "LinearAlgebra", "Printf", "SampledSignals", "libsndfile_jll"]
git-tree-sha1 = "955515227165d2a276abb017bafd0b4e93d0eded"
uuid = "b13ce0c6-77b0-50c6-a2db-140568b8d1a5"
version = "2.4.0"

[[LibUnwind_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "745a5e78-f969-53e9-954f-d19f2f74f4e3"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "7739f837d6447403596a75d19ed01fd08d6f56bf"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.3.0+3"

[[Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[Libical_jll]]
deps = ["Artifacts", "BerkeleyDB_jll", "Glib_jll", "ICU_jll", "JLLWrappers", "Libdl", "Pkg", "XML2_jll"]
git-tree-sha1 = "c61ffd9e8faf24c19a88f369f1966d53967824d1"
uuid = "bce108ef-3f60-5dd0-bcd6-e13a096cb796"
version = "3.0.9+0"

[[Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "340e257aada13f95f98ee352d316c3bed37c8ab9"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.3.0+0"

[[Libtool_jll]]
deps = ["Libdl", "Pkg"]
git-tree-sha1 = "e5651a50cdb27262ad368cded3130f11edbfc9de"
uuid = "a76c16ae-fb8f-5ff0-8826-da3b7a640f0b"
version = "2.4.6+0"

[[Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "e5718a00af0ab9756305a0392832c8952c7426c1"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.6"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "5455aef09b40e5020e1520f551fa3135040d4ed0"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2021.1.1+2"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "3d3e902b31198a27340d0bf00d6ac452866021cf"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.9"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "Random", "Sockets"]
git-tree-sha1 = "1c38e51c3d08ef2278062ebceade0e46cefc96fe"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.0.3"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Measures]]
git-tree-sha1 = "e498ddeee6f9fdb4551ce855a46f54dbd900245f"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.1"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[Mocking]]
deps = ["Compat", "ExprTools"]
git-tree-sha1 = "29714d0a7a8083bba8427a4fbfb00a540c681ce7"
uuid = "78c3b35d-d492-501b-9361-3d52fe80e533"
version = "0.7.3"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NaNMath]]
git-tree-sha1 = "f755f36b19a5116bb580de457cda0c140153f283"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.6"

[[Ncurses_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e3fb71f3c971fdc8523f9ef3906691124f3048a2"
uuid = "68e3532b-a499-55ff-9963-d1c0c0748b3a"
version = "6.2.0+0"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "043017e0bdeff61cfbb7afeb558ab29536bbb5ed"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.10.8"

[[Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7937eda4681660b4d6aeeecc2f7e1c81c8ee4e2f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+0"

[[OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"

[[OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "15003dcb7d8db3c6c857fda14891a539a8f2705a"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.10+0"

[[OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[PCRE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b2a7af664e098055a7529ad1a900ded962bca488"
uuid = "2f80f16e-611a-54ab-bc61-aa92de5b98fc"
version = "8.44.0+0"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "d7fa6237da8004be601e19bd6666083056649918"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.1.3"

[[Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PlotThemes]]
deps = ["PlotUtils", "Requires", "Statistics"]
git-tree-sha1 = "a3a964ce9dc7898193536002a6dd892b1b5a6f1d"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "2.0.1"

[[PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "68604313ed59f0408313228ba09e79252e4b2da8"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.1.2"

[[Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "GeometryBasics", "JSON", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "71d65e9242935132e71c4fbf084451579491166a"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.25.4"

[[PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "fed057115644d04fba7f4d768faeeeff6ad11a60"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.27"

[[Polynomials]]
deps = ["Intervals", "LinearAlgebra", "OffsetArrays", "RecipesBase"]
git-tree-sha1 = "0b15f3597b01eb76764dd03c3c23d6679a3c32c8"
uuid = "f27b6e38-b328-58d1-80ce-0feddd5e7a45"
version = "1.2.1"

[[PortAudio]]
deps = ["LinearAlgebra", "SampledSignals", "Suppressor", "alsa_plugins_jll", "libportaudio_jll"]
git-tree-sha1 = "52e590ceebf17a8ef1b51a0cbe0fd54c9678878a"
uuid = "80ea8bcb-4634-5cb3-8ee8-a132660d1d2d"
version = "1.1.2"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "2cf929d64681236a2e074ffafb8d568733d2e6af"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.3"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[PulseAudio_jll]]
deps = ["Artifacts", "BlueZ_jll", "Check_jll", "Dbus_jll", "FFTW_jll", "GStreamer_jll", "Gdbm_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Libtool_jll", "OpenSSL_jll", "Pkg", "SBC_jll", "SoXResampler_jll", "SpeexDSP_jll", "alsa_jll", "eudev_jll", "libasyncns_jll", "libcap_jll", "libsndfile_jll"]
git-tree-sha1 = "6554e7e66f37a699c2f53d9d6622969272b90408"
uuid = "02771fc1-bdb7-5db5-8d11-300768e00fbd"
version = "15.0.0+0"

[[PyCall]]
deps = ["Conda", "Dates", "Libdl", "LinearAlgebra", "MacroTools", "Serialization", "VersionParsing"]
git-tree-sha1 = "71fd4022ecd0c6d20180e23ff1b3e05a143959c2"
uuid = "438e738f-606a-5dbb-bf0a-cddfbfd45ab0"
version = "1.93.0"

[[Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "ad368663a5e20dbb8d6dc2fddeefe4dae0781ae8"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+0"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Readline_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ncurses_jll", "Pkg"]
git-tree-sha1 = "7cfd44e2889fcabf8ee80dad89bccb3756d4e778"
uuid = "05236dd9-4125-5232-aa7c-9ec0c9b2c25a"
version = "8.1.1+1"

[[RecipesBase]]
git-tree-sha1 = "6bf3f380ff52ce0832ddd3a2a7b9538ed1bcca7d"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.2.1"

[[RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase"]
git-tree-sha1 = "7ad0dfa8d03b7bcf8c597f59f5292801730c55b8"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.4.1"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "8f82019e525f4d5c669692772a6f4b0a58b06a6a"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.2.0"

[[SBC_jll]]
deps = ["Libdl", "Pkg", "libsndfile_jll"]
git-tree-sha1 = "34755bff50b6b08988cdfe5fee69c1c1b24ff810"
uuid = "da37f231-8920-5702-a09a-bdd970cb6ddc"
version = "1.4.0+0"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[SampledSignals]]
deps = ["Base64", "Compat", "DSP", "FFTW", "FixedPointNumbers", "IntervalSets", "LinearAlgebra", "Random", "TreeViews", "Unitful"]
git-tree-sha1 = "4b7e413f20fa56fa47b8433c96f96a1acfe372a6"
uuid = "bd7594eb-a658-542f-9e75-4c4d8908c167"
version = "2.1.2"

[[Scratch]]
deps = ["Dates"]
git-tree-sha1 = "0b4b7f1393cff97c33891da2a0bf69c6ed241fda"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.0"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[SoXResampler_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "a95ff1842456719a727e23fe28712eb26f7818b8"
uuid = "fbe68eb6-6641-54c6-99e3-f7c7c4d73a57"
version = "0.1.3+0"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "f0bccf98e16759818ffc5d97ac3ebf87eb950150"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "1.8.1"

[[SpeexDSP_jll]]
deps = ["Libdl", "Pkg"]
git-tree-sha1 = "ecc65cb4a4e77f624deae8d881787c789af6deaf"
uuid = "f2f9631b-9a4e-5b48-9975-88f638ec36a7"
version = "1.2.0+0"

[[Static]]
deps = ["IfElse"]
git-tree-sha1 = "7f5a513baec6f122401abfc8e9c074fdac54f6c1"
uuid = "aedffcd0-7271-4cad-89d0-dc628f76c6d3"
version = "0.4.1"

[[StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "3c76dde64d03699e074ac02eb2e8ba8254d428da"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.2.13"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StatsAPI]]
git-tree-sha1 = "d88665adc9bcf45903013af0982e2fd05ae3d0a6"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.2.0"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "51383f2d367eb3b444c961d485c565e4c0cf4ba0"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.14"

[[StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "2ce41e0d042c60ecd131e9fb7154a3bfadbf50d3"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.3"

[[Suppressor]]
git-tree-sha1 = "a819d77f31f83e5792a76081eee1ea6342ab8787"
uuid = "fd094767-a336-5f1f-9728-57cf17d0bbfb"
version = "0.2.0"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "bb1064c9a84c52e277f1096cf41434b675cd368b"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.6.1"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[TimeZones]]
deps = ["Dates", "Downloads", "InlineStrings", "LazyArtifacts", "Mocking", "Printf", "RecipesBase", "Serialization", "Unicode"]
git-tree-sha1 = "ce5aab0b0146b81efefae52f13002e19c2af57ac"
uuid = "f269a46b-ccf7-5d73-abea-4c690281aa53"
version = "1.7.0"

[[TreeViews]]
deps = ["Test"]
git-tree-sha1 = "8d0d7a3fe2f30d6a7f833a5f19f7c7a5b396eae6"
uuid = "a2a6695c-b41b-5b7d-aed9-dbfdeacea5d7"
version = "0.3.0"

[[URIs]]
git-tree-sha1 = "97bbe755a53fe859669cd907f2d96aee8d2c1355"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.3.0"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[UnicodePlots]]
deps = ["Crayons", "Dates", "SparseArrays", "StatsBase"]
git-tree-sha1 = "3cb994143aba28cfe66615702505b2d294cebd3e"
uuid = "b8865327-cd53-5732-bb35-84acbb429228"
version = "2.5.1"

[[Unitful]]
deps = ["ConstructionBase", "Dates", "LinearAlgebra", "Random"]
git-tree-sha1 = "09b3c3eb6767521346b3716e461ddfb3ebe88293"
uuid = "1986cc42-f94f-5a68-af5c-568840ba703d"
version = "1.10.0"

[[Unzip]]
git-tree-sha1 = "34db80951901073501137bdbc3d5a8e7bbd06670"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.1.2"

[[VersionParsing]]
git-tree-sha1 = "e575cf85535c7c3292b4d89d89cc29e8c3098e47"
uuid = "81def892-9a0e-5fdd-b105-ffc91e053289"
version = "1.2.1"

[[WAV]]
deps = ["Base64", "FileIO", "Libdl", "Logging"]
git-tree-sha1 = "7e7e1b4686995aaf4ecaaf52f6cd824fa6bd6aa5"
uuid = "8149f6b0-98f6-5db9-b78f-408fbbb8ef88"
version = "1.2.0"

[[Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "3e61f0b86f90dacb0bc0e73a0c5a83f6a8636e23"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.19.0+0"

[[Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "66d72dc6fcc86352f01676e8f0f698562e60510f"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.23.0+0"

[[XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "1acf5bdf07aa0907e0a37d3718bb88d4b687b74a"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.12+0"

[[XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[XZ_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "a921669cd9a45c23031fd4eb904f5cc3d20de415"
uuid = "ffd25f8a-64ca-5728-b0f7-c24cf3aae800"
version = "5.2.5+2"

[[Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "926af861744212db0eb001d9e40b5d16292080b2"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.0+4"

[[Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "4bcbf660f6c2e714f87e960a171b119d06ee163b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.2+4"

[[Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "5c8424f8a67c3f2209646d4425f3d415fee5931d"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.27.0+4"

[[Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "cc4bf3fdde8b7e3e9fa0351bdeedba1cf3b7f6e6"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.0+0"

[[alsa_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "69859a01e7735ce5b49b1328827f6e3f4cdd7d19"
uuid = "45378030-f8ea-5b20-a7c7-1a9d95efb90e"
version = "1.2.5+0"

[[alsa_plugins_jll]]
deps = ["Artifacts", "FFMPEG_jll", "JLLWrappers", "Libdl", "Pkg", "PulseAudio_jll", "alsa_jll", "libsamplerate_jll"]
git-tree-sha1 = "a43b5bcdfadfbe06c42cd6b007572c4806f2c0f7"
uuid = "5ac2f6bb-493e-5871-9171-112d4c21a6e7"
version = "1.2.2+0"

[[argp_standalone_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "feaf9f6293003c2bf53056fd6930d677ed340b34"
uuid = "c53206cc-00f7-50bf-ad1e-3ae1f6e49bc3"
version = "1.3.1+0"

[[eudev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "gperf_jll"]
git-tree-sha1 = "431b678a28ebb559d224c0b6b6d01afce87c51ba"
uuid = "35ca27e7-8b34-5b7f-bca9-bdc33f59eb06"
version = "3.2.9+0"

[[fts_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "78732b942383d2cb521df8a1a0814911144e663d"
uuid = "d65627f6-89bd-53e8-8ab5-8b75ff535eee"
version = "1.2.7+1"

[[gperf_jll]]
deps = ["Libdl", "Pkg"]
git-tree-sha1 = "9a7e727603ef936433110ee68b78dcdc3576ee79"
uuid = "1a1c6b14-54f6-533d-8383-74cd7377aa70"
version = "3.1.0+0"

[[libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[libasyncns_jll]]
deps = ["Libdl", "Pkg"]
git-tree-sha1 = "38a54b0ebad9bc225a38106ff66b7827fac5bd9e"
uuid = "ed080073-db63-57db-a029-74e11ae80737"
version = "0.8.0+0"

[[libcap_jll]]
deps = ["Libdl", "Pkg"]
git-tree-sha1 = "c6816cb55afe6639d776f438a74193f5694268c6"
uuid = "eef66a8b-8d7a-5724-a8d2-7c31ae1e29ed"
version = "2.27.0+0"

[[libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[libportaudio_jll]]
deps = ["Libdl", "Pkg", "alsa_jll"]
git-tree-sha1 = "7a5bcc2dcdce9ff8565768761ab3331a8a73b104"
uuid = "2d7b7beb-0762-5160-978e-1ab83a1e8a31"
version = "19.6.0+2"

[[libsamplerate_jll]]
deps = ["Libdl", "Pkg"]
git-tree-sha1 = "45ba80d9b0a208fd5165d159d93a3725fab0d76b"
uuid = "9427e74d-4e05-59c1-8ff3-7d74b6e52ac8"
version = "0.1.9+0"

[[libsndfile_jll]]
deps = ["Artifacts", "FLAC_jll", "JLLWrappers", "Libdl", "Ogg_jll", "Opus_jll", "Pkg", "alsa_jll", "libvorbis_jll"]
git-tree-sha1 = "80b4b0e934900ae0e967fb1e841f1bb7f8a264a8"
uuid = "5bf562c0-5a39-5b4f-b979-f64ac885830c"
version = "1.0.31+1"

[[libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "c45f4e40e7aafe9d086379e5578947ec8b95a8fb"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+0"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[obstack_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "1c4a6b66e934fc6db4649cb2910c72f53bbfea7e"
uuid = "c88a4935-d25e-5644-aacc-5db6f1b8ef79"
version = "1.2.2+0"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"

[[x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "ece2350174195bb31de1a63bea3a41ae1aa593b6"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "0.9.1+5"
"""

# ╔═╡ Cell order:
# ╟─731b6d2f-99f2-47d1-a145-c8f36b742fc2
# ╠═2edd755e-6973-11ec-27c6-4f0531f047a0
# ╠═4b6fbff4-7239-4501-b070-529460a54ed9
# ╟─a00b47a5-2757-4d55-9781-8ef06bf65211
# ╟─2d308cf3-6f29-4696-8ef2-043c61723af9
# ╠═aef4ccd9-9382-438f-9ff7-144a11b62200
# ╠═12d9ed29-26f8-4c26-92f5-ec1ef087f5a9
# ╠═8bd55615-9aaf-4839-91ff-bb71d58da589
# ╟─86ce8edc-842e-474e-8142-c9e1d4a6470d
# ╠═ccd3ef9e-b5f7-4e29-9b3a-12d9b1e62dc4
# ╠═73ce2a7c-d4d8-450f-95d3-f9da0e361808
# ╠═954c097e-7ee5-4de4-ad0f-6ab3f204d357
# ╠═bba5212d-abfe-4aab-a270-0a60cff0f305
# ╠═128105e4-0a32-4c61-b285-ac11af8f9bec
# ╠═bcc7a1d1-59e0-413f-831d-6132bb0158e7
# ╠═b73c4181-858f-42cc-ad44-140406eb9231
# ╟─3235909b-9f5c-4a52-971e-979aa0a7b0fc
# ╠═3bb905f4-5fba-4327-8d80-fa625f8501ab
# ╠═75d09f1c-ed03-45fc-b107-b403f71c5cff
# ╠═cbd0ac62-125f-419f-9458-33f76768ae36
# ╠═90e79652-438f-4796-a10e-713b68fca189
# ╠═89ebc526-8e5d-465b-817b-87c3d49d6472
# ╠═d87cfc7d-b17d-4925-b7b9-7f95d56fff14
# ╠═225030d2-e2fc-497d-96ba-1ba0b6153567
# ╟─71b0e49a-f96d-463e-bc73-37b7e5fa79cd
# ╠═00e1e3df-8f51-4e66-b73f-0e0caa2da0e1
# ╟─1daba4c9-78d4-4030-918e-62e29f473f1a
# ╟─093e2227-72e5-4111-916b-60565c83be1e
# ╟─6ab497d8-8f9d-4a1a-b7d9-c0c0e48d38e6
# ╠═e1ea44a9-7af8-47b3-8970-551e021bcb0b
# ╠═00ec9153-045c-4e88-af10-d615a6a55603
# ╟─785367e4-b839-4123-afe8-91c6e681512a
# ╟─926b3aa7-69ae-45f8-9a98-95b3bf8425d0
# ╟─f954b047-0191-4bf6-8542-79ee28a0e5b2
# ╠═5f36b4b3-b071-49e0-8160-ad3d4945756f
# ╟─c5231ebd-33a7-4bb5-a94c-c961f23f4823
# ╟─d1430b88-0dbe-41e3-a362-d37889e436e7
# ╟─c841ce52-a946-4d9d-82c7-c4349f22a46e
# ╠═a3370c94-3806-4f25-8d11-c159b1317586
# ╟─ae8cc93e-3e4e-4b95-8758-f982f9d2e573
# ╠═bdeeadfa-0ee0-41c7-acdf-c31a1c63eb0b
# ╠═4f8d137d-3b42-4496-83c7-7edca075a422
# ╠═ccdc4295-432c-4c96-b5c7-82b5d13d892d
# ╟─c558365b-8207-440b-9cc0-4d4eb86ef9df
# ╠═777be32e-f5c2-4817-b921-5864613494a7
# ╟─26f03e01-9bbc-43b1-8b69-4c0c1d144843
# ╠═2edd7540-6973-11ec-1a21-273536e0bc2c
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
