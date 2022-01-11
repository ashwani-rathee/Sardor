### A Pluto.jl notebook ###
# v0.14.5

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ fb56c064-b90d-11eb-124f-bd2478c9a5bf
using WAV, SampledSignals, Plots,PlutoUI

# ╔═╡ 56d13e40-49bc-4f45-9033-0a4003070da8
using UnicodePlots

# ╔═╡ a6fcf1e7-e477-41d3-b33a-08f521db740c
@bind a Slider(1:10)

# ╔═╡ 6813d955-d54d-47ac-8cec-5be4ea1847fe
begin
# a =  1   # Amplitude
f = 1# Frequency # in hz # No of oscillations of medium particles per unit time
t = 1/f   # Time Period
l = 100   # WaveLength
w = 2*pi*f # omega
v = f * l # Velocity
k = 1 # 2* pi / l # Wave number
padiff = 10
phdiff = k * padiff # phase difference
padiff = phdiff / k # path difference
phdiff = 10
m = 100 # mass I think
# e = 1/2 * (m * (w * a)^2) # energy of wave
fs = 8000 # sample rate
i = 0.0:1/fs:prevfloat(1.0)
alpha = pi # alpha
	
end

# ╔═╡ c5413acd-7828-4da0-9009-65fd61264637
begin
	
# some examples from WaveForm.jl
squarewave(x::Real) = ifelse(mod2pi(x) < π, 1.0, -1.0)
 
#Compute ``2\pi``-periodic square wave of `x` with a duty cycle `θ`and a peak amplitude ``1``.

function squarewave(x::Real, θ::Real)
    0 ≤ θ ≤ 1 || throw(DomainError(θ, "squwarewave(x, θ) is only defined for 0 ≤ θ ≤ 1."))
    ifelse(mod2pi(x) < 2π * θ, 1.0, -1.0)
end

#Compute ``1``-periodic square wave of `x` with a peak amplitude ``1``.
squarewave1(x::Real) = ifelse(mod(x, 1) < 1/2, 1.0, -1.0)

# Compute ``1``-periodic square wave of `x` with a duty cycle `θ` and a peak amplitude ``1``.
function squarewave1(x::Real, θ::Real)
    0 ≤ θ ≤ 1 || throw(DomainError(θ, "squwarewave1(x, θ) is only defined for 0 ≤ θ ≤ 1."))
    ifelse(mod(x, 1) < θ, 1.0, -1.0)
end

#Compute ``2\pi``-periodic triangle wave of `x` with a peak amplitude ``1``.
function trianglewave(x::Real)
    modx = mod2pi(x + π/2)
    ifelse(modx < π, 2modx/π - 1, -2modx/π + 3)
end

#Compute ``1``-periodic triangle wave of `x` with a peak amplitude ``1``.
function trianglewave1(x::Real)
    modx = mod(x + 1/4, 1.0)
    ifelse(modx < 1/2, 4modx - 1, -4modx + 3)
end
#Compute ``2\pi``-periodic sawtooth wave of `x` with a peak amplitude ``1``.
sawtoothwave(x::Real) = rem2pi(x, RoundNearest) / π
#Compute ``1``-periodic sawtooth wave of `x` with a peak amplitude ``1``.
sawtoothwave1(x::Real) = rem(x, 1.0, RoundNearest) * 2
end

# ╔═╡ df0fbb6c-bad6-435d-a931-2a4cd9ea935c
begin

vpart = a*w*cos.(w*i .- k*phdiff .+alpha) #velocity of a particle
apart = -a*(w^2)*sin.(w*i .- k*phdiff .+alpha) #velocity of a particle
# y = a*sin(w*t-k*phdiff +alpha) # general equation
# y1 = a*sin(w*(i - phdiff/v)) # 1st Equation
# y2 = a*sin((2*pi/l)*(v*i-phdiff)) # 2nd Equation
# y3 = a*sin((2*pi)*(i/t - phdiff/l)) # different forms of same equation
	
wave = a*sin.(w*i .- k*phdiff .+alpha) 
wave1 = a*sin.(w*i .- k*phdiff .+alpha) + a*sin.(w*i .- k*phdiff .+alpha .+pi ) 
wave2 = a*sin.(w*i .- k*phdiff .+alpha) + a*sin.(w*i .- k*phdiff .+alpha .+pi ) .+ a*squarewave.(w*i .- k*phdiff .+alpha .+pi )
wave3 = a*squarewave.(w*i .- k*phdiff .+alpha .+pi )
# Wave Source # Lossless medium
# fs = 8e3
# t = 0.0:1/fs:prevfloat(1.0)
# f = 1e3
y = sin.(2pi * f * i) * 0.1
wavplay(y, fs)	
end

# ╔═╡ 683fa835-7339-4b7c-89fe-6511da652e2d
length(wave)

# ╔═╡ 17af4d9f-687a-48c8-9a68-10d9bb713187
lineplot(i, wave)

# ╔═╡ 263973d5-9d5c-427b-94cb-bd74073a7a29
lineplot(i, wave1)

# ╔═╡ 8c401e62-30b2-492d-a896-b0dceb2c8508
lineplot(i, wave2)

# ╔═╡ aa1d8f3a-09cd-4fee-b6a0-e959650b0faa
lineplot(i, wave3)

# ╔═╡ a5298c48-a277-4c1c-bb35-e129cb205df2
lineplot(i, y)

# ╔═╡ e4b55da5-2cba-46b0-a084-2ebbb93a31f9
# plot(i, y, seriestype = :scatter, title = "My Scatter Plot")

# ╔═╡ 5ffbc4bf-cc16-474e-8985-2ebb81dc821c
# plot(i, wave, seriestype = :scatter, title = "My Scatter Plot")

# ╔═╡ 3ee38394-fce7-456f-86f8-0f889b2c4f1a
# plot(i, wave1, seriestype = :scatter, title = "My Scatter Plot")

# ╔═╡ 37c49652-2500-4236-8ffb-0906ff0248e5
# plot(i, wave2, seriestype = :scatter, title = "My Scatter Plot")

# ╔═╡ 1df63790-0d76-4c41-aaf9-5cf39ec6cb98
@bind fs1 Slider(100:100:10000,default=8e3, show_value=true)

# ╔═╡ 446e0ba3-4c3a-4e15-b1a1-5a8046c02c3c
@bind f1 Slider(0:100:10000, default=1e3, show_value=true)

# ╔═╡ dd194f36-68c0-440b-86f8-9f3ec2a78647
begin
t1 = 0.0:1/fs1:prevfloat(1.0)
#y1 = squarewave.(f1*t1) * 1	
#y1 = (sin.(2pi * f1* t1) .*0.1) 
#y1 = trianglewave.(f1* t1) * 1
y1 = (sin.(2pi * f1* t1) .*t1) .+ (sin.(2pi * f1*2* t1 .+pi) .*t1/2)
wavplay(y1, fs1)	
end

# ╔═╡ b9a462bd-67b0-426a-a912-9422c3524885
lineplot(t1, y1)

# ╔═╡ 545eb713-70f5-4e04-adf5-bbb6100a453f
@bind a1 Slider(0:0.1:2,default=0.1, show_value=true)

# ╔═╡ 8577ca66-db1e-4f9b-a775-adb4b404e4e8
@bind x Slider(0:100:10000,default=100, show_value=true)

# ╔═╡ 2d064c8f-d7f4-48ed-985d-c61172088a62
@bind L Slider(0:100:10000,default=100, show_value=true)

# ╔═╡ ee1eaf9e-1459-4184-85e6-0736053304ef
@bind fw Slider(0:100:10000,default=100, show_value=true)

# ╔═╡ ed916679-4bca-41cc-9fae-c6b8362855a0
@bind n Slider(1:1:10,default=2, show_value=true)

# ╔═╡ 236f96dd-8ed0-4332-9e78-41bd0b57c5ac
@bind vibfs Slider(0:100:10000,default=100, show_value=true)

# ╔═╡ 58f1d291-6cd3-42a2-b48a-44a4fd590dd4
# making vibrations
begin
tn = 0.0:1/vibfs:prevfloat(1.0)
vib =  2 * a1 * sin.(n*pi*x/L).*cos.(2*pi*fw*tn)
end

# ╔═╡ d8396378-e8b5-413f-87b4-d77479e130e7
lineplot(tn, vib)

# ╔═╡ d8d86fdc-8adf-43db-ae77-a04dabb2c63a
# wavplay(vib, vibfs)

# ╔═╡ fd76e076-2b61-4e55-9cd3-e59340168f4d


# ╔═╡ Cell order:
# ╠═fb56c064-b90d-11eb-124f-bd2478c9a5bf
# ╠═a6fcf1e7-e477-41d3-b33a-08f521db740c
# ╠═6813d955-d54d-47ac-8cec-5be4ea1847fe
# ╠═df0fbb6c-bad6-435d-a931-2a4cd9ea935c
# ╠═c5413acd-7828-4da0-9009-65fd61264637
# ╠═56d13e40-49bc-4f45-9033-0a4003070da8
# ╠═683fa835-7339-4b7c-89fe-6511da652e2d
# ╠═17af4d9f-687a-48c8-9a68-10d9bb713187
# ╠═263973d5-9d5c-427b-94cb-bd74073a7a29
# ╠═8c401e62-30b2-492d-a896-b0dceb2c8508
# ╠═aa1d8f3a-09cd-4fee-b6a0-e959650b0faa
# ╠═a5298c48-a277-4c1c-bb35-e129cb205df2
# ╠═e4b55da5-2cba-46b0-a084-2ebbb93a31f9
# ╠═5ffbc4bf-cc16-474e-8985-2ebb81dc821c
# ╠═3ee38394-fce7-456f-86f8-0f889b2c4f1a
# ╠═37c49652-2500-4236-8ffb-0906ff0248e5
# ╠═1df63790-0d76-4c41-aaf9-5cf39ec6cb98
# ╠═446e0ba3-4c3a-4e15-b1a1-5a8046c02c3c
# ╠═dd194f36-68c0-440b-86f8-9f3ec2a78647
# ╠═b9a462bd-67b0-426a-a912-9422c3524885
# ╠═545eb713-70f5-4e04-adf5-bbb6100a453f
# ╠═8577ca66-db1e-4f9b-a775-adb4b404e4e8
# ╠═2d064c8f-d7f4-48ed-985d-c61172088a62
# ╠═ee1eaf9e-1459-4184-85e6-0736053304ef
# ╠═ed916679-4bca-41cc-9fae-c6b8362855a0
# ╠═236f96dd-8ed0-4332-9e78-41bd0b57c5ac
# ╠═58f1d291-6cd3-42a2-b48a-44a4fd590dd4
# ╠═d8396378-e8b5-413f-87b4-d77479e130e7
# ╠═d8d86fdc-8adf-43db-ae77-a04dabb2c63a
# ╠═fd76e076-2b61-4e55-9cd3-e59340168f4d
