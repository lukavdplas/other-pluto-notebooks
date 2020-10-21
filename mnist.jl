### A Pluto.jl notebook ###
# v0.12.4

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

# ╔═╡ a7f3be2c-1397-11eb-3461-317cabdde53b
using Images, GZip

# ╔═╡ 8337bd64-13aa-11eb-3259-3d3a8fb11287
md"# Machine learning"

# ╔═╡ 9eabb20a-13a3-11eb-1d38-495ad0d6953f
md"""
### Before we begin...

This notebook requires several packages. Check the box below to install any that you do not already have.

$(@bind install_all_packages html"<input type=checkbox>  Install all packages")
$(html"<br>")
"""

# ╔═╡ 6e4bd2f2-13a3-11eb-1c05-295e31903102
if install_all_packages
	import Pkg
	Pkg.add("Images")
	Pkg.add("ImageMagick")
	Pkg.add("GZip")
end

# ╔═╡ 5bd9edc8-13aa-11eb-0078-95bb6449bf80
md"""It also requires the MNIST data, published [here](http://yann.lecun.com/exdb/mnist/). Check the box below to let the notebook download the data.

$(@bind download_mnist html"<input type=checkbox>  Download MNIST data ")
$(html"<br>")

The notebook will only work if both boxes are checked."""

# ╔═╡ 6057bdec-13a2-11eb-36da-65c95bd6b651
md"""
## The MNIST dataset

The MNIST dataset consists of handwritten numbers, and a label that tells you what each number is supposed to be.

I'm saving each handwritten number as a grayscale image.
"""

# ╔═╡ 4171703e-13a3-11eb-3a45-b1e612c6e75a
md"""
## Defining a classifier
"""

# ╔═╡ a7857c1e-13a6-11eb-31b9-e32b5798ce52
md"""
## Training
"""

# ╔═╡ 833bdf2e-13ab-11eb-1c13-379162a030d4
md"""
Use the button below to train the model.


$(@bind start_training html"<button>Train!</button>")
"""

# ╔═╡ b04a32c4-13a6-11eb-0f8d-9bbe269ce86c
md"""
## Evaluation
"""

# ╔═╡ 91a0546e-13a1-11eb-3fa0-6fedd2d74ed6
md"""
## Data import

This section will download the MNIST data and save them in the folder `mnist` in your working directory. If you want, you can change the location to somewhere else by editing the `location` variable below.
"""

# ╔═╡ 651faff4-13a4-11eb-1ce2-d98c288ad3be
location = "."

# ╔═╡ 7af00b44-13a4-11eb-04b7-670522b8791c
data_dir = location * "/mnist/"

# ╔═╡ 31eca87e-13a6-11eb-08bf-2b76cb46a24c
train_img_filename = "train-images-idx3-ubyte.gz"

# ╔═╡ 6b27d95e-13a6-11eb-036a-d17e19f62c64
train_labels_filename = "train-labels-idx1-ubyte.gz"

# ╔═╡ 542651a8-13a6-11eb-3f8c-075ccd2ad28b
test_img_filename = "t10k-images-idx3-ubyte.gz"

# ╔═╡ 782edb72-13a6-11eb-2983-cda32f85aee2
test_labels_filename = "t10k-labels-idx1-ubyte.gz"

# ╔═╡ 0d87e450-13a4-11eb-3763-4356f6efd2a9
downloaded = if download_mnist
	#make folder if needed
	if !("mnist" in readdir(location))
		mkdir(data_dir)
	end
	
	#download files
	required_files = [train_img_filename, test_img_filename, 
		train_labels_filename, test_labels_filename]
	
	for filename in required_files
		if !(filename in readdir(data_dir))
			url = "http://yann.lecun.com/exdb/mnist/" * filename
			download(url, data_dir * filename)
		end
	end
	
	true
else
	false
end

# ╔═╡ 792a208a-139f-11eb-2737-ed7c972f44b6
function grayscale(byte)
	Gray(1 - byte / 256)
end

# ╔═╡ 39422960-139b-11eb-0210-b9e210f0d640
function read_img_file(filename)
	if downloaded
		GZip.open(filename) do file
			readbyte() = read(file, UInt8)
			read32bit(n) = map(1:n) do i
				parts = map(1:4) do j
					readbyte() * 2 ^ (32 - 8j)
				end
				sum(parts)
			end

			_, size, rows, cols = read32bit(4)

			map(1:size) do n
				img = [grayscale(readbyte()) for y in 1:cols, x in 1:rows]
				transpose(img)
			end
		end
	end
end

# ╔═╡ 67a3c41e-139e-11eb-24a0-9fa40b76e6c5
train_data = read_img_file(data_dir * train_img_filename)

# ╔═╡ b3d68dcc-13a2-11eb-3f71-1b37f458b3fb
train_size = length(train_data)

# ╔═╡ c2561502-13a2-11eb-1c15-238a2333228a
width, height = size(train_data[1])

# ╔═╡ 8521b04e-13a0-11eb-2f17-57d3d45fff46
test_data = read_img_file(data_dir * test_img_filename)

# ╔═╡ b83e5f3c-13ae-11eb-2e3e-a1053f9d8c29
test_size = length(test_data)

# ╔═╡ ff802cf8-13a0-11eb-19d8-d5ffbb1983f6
function read_label_file(filename)
	if downloaded
		GZip.open(filename) do file
			readbyte() = read(file, UInt8)
			read32bit(n) = map(1:n) do i
				parts = map(1:4) do j
					readbyte() * 2 ^ (32 - 8j)
				end
				sum(parts)
			end

			_, size = read32bit(2)

			map(1:size) do n
				readbyte() * 1
			end
		end
	end
end

# ╔═╡ 09ab0d56-13a1-11eb-1422-5b1c21afd3c8
train_labels = read_label_file(data_dir * train_labels_filename)

# ╔═╡ 7df29cce-13a1-11eb-23bc-d1d73545b535
test_labels = read_label_file(data_dir * test_labels_filename)

# ╔═╡ Cell order:
# ╟─8337bd64-13aa-11eb-3259-3d3a8fb11287
# ╟─9eabb20a-13a3-11eb-1d38-495ad0d6953f
# ╠═6e4bd2f2-13a3-11eb-1c05-295e31903102
# ╠═a7f3be2c-1397-11eb-3461-317cabdde53b
# ╟─5bd9edc8-13aa-11eb-0078-95bb6449bf80
# ╟─6057bdec-13a2-11eb-36da-65c95bd6b651
# ╠═67a3c41e-139e-11eb-24a0-9fa40b76e6c5
# ╠═09ab0d56-13a1-11eb-1422-5b1c21afd3c8
# ╠═b3d68dcc-13a2-11eb-3f71-1b37f458b3fb
# ╠═c2561502-13a2-11eb-1c15-238a2333228a
# ╠═8521b04e-13a0-11eb-2f17-57d3d45fff46
# ╠═7df29cce-13a1-11eb-23bc-d1d73545b535
# ╠═b83e5f3c-13ae-11eb-2e3e-a1053f9d8c29
# ╟─4171703e-13a3-11eb-3a45-b1e612c6e75a
# ╟─a7857c1e-13a6-11eb-31b9-e32b5798ce52
# ╟─833bdf2e-13ab-11eb-1c13-379162a030d4
# ╟─b04a32c4-13a6-11eb-0f8d-9bbe269ce86c
# ╟─91a0546e-13a1-11eb-3fa0-6fedd2d74ed6
# ╠═651faff4-13a4-11eb-1ce2-d98c288ad3be
# ╟─7af00b44-13a4-11eb-04b7-670522b8791c
# ╟─31eca87e-13a6-11eb-08bf-2b76cb46a24c
# ╟─6b27d95e-13a6-11eb-036a-d17e19f62c64
# ╟─542651a8-13a6-11eb-3f8c-075ccd2ad28b
# ╟─782edb72-13a6-11eb-2983-cda32f85aee2
# ╟─0d87e450-13a4-11eb-3763-4356f6efd2a9
# ╟─39422960-139b-11eb-0210-b9e210f0d640
# ╟─792a208a-139f-11eb-2737-ed7c972f44b6
# ╟─ff802cf8-13a0-11eb-19d8-d5ffbb1983f6
