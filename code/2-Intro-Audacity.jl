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

# ╔═╡ ff275f7e-b9fe-11eb-1f20-39ca812b0fbe
using WAV, PlutoUI, DSP, Plots,UnicodePlots

# ╔═╡ 983dde83-0ad7-4d1f-81b8-a85e74b137f0
gr()

# ╔═╡ 59209394-0315-4e4e-bd83-8b8d08b9acd4
begin
# # fs = 8e3
# t = 0.0:1/fs:prevfloat(1.0)
# f = 1e3
# y = sin.(2pi * f * t) * 0.1
# wavwrite(y, "example.wav", Fs=fs)

# y, fs = wavread("example.wav")
# y = sin.(2pi * 2f * t) * 0.1
# wavappend(y, "example.wav")

y, fs1 = wavread("piano-phrase.wav")
wavplay(y, fs1)	
end

# ╔═╡ 8413a04a-a377-40e1-b798-26d8964f8ada
y #we use 64-bit float

# ╔═╡ 9ea99bc6-38d0-40bf-b498-5aff2cf957d1
fs1 #sampling rate

# ╔═╡ 13937baf-4bb7-4de8-9a8d-9a6d0228fb52
size(y)

# ╔═╡ da16ccb9-b5a8-4875-94d8-9c60538ae41c

begin
plot(0:1/fs1:(length(y)-1)/fs1, y)
# xlabel("Time [s]")	
end

# ╔═╡ 4c7ab8a6-8fbb-4024-b434-ab512d156f61
wavplay(y, fs1)

# ╔═╡ fecbcf72-4146-4dff-a2f7-6e5c5e07bfe1
@bind A Slider(.1:.1:1,default=.8,show_value=true)

# ╔═╡ 6a68a83a-6f4c-4355-8ddc-797cccaac1f4
@bind phi Slider(0:pi/6:2pi,default=pi/2,show_value=true)

# ╔═╡ a3cbf87e-ae75-4418-b5b4-44d6ac5f1469
# @bind f0 Slider(0:10:1000,default=440,show_value=true)

# ╔═╡ f4b75e73-47f9-4786-8210-8619daf50cb5
@bind fsd Slider(0:1000:50000,default=44100,show_value=true)

# ╔═╡ e7426fcc-bb42-4df0-8390-ea2085021860
begin
f0 = 880
t = 1:1/fsd:11
wave = A./t .*sin.(2*pi*f0*t .+ phi)

#y1 = squarewave.(f1*t1) * 1	
#y1 = (sin.(2pi * f1* t1) .*0.1) 
#y1 = trianglewave.(f1* t1) * 1
# y1 = (sin.(2pi * f1* t1) .*t1) .+ (sin.(2pi * f1*2* t1 .+pi) .*t1/2)
wavplay(wave, fsd)	
end

# ╔═╡ 521e87e1-d9eb-4bfc-96f5-b8678c7c83a1
lineplot(t,wave)

# ╔═╡ 9b852298-1cb9-49d9-9384-1be059d2918a
begin
@bind f1 Slider(0:10:1000,default=200,show_value=true)
end

# ╔═╡ 24ecd45a-9863-4cc2-b23c-ceb2c2f8c9e9
@bind f2 Slider(0:10:1000,default=400,show_value=true)

# ╔═╡ 5398de30-c98f-405f-a34c-a790a6458e17
@bind f3 Slider(0:10:1000,default=600,show_value=true)

# ╔═╡ 639ac6cb-4763-406e-8f31-8c190ef2ea30
@bind f4 Slider(0:10:1000,default=800,show_value=true)

# ╔═╡ 77737e79-de60-4134-a95e-2e40b2ca1ec3
@bind f5 Slider(0:10:1000,default=1000,show_value=true)

# ╔═╡ 58c40dd6-23f6-4a97-8389-acff4c906a4c
begin
ta = 0:1/fsd:0.008
harmonic1 = A*sin.(2*pi*f1*ta .+ phi)
harmonic2 = A*sin.(2*pi*f2*ta .+ phi)
harmonic3 = A*sin.(2*pi*f3*ta .+ phi)
harmonic4 = A*sin.(2*pi*f4*ta .+ phi)
harmonic5 = A*sin.(2*pi*f5*ta .+ phi)	
end

# ╔═╡ 537e7423-cb27-49b1-8cec-947051ba2964
lineplot(ta,harmonic1)

# ╔═╡ c25eb43b-2fc7-4f96-a4f4-f48f89138786
lineplot(ta,harmonic2)

# ╔═╡ 4bf9ddc2-c3d9-48af-9afd-509aa0505e53
lineplot(ta,harmonic3)

# ╔═╡ cabb81ec-1d67-46f4-b4e3-296f763fc644
lineplot(ta,harmonic4)

# ╔═╡ 0bc6ab88-9498-417e-95af-4b733a0db37a
lineplot(ta,harmonic5)

# ╔═╡ 938ed7b9-2a5e-4a8a-a8fe-f3e1e179324e
composite = harmonic1 .+ harmonic2 .+ harmonic3 .+ harmonic4 .+harmonic5

# ╔═╡ cb7abc8f-259d-4509-8e67-69dc7fbdc2bc
lineplot(ta,composite)

# ╔═╡ Cell order:
# ╠═ff275f7e-b9fe-11eb-1f20-39ca812b0fbe
# ╠═983dde83-0ad7-4d1f-81b8-a85e74b137f0
# ╠═59209394-0315-4e4e-bd83-8b8d08b9acd4
# ╠═8413a04a-a377-40e1-b798-26d8964f8ada
# ╠═9ea99bc6-38d0-40bf-b498-5aff2cf957d1
# ╠═13937baf-4bb7-4de8-9a8d-9a6d0228fb52
# ╠═da16ccb9-b5a8-4875-94d8-9c60538ae41c
# ╠═4c7ab8a6-8fbb-4024-b434-ab512d156f61
# ╠═fecbcf72-4146-4dff-a2f7-6e5c5e07bfe1
# ╠═6a68a83a-6f4c-4355-8ddc-797cccaac1f4
# ╠═a3cbf87e-ae75-4418-b5b4-44d6ac5f1469
# ╠═f4b75e73-47f9-4786-8210-8619daf50cb5
# ╠═e7426fcc-bb42-4df0-8390-ea2085021860
# ╠═521e87e1-d9eb-4bfc-96f5-b8678c7c83a1
# ╠═9b852298-1cb9-49d9-9384-1be059d2918a
# ╠═24ecd45a-9863-4cc2-b23c-ceb2c2f8c9e9
# ╠═5398de30-c98f-405f-a34c-a790a6458e17
# ╠═639ac6cb-4763-406e-8f31-8c190ef2ea30
# ╠═77737e79-de60-4134-a95e-2e40b2ca1ec3
# ╠═58c40dd6-23f6-4a97-8389-acff4c906a4c
# ╠═537e7423-cb27-49b1-8cec-947051ba2964
# ╠═c25eb43b-2fc7-4f96-a4f4-f48f89138786
# ╠═4bf9ddc2-c3d9-48af-9afd-509aa0505e53
# ╠═cabb81ec-1d67-46f4-b4e3-296f763fc644
# ╠═0bc6ab88-9498-417e-95af-4b733a0db37a
# ╠═938ed7b9-2a5e-4a8a-a8fe-f3e1e179324e
# ╠═cb7abc8f-259d-4509-8e67-69dc7fbdc2bc
