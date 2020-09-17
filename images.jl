### A Pluto.jl notebook ###
# v0.11.14

using Markdown
using InteractiveUtils

# ╔═╡ e46109f4-f845-11ea-3a4e-19196c50bbb8
using Images

# ╔═╡ f86c33e4-f848-11ea-1392-8566e516d8dd
using Plots

# ╔═╡ 9f62a376-f845-11ea-0c80-8d8d8f2dfc52
url = "https://upload.wikimedia.org/wikipedia/commons/thumb/6/67/Giant_Pandas_having_a_snack.jpg/1280px-Giant_Pandas_having_a_snack.jpg"

# ╔═╡ ca75f874-f845-11ea-1d22-9352f0e872bb
download(url, "pandas.jpg")

# ╔═╡ e6a44cf8-f845-11ea-0918-6585b79b2981
pandas = load("pandas.jpg")

# ╔═╡ 37d21840-f84a-11ea-1fdc-43a5227edf08
reds = x -> x^2

# ╔═╡ 541dd022-f84a-11ea-0449-a924bfcb70a5
greens = x -> x

# ╔═╡ 4b46ed74-f84a-11ea-05f3-9337d7b46823
blues = x -> x^3

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

# ╔═╡ 7b72bd6e-f84a-11ea-3c86-d52011d43cde
function apply_curve(img, red_curve, green_curve, blue_curve)
	
	function apply_curve(color)
		RGB(red_curve(color.r), green_curve(color.g), blue_curve(color.b))
	end
	
	apply_curve.(img)
end

# ╔═╡ cfc1d17e-f84a-11ea-3782-b9fd15025fe6
apply_curve(pandas, reds, greens, blues)

# ╔═╡ Cell order:
# ╠═e46109f4-f845-11ea-3a4e-19196c50bbb8
# ╠═f86c33e4-f848-11ea-1392-8566e516d8dd
# ╠═9f62a376-f845-11ea-0c80-8d8d8f2dfc52
# ╠═ca75f874-f845-11ea-1d22-9352f0e872bb
# ╠═e6a44cf8-f845-11ea-0918-6585b79b2981
# ╠═37d21840-f84a-11ea-1fdc-43a5227edf08
# ╠═541dd022-f84a-11ea-0449-a924bfcb70a5
# ╠═4b46ed74-f84a-11ea-05f3-9337d7b46823
# ╠═f6bccafe-f848-11ea-3736-4b6449fbfa0e
# ╠═59a8caae-f84a-11ea-32fd-2520b9a8b57f
# ╠═7b72bd6e-f84a-11ea-3c86-d52011d43cde
# ╠═cfc1d17e-f84a-11ea-3782-b9fd15025fe6
