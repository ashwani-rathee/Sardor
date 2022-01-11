### A Pluto.jl notebook ###
# v0.14.5

using Markdown
using InteractiveUtils

# ╔═╡ 8bc61658-b880-11eb-0b6c-a5b7ff4dcf3e
using SampledSignals

# ╔═╡ 821a6565-7046-46ff-b874-521fd846d703
using WAV

# ╔═╡ 06853df6-44a0-42cb-8e5a-95bbc8962b81
using Base, UnicodePlots

# ╔═╡ aa8e6100-5919-461a-8394-dea283f15b00
using Unitful

# ╔═╡ bc1888ec-9c33-45e7-91cb-4a7024f1acd7
begin
	
# some examples using signal operators
using SignalOperators

# a pure tone 20 dB below a power 1 signal, with on and off ramps (for
# a smooth onset/offset)
sound1 = Signal(sin,ω=1kHz) |> Until(5s) |> Ramp |> Normpower |> Amplify(-20dB)

# a sound defined by a file, matching the overall power to that of sound1
sound2 = "example.wav" |> Normpower |> Amplify(-20dB)

# a 1kHz sawtooth wave
sound3 = Signal(ϕ -> ϕ-π,ω=1kHz) |> Ramp |> Normpower |> Amplify(-20dB)

# a 5 Hz amplitude modulated noise
sound4 = randn |>
    Amplify(Signal(ϕ -> 0.5sin(ϕ) + 0.5,ω=5Hz)) |>
    Until(5s) |> Normpower |> Amplify(-20dB)

# a 1kHz tone surrounded by a notch noise
SNR = 5dB
x = Signal(sin,ω=1kHz) |> Until(1s) |> Ramp |> Normpower |> Amplify(-20dB + SNR)
z = Signal(randn) |> Until(1s) |> Filt(Bandstop,0.5kHz,2kHz) |> Normpower |> Amplify(-20dB)
scene = Mix(x,z)

# # write all of the signals to a single file, at 44.1 kHz
# Append(sound1,sound2,sound3,sound4,scene) |> ToFramerate(44.1kHz) |> sink("examples.wav")
end

# ╔═╡ 770f4a6b-2fe3-4493-a324-08a54131ea88
md"""
# Oscillators 
It is the most important component of a synthesizer, it is a component that
that generates a sequence of numbers that repeats after a certain interval.

The most simplest oscillator is one that produces which is generated by 
unsurprisingly yet delightfully, the sine function. 

https://www.reddit.com/r/Python/comments/lw50ne/making_a_synthesizer_using_python/
https://python.plainenglish.io/making-a-synth-with-python-oscillators-2cb8e68e9c3b
"""

# ╔═╡ fe3abf37-bcad-4717-9ebd-702838c5ccbf
begin    # Example audio
    audio_one_channel = SampleBuf(rand(100000), 10000)
    audio_two_channel = SampleBuf(rand(100000,2), 10000)
    audio_multi_channel = SampleBuf(rand(100000,2), 10000)
end

# ╔═╡ 961a4dfa-0cbb-46aa-8af1-a056ade120ad
function get_sin_oscillator(freq=1, sample_rate=512)
	increment = ( 2 * pi * freq) / sample_rate
	return(sin(v) for v in Iterators.countfrom(0, increment))
end

# ╔═╡ dfe31fdd-6be0-41cf-8fae-77c0e8692627
begin
osc =  get_sin_oscillator(1, 512)
samples = [osc for i in 1:512]
# samples = [next(osc,3) for i in 1:512]
end

# ╔═╡ d1890135-cbcf-4b23-a32c-418be77debc0
samples

# ╔═╡ ea2c8ea0-7f9d-4687-b657-21e4d2a0c253
sizeof(osc)

# ╔═╡ 764cb127-bcec-450f-8ed5-933e3bc1db6c
begin
	
# some examples from WaveForm.jl
squarewave(x::Real) = ifelse(mod2pi(x) < π, 1.0, -1.0)

md"""
    squarewave(x, θ)
Compute ``2\pi``-periodic square wave of `x` with a duty cycle `θ`
and a peak amplitude ``1``.
"""
function squarewave(x::Real, θ::Real)
    0 ≤ θ ≤ 1 || throw(DomainError(θ, "squwarewave(x, θ) is only defined for 0 ≤ θ ≤ 1."))
    ifelse(mod2pi(x) < 2π * θ, 1.0, -1.0)
end

md"""
    squarewave1(x)
Compute ``1``-periodic square wave of `x` with a peak amplitude ``1``.
"""
squarewave1(x::Real) = ifelse(mod(x, 1) < 1/2, 1.0, -1.0)

md"""
    squarewave1(x, θ)
Compute ``1``-periodic square wave of `x` with a duty cycle `θ`
and a peak amplitude ``1``.
"""
function squarewave1(x::Real, θ::Real)
    0 ≤ θ ≤ 1 || throw(DomainError(θ, "squwarewave1(x, θ) is only defined for 0 ≤ θ ≤ 1."))
    ifelse(mod(x, 1) < θ, 1.0, -1.0)
end

md"""
    trianglewave(x)
Compute ``2\pi``-periodic triangle wave of `x` with a peak amplitude ``1``.
"""
function trianglewave(x::Real)
    modx = mod2pi(x + π/2)
    ifelse(modx < π, 2modx/π - 1, -2modx/π + 3)
end

md"""
    trianglewave1(x)
Compute ``1``-periodic triangle wave of `x` with a peak amplitude ``1``.
"""
function trianglewave1(x::Real)
    modx = mod(x + 1/4, 1.0)
    ifelse(modx < 1/2, 4modx - 1, -4modx + 3)
end

md"""
    sawtoothwave(x)
Compute ``2\pi``-periodic sawtooth wave of `x` with a peak amplitude ``1``.
"""
sawtoothwave(x::Real) = rem2pi(x, RoundNearest) / π

md"""
    sawtoothwave1(x)
Compute ``1``-periodic sawtooth wave of `x` with a peak amplitude ``1``.
"""
sawtoothwave1(x::Real) = rem(x, 1.0, RoundNearest) * 2

end

# ╔═╡ 29ef8525-5c0e-4dfd-8313-c3232ae362ab
squarewave(1)

# ╔═╡ a98ee93f-aac1-4b80-b337-f96f17744561
lineplot([squarewave], -π/2, 2π)

# ╔═╡ 466a36e8-c298-4ff9-ae0a-87c92905cf2a
lineplot([sawtoothwave], -π/2, 2π)

# ╔═╡ 3122c57a-f46f-49d7-9770-b51b1347b8f9
lineplot([trianglewave], -π/2, 2π)

# ╔═╡ 11b6cb26-da27-4222-94fe-40ef41f1c954
  audio_multi1_channel = SampleBuf(rand(100000,2), 10000)

# ╔═╡ acde3a7e-b314-4e3d-96d7-81b63821e060
typeof(SampleBuf(rand(100000,2), 10000))

# ╔═╡ 1dd3020a-9d13-4ab5-9967-14644d72f6df
audio_multi1_channel.data

# ╔═╡ 7f0b5cd9-24c7-4c40-a62c-0d2e909c1ae9
# Using Dan Casmiro WAV.jl
begin
fs = 8e3
t = 0.0:1/fs:prevfloat(1.0)
f = 1e3
y = sin.(2pi * f * t) * 0.1
wavwrite(y, "example.wav", Fs=fs)

y, fs = wavread("example.wav")
y = sin.(2pi * 2f * t) * 0.1
wavappend(y, "example.wav")

y, fs = wavread("example.wav")
wavplay(y, fs)
end

# ╔═╡ e7a0111f-1df0-4a36-8a24-d68c059b8cad
begin
nsamples = []
for i in 0:1/10000:10
	push!(nsamples, sinpi(f * i))
end
end

# ╔═╡ 3b19dcd5-37ef-4676-924b-e0b0778b1dd5
nsamples1 = hcat(nsamples, nsamples)

# ╔═╡ 4ff67c7e-73c8-4cfa-91a0-392ab3af2318
# using sampledsignals
audio_samples = SampleBuf(nsamples1, 10000)

# ╔═╡ 9b3bbcb7-544c-43b6-957a-495291525736
# using wavplay
wavplay(audio_samples.data,10000)

# ╔═╡ b92e9a63-f08e-47fe-baab-f5cc309bcdbc
# using SignalOperators.Units # allows the use of dB, Hz, s etc... as unitful values

# ╔═╡ b271de0b-3566-4712-bcdc-06a66f6f0b86
sound1

# ╔═╡ Cell order:
# ╠═8bc61658-b880-11eb-0b6c-a5b7ff4dcf3e
# ╠═821a6565-7046-46ff-b874-521fd846d703
# ╠═06853df6-44a0-42cb-8e5a-95bbc8962b81
# ╠═770f4a6b-2fe3-4493-a324-08a54131ea88
# ╠═fe3abf37-bcad-4717-9ebd-702838c5ccbf
# ╠═961a4dfa-0cbb-46aa-8af1-a056ade120ad
# ╠═dfe31fdd-6be0-41cf-8fae-77c0e8692627
# ╠═d1890135-cbcf-4b23-a32c-418be77debc0
# ╠═ea2c8ea0-7f9d-4687-b657-21e4d2a0c253
# ╠═764cb127-bcec-450f-8ed5-933e3bc1db6c
# ╠═29ef8525-5c0e-4dfd-8313-c3232ae362ab
# ╠═a98ee93f-aac1-4b80-b337-f96f17744561
# ╠═466a36e8-c298-4ff9-ae0a-87c92905cf2a
# ╠═3122c57a-f46f-49d7-9770-b51b1347b8f9
# ╠═e7a0111f-1df0-4a36-8a24-d68c059b8cad
# ╠═3b19dcd5-37ef-4676-924b-e0b0778b1dd5
# ╠═9b3bbcb7-544c-43b6-957a-495291525736
# ╠═4ff67c7e-73c8-4cfa-91a0-392ab3af2318
# ╠═11b6cb26-da27-4222-94fe-40ef41f1c954
# ╠═acde3a7e-b314-4e3d-96d7-81b63821e060
# ╠═1dd3020a-9d13-4ab5-9967-14644d72f6df
# ╠═7f0b5cd9-24c7-4c40-a62c-0d2e909c1ae9
# ╠═b92e9a63-f08e-47fe-baab-f5cc309bcdbc
# ╠═aa8e6100-5919-461a-8394-dea283f15b00
# ╠═bc1888ec-9c33-45e7-91cb-4a7024f1acd7
# ╠═b271de0b-3566-4712-bcdc-06a66f6f0b86