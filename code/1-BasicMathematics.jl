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

# ╔═╡ bce7c57b-9250-496a-a943-275301ea8c6c
begin
    import Pkg
    Pkg.add(url="https://github.com/Pocket-titan/DarkMode")
    import DarkMode
    DarkMode.enable()
    # OR DarkMode.Toolbox(theme="default")
end

# ╔═╡ dacc8004-b9f0-11eb-04d8-a391fd316be6
using PlutoUI, WAV, UnicodePlots

# ╔═╡ afdee77e-ccdb-42ad-9402-e0dd214fc7aa
md"![](https://i.imgur.com/k2qKXDd.png)"

# ╔═╡ db3d1596-f84c-4e0d-a3cf-23b6cdd7b8b4
@bind A Slider(.1:.1:1,default=.8,show_value=true)

# ╔═╡ 671513e6-1d23-49e9-802c-b50d079c0b94
@bind phi Slider(0:pi/6:2pi,default=pi/2,show_value=true)

# ╔═╡ 828db6b2-6c0f-4a81-a804-0a1ae2ed1dc0
@bind f0 Slider(0:1000:10000,default=1000,show_value=true)

# ╔═╡ 01cb6294-a0d3-4e10-a919-7da531c36997
@bind fs Slider(0:1000:50000,default=44100,show_value=true)

# ╔═╡ b3b71013-5de2-4f7c-99a7-98f92de69ec7
begin
	
t = -0.002:1/fs:0.002
y = A*cos.(2*pi*f0*t .+ phi)

#y1 = squarewave.(f1*t1) * 1	
#y1 = (sin.(2pi * f1* t1) .*0.1) 
#y1 = trianglewave.(f1* t1) * 1
# y1 = (sin.(2pi * f1* t1) .*t1) .+ (sin.(2pi * f1*2* t1 .+pi) .*t1/2)
wavplay(y, fs)	
end

# ╔═╡ 956dbaf0-f6f7-495f-acdd-03792be4eade
lineplot(t, y)

# ╔═╡ 13b2dac6-6f57-4922-9931-24ff501f7e9b
md"""
## Complex Numbers
```
(a + ib)  a,b: real numbers; i: imaginary unit
```
- Rectangular form: a+ib
- Polar form: A=sqroot(a^2+b^2);phi=a*tan(2(b/a))
"""

# ╔═╡ 5db2175f-d377-49b5-bfb3-f9403857c48b
md"""
## Euler's Formula

Fundamental to understand discrete fourier transform

$$e^{i\phi} = cos(\phi) + isin(\phi)$$

$$cos(\phi) = \frac{e^{i\phi}+ e^{-i\phi}}{2}$$
$$sin(\phi) = \frac{e^{i\phi}- e^{-i\phi}}{2i}$$
"""

# ╔═╡ d4e6f5af-2f22-4501-adf9-fadb96d9c436
md"""
![](https://i.imgur.com/HkbIUh8.png)

We plot the complex wave  in a 2d graph by plotting real and imaginary parts separately
"""


# ╔═╡ f705e1df-9ef3-4eae-9edb-1b0f932569a2
md"""
## Scalar(Dot Product of sequences)
$$x=[1,2,3] , y = [1,2,3]$$
$$dot = 1*1 + 2*2 + 3*3 = 14$$

Scalar product of two orthogonal sequences is 0.

$$x = [2,2], y = [2,-2]$$
$$dot = 2*2 + 2*-2 = 0$$

"""

# ╔═╡ 178a84f2-54e4-42f2-8ee2-165db0dc3618
md"""
![](https://i.imgur.com/iixirS3.png)
"""

# ╔═╡ 23b9bb3e-74f4-43f6-b3dc-8e2edcc5700d
@bind A1 Slider(.1:.1:1,default=.8,show_value=true)

# ╔═╡ 47ce6005-a5c9-4684-8632-33e675433bd9
@bind A2 Slider(.1:.1:1,default=.8,show_value=true)

# ╔═╡ 17258789-78dd-446e-bc57-36faf3fe664b
@bind phi1 Slider(0:pi/6:2pi,default=pi/2,show_value=true)

# ╔═╡ 0b7b17a5-d2c5-4af5-b1c9-376fdaffdd58
@bind phi2 Slider(0:pi/6:2pi,default=pi/2,show_value=true)

# ╔═╡ 51f34b02-d31f-435d-b816-7369da8764ce
@bind f01 Slider(0:1000:10000,default=1000,show_value=true)

# ╔═╡ c8a44a7c-ea12-4d7c-a2ab-c2b792f12a0e
@bind f02 Slider(0:1000:10000,default=1000,show_value=true)

# ╔═╡ 234f7169-6f24-4508-a35a-11664de63f48
@bind fst Slider(0:1000:50000,default=44100,show_value=true)

# ╔═╡ 6777d7e3-de89-45a8-a07f-bb22428b0418
begin
#tr = -1:1/fst:1	 #use this if want to hear something and comment next line
tr = -0.002:1/fs:0.002
y1 = A1*sin.(2*pi*f01*tr .+ phi1)
y2 = A2*cos.(2*pi*f02*tr .+ phi2)
addresult =y1 .+ y2
subresult =y1 .- y2
mulresult =y1 .* y2
divresult =y1 ./ y2	
wavplay(subresult, fst)	
end

# ╔═╡ 1a532407-0157-4ced-b657-7b0b3f664142
lineplot(tr, y1)

# ╔═╡ 8c0abdfe-ad72-4307-97c7-3358a9889a7e
lineplot(tr, y2)

# ╔═╡ 96048a2b-31dc-4377-bcd5-64528a5127d1
lineplot(tr, addresult)

# ╔═╡ 82b9d306-07a7-41d3-a0a6-dfd1ee3153fc
lineplot(tr, subresult)

# ╔═╡ c2b815e6-062d-4225-8ed6-221b16fbec7f
lineplot(tr, mulresult)

# ╔═╡ 53989efc-c028-4f84-abbd-fffc7727f2da
lineplot(tr, divresult)

# ╔═╡ a01ff431-a00f-4a36-9aed-520209e53e8d
md"""
Important Resources:

- https://ccrma.stanford.edu/~jos/mdft/
- https://github.com/MTG/sms-tools

"""

# ╔═╡ Cell order:
# ╠═bce7c57b-9250-496a-a943-275301ea8c6c
# ╠═dacc8004-b9f0-11eb-04d8-a391fd316be6
# ╠═afdee77e-ccdb-42ad-9402-e0dd214fc7aa
# ╠═db3d1596-f84c-4e0d-a3cf-23b6cdd7b8b4
# ╠═671513e6-1d23-49e9-802c-b50d079c0b94
# ╠═828db6b2-6c0f-4a81-a804-0a1ae2ed1dc0
# ╠═01cb6294-a0d3-4e10-a919-7da531c36997
# ╠═b3b71013-5de2-4f7c-99a7-98f92de69ec7
# ╠═956dbaf0-f6f7-495f-acdd-03792be4eade
# ╠═13b2dac6-6f57-4922-9931-24ff501f7e9b
# ╠═5db2175f-d377-49b5-bfb3-f9403857c48b
# ╠═d4e6f5af-2f22-4501-adf9-fadb96d9c436
# ╠═f705e1df-9ef3-4eae-9edb-1b0f932569a2
# ╠═178a84f2-54e4-42f2-8ee2-165db0dc3618
# ╠═23b9bb3e-74f4-43f6-b3dc-8e2edcc5700d
# ╠═47ce6005-a5c9-4684-8632-33e675433bd9
# ╠═17258789-78dd-446e-bc57-36faf3fe664b
# ╠═0b7b17a5-d2c5-4af5-b1c9-376fdaffdd58
# ╠═51f34b02-d31f-435d-b816-7369da8764ce
# ╠═c8a44a7c-ea12-4d7c-a2ab-c2b792f12a0e
# ╠═234f7169-6f24-4508-a35a-11664de63f48
# ╠═6777d7e3-de89-45a8-a07f-bb22428b0418
# ╠═1a532407-0157-4ced-b657-7b0b3f664142
# ╠═8c0abdfe-ad72-4307-97c7-3358a9889a7e
# ╠═96048a2b-31dc-4377-bcd5-64528a5127d1
# ╠═82b9d306-07a7-41d3-a0a6-dfd1ee3153fc
# ╠═c2b815e6-062d-4225-8ed6-221b16fbec7f
# ╠═53989efc-c028-4f84-abbd-fffc7727f2da
# ╟─a01ff431-a00f-4a36-9aed-520209e53e8d
