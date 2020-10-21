### A Pluto.jl notebook ###
# v0.11.14

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

# ╔═╡ e46109f4-f845-11ea-3a4e-19196c50bbb8
using Images

# ╔═╡ f86c33e4-f848-11ea-1392-8566e516d8dd
using Plots

# ╔═╡ 7aae35f2-f90a-11ea-162d-b1a6d0137512
using PlutoUI

# ╔═╡ ca75f874-f845-11ea-1d22-9352f0e872bb
download("https://upload.wikimedia.org/wikipedia/commons/thumb/6/67/Giant_Pandas_having_a_snack.jpg/1280px-Giant_Pandas_having_a_snack.jpg",
	"pandas.jpg")

# ╔═╡ e6a44cf8-f845-11ea-0918-6585b79b2981
pandas = load("pandas.jpg")

# ╔═╡ db932344-f90a-11ea-262a-89ba870543d7
function color_slider()
	Slider(-0.2 : 0.01 : 0.2, default = 0.0 )
end

# ╔═╡ fe39ca62-f90a-11ea-3c73-1deb0d6bf9f3
function color_curve(contrast, intensity)
	x -> max(0, min(1, 
			x + contrast * sin((x - 0.5) * 2 * pi) + intensity * cos((x - 0.5) * pi) 
			))
end

# ╔═╡ 7b72bd6e-f84a-11ea-3c86-d52011d43cde
function apply_curve(img, red_curve, green_curve, blue_curve)
	
	function apply_curve(color)
		RGB(red_curve(color.r), green_curve(color.g), blue_curve(color.b))
	end
	
	apply_curve.(img)
end

# ╔═╡ 6e59eb98-f90a-11ea-0540-2b03b30c5bd1
md"""
**Red**:

Contrast: $(@bind red_contrast color_slider()) 

Intensity: $(@bind red_intensity color_slider())

**Green**:

Contrast: $(@bind green_contrast color_slider()) 

Intensity: $(@bind green_intensity color_slider())

**Blue**:

Contrast: $(@bind blue_contrast color_slider()) 

Intensity: $(@bind blue_intensity color_slider())
"""

# ╔═╡ 37d21840-f84a-11ea-1fdc-43a5227edf08
reds = color_curve(red_contrast, red_intensity)

# ╔═╡ 541dd022-f84a-11ea-0449-a924bfcb70a5
greens = color_curve(green_contrast, green_intensity)

# ╔═╡ 4b46ed74-f84a-11ea-05f3-9337d7b46823
blues = color_curve(blue_contrast, blue_intensity)

# ╔═╡ cfc1d17e-f84a-11ea-3782-b9fd15025fe6
apply_curve(pandas, reds, greens, blues)

# ╔═╡ f6bccafe-f848-11ea-3736-4b6449fbfa0e
#plot curves
function plot_curves(red_curve, green_curve, blue_curve)
	ticks = range(0,1,step=0.05)
	plot(ticks, red_curve, label = "red", linecolor = RGB(0.8,0,0))
	plot!(ticks, green_curve, label = "green", linecolor = RGB(0,0.8,0))
	plot!(ticks, blue_curve, label = "red", linecolor = RGB(0,0,0.8))
	plot!(legend = false)
end

# ╔═╡ 59a8caae-f84a-11ea-32fd-2520b9a8b57f
plot_curves(reds, greens, blues)

# ╔═╡ Cell order:
# ╠═e46109f4-f845-11ea-3a4e-19196c50bbb8
# ╠═f86c33e4-f848-11ea-1392-8566e516d8dd
# ╠═7aae35f2-f90a-11ea-162d-b1a6d0137512
# ╠═ca75f874-f845-11ea-1d22-9352f0e872bb
# ╠═e6a44cf8-f845-11ea-0918-6585b79b2981
# ╠═db932344-f90a-11ea-262a-89ba870543d7
# ╠═fe39ca62-f90a-11ea-3c73-1deb0d6bf9f3
# ╠═37d21840-f84a-11ea-1fdc-43a5227edf08
# ╠═541dd022-f84a-11ea-0449-a924bfcb70a5
# ╠═4b46ed74-f84a-11ea-05f3-9337d7b46823
# ╠═7b72bd6e-f84a-11ea-3c86-d52011d43cde
# ╟─6e59eb98-f90a-11ea-0540-2b03b30c5bd1
# ╠═cfc1d17e-f84a-11ea-3782-b9fd15025fe6
# ╠═59a8caae-f84a-11ea-32fd-2520b9a8b57f
# ╟─f6bccafe-f848-11ea-3736-4b6449fbfa0e
