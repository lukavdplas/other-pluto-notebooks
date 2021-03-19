### A Pluto.jl notebook ###
# v0.12.7

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
using Images, GZip, Flux

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
	Pkg.add("Flux")
end

# ╔═╡ 5bd9edc8-13aa-11eb-0078-95bb6449bf80
md"""It also requires the MNIST data, published [here](http://yann.lecun.com/exdb/mnist/). Check the box below to let the notebook download the data.

$(@bind download_mnist html"<input type=checkbox>  Download MNIST data ")
$(html"<br>")"""

# ╔═╡ 6057bdec-13a2-11eb-36da-65c95bd6b651
md"""
## The MNIST dataset

The MNIST dataset consists of handwritten numbers, and a label that tells you what each number is supposed to be.

I'm saving each handwritten number as a grayscale image.

The code for the download is at the bottom of the notebook. Note: using Flux, you can also download this dataset using the `Flux.Data.MNIST` module, but I had some trouble in getting this to work.
"""

# ╔═╡ 4171703e-13a3-11eb-3a45-b1e612c6e75a
md"""
## Defining a classifier
"""

# ╔═╡ 1ebd61ea-148b-11eb-1cc1-45606fbcca6d
md"""
### Preparing the images

We will change the shape of the image data a bit, to make them more convenient input for a machine learning model. 

**Step 1: Reduce**

The bigger the images we use, the more work the model will need to do. To make things run a little faster, we will start out by making our image twice as small.
"""

# ╔═╡ 5d3ccfdc-148b-11eb-11a0-e7261283bc9e
function reduce_image(img)
	width, height = size(img)
	
	[img[x,y] for x in 1:2:width, y in 1:2:height]
end

# ╔═╡ dbe34bec-1489-11eb-392f-bf6de149552d
md"""
**Step 2: Flatten**

Our MNIST images are two-dimensional, but our model won't actually care about that. We are considering each pixel individually, so we might as well put them all in a row.

Doing so will things easier, because our data will look more "standard". So here is a function that will do that.
"""

# ╔═╡ 6d651b22-148a-11eb-04fa-938d39f43c44
function flatten_image(img) ::Array{Float64}
	reshape(img, length(img))
end

# ╔═╡ 27c945da-2136-11eb-24db-3589966f93e5
function invert_values(values)
	map(values) do value
		1.0 - value
	end
end

# ╔═╡ cbb5a828-212c-11eb-1bb2-c9bf3b849b6c
md"""
We can concatenate these two options in a `prepare` function.
"""

# ╔═╡ fc48fbea-212c-11eb-0a1c-0bb67c0b00f5
prepare = invert_values ∘ flatten_image ∘ reduce_image

# ╔═╡ 03025a36-148c-11eb-28f8-a3a36a284d03
md"""
### The model

We have done some work to make our images as easy to work with as possible. Now the real work needs to happen.

**Step 1: transform**

We have number of _input features_. From there, we need to give a score to each _output class_. In our case, the output classes are the 10 possible digits. The score of the image for an output class will tell us how much the image looks like it belongs to that class.

To do this, we use a singe dense layer. To calculate the score _s_, we multiply each input feature $x_i$ (the i-eth input feature) with a corresponding _weight_, $w_i$. We sum all those together, and then we add a _bias_, $b$. So we get:

$s = b + \sum_i w_i \cdot x_i$

We need one of these equations for each output class - i.e. each digit.

Flux already has a `Dense` constructor that makes exactly this.
"""

# ╔═╡ 54f8e3a0-148f-11eb-2ea3-cb515f35458e
md"""
What's this `input_size`? It's the number of input features, i.e. pixels. But remember that we reduced our images, so it should be number of pixels in the reduced version.
"""

# ╔═╡ 9c969326-148f-11eb-3ecc-6303da117d28
md"""
**Step 2: Softmax**

The dense layer will give us 10 scores. But those scores can be any number. What does it mean when a digit gets a score of 2.42? Is that a lot? We want to translate the scores into something we can interpret directly. 

That is what the softmax function will do. It takes all 10 scores and turns them into values between 1 and 0, in such a way that they all sum to 1. That way, you can kind of read them like probabilities. An output of 1 means it's definitely that digit, and an output of 0 means it definitely isn't.

We can use the existing `softmax` function from Flux.
"""

# ╔═╡ 8325aa84-1490-11eb-26e9-392669ca894d
softmax

# ╔═╡ 7e60aeb8-1490-11eb-0969-5d1734ac7540
md"""
**Constructing a model**

Now let's put all of these steps into a model.

To make everything run smoothly in a reactive environment, we will write a function that constructs a model. We could define the model directly, but then some weird things might happen if we update it later.
"""

# ╔═╡ 5a9734ec-1491-11eb-39d2-27be371f2942
md"""
We can intialise a model to see how this works.
"""

# ╔═╡ 37b1c064-212f-11eb-1177-f3d0eac900cc
md"""
A Flux model can use used on input like a function. We give it some input, and it gives us the output of the model.
"""

# ╔═╡ 6f8b6daa-1491-11eb-0183-4b7ad68fd40b
md"""
What are we looking at? The output is an array of ten values. For each of the ten digits, the array gives the probability that the example image depicts that digit.

(Keep in mind that we have not trained the model yet, so this output is completely random.)

For convenience, here is a function `best_label` that applies the model and gives the best output.
"""

# ╔═╡ f1e6abf8-1490-11eb-260a-7b51e1e5a8f6
function best_label(model, img)
	output = model(prepare(img))
	argmax(output)
end

# ╔═╡ aff40de8-212f-11eb-281c-7bd04a0094f2
md"""
This is how we can make predictions. Now, it would be nice if our predictions were actually based on some observations...
"""

# ╔═╡ a7857c1e-13a6-11eb-31b9-e32b5798ce52
md"""
## Training
"""

# ╔═╡ 1adb203a-2133-11eb-0d36-9773ad2608d1
function zip_data(images, labels)
	zip(prepare.(images), labels)
end

# ╔═╡ 39dbfada-2125-11eb-0e2a-63d44a37b2d2
@bind execute_training html"<input type=checkbox> Train model"

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

			grayscale(byte) = Gray(1 - byte / 256)
			map(1:size) do n
				img = [grayscale(readbyte()) for y in 1:cols, x in 1:rows]
				transpose(img)
			end
		end
	end
end

# ╔═╡ 67a3c41e-139e-11eb-24a0-9fa40b76e6c5
train_images = read_img_file(data_dir * train_img_filename)

# ╔═╡ 89c34bb6-1491-11eb-3a52-8b61e6e09772
example = train_images[1]

# ╔═╡ 3ce83ee4-148e-11eb-2bfb-df482e50104b
reduce_image(example)

# ╔═╡ 0b121b96-212d-11eb-3eb9-a5c108201575
prepare(example)

# ╔═╡ ef984272-148a-11eb-3c8e-b144778fbe45
input_size = length(prepare(example))

# ╔═╡ 5dd13e5c-212d-11eb-2711-55333b0eaba5
Dense(input_size, 10)

# ╔═╡ 090a58b8-2128-11eb-175c-c5f286918d04
function initialise_model()
	model = Chain(Dense(input_size, 10), softmax)
end

# ╔═╡ 665f820c-1491-11eb-0bc8-7b4b86868f68
initial_model = initialise_model()

# ╔═╡ 96699338-2135-11eb-0e1c-5f9e129f3fd0
let
	par = Flux.params(initial_model)
	sum(x -> sum(abs2, x), par)
end

# ╔═╡ 86ee4b6e-212e-11eb-3d9d-91d2ea56f74c
initial_model(prepare(example))

# ╔═╡ dcf8a7a0-1490-11eb-0cf4-cb9cf47b4f18
best_label(initial_model, example)

# ╔═╡ 8521b04e-13a0-11eb-2f17-57d3d45fff46
test_images = read_img_file(data_dir * test_img_filename)

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

# ╔═╡ 2a9e3b3a-2131-11eb-0427-3bf829eb489a
train_data = zip_data(train_images, train_labels)

# ╔═╡ 23ff37d6-2125-11eb-2214-134d00ed47c1
function train_model()
	model = initialise_model()
	
	parameters = Flux.params(model)
	optimiser = Flux.Optimise.Momentum()
	
	predict(img) = model(img)
	penalty() = sum(x -> sum(abs2, x), Flux.params(model))
	loss(img, label) = Flux.Losses.crossentropy(predict(img), label) + penalty()
	
	Flux.train!(loss, parameters, train_data, optimiser)
	
	model
end

# ╔═╡ 648a9a54-1494-11eb-1ea7-c188b90ea603
trained_model = if execute_training
	train_model()
else
	#if we're not training, we create a dummy model
	initialise_model()
end

# ╔═╡ b1983f64-2133-11eb-195f-19729b915ca9
best_label(trained_model, example)

# ╔═╡ 7df29cce-13a1-11eb-23bc-d1d73545b535
test_labels = read_label_file(data_dir * test_labels_filename)

# ╔═╡ f1a5b5e4-2133-11eb-147a-1784e80f4437
function accuracy(model)
	test_size = length(test_images)
	correct = count(1:test_size) do i
		img = test_images[i]
		label = test_labels[i]
		best_label(model, img) == label
	end
	
	correct / test_size
end

# ╔═╡ 8a4d5824-2134-11eb-2102-09c315642f0c
accuracy(initial_model)

# ╔═╡ 92941a9a-2134-11eb-3d66-294247f292e7
accuracy(trained_model)

# ╔═╡ Cell order:
# ╟─8337bd64-13aa-11eb-3259-3d3a8fb11287
# ╟─9eabb20a-13a3-11eb-1d38-495ad0d6953f
# ╠═6e4bd2f2-13a3-11eb-1c05-295e31903102
# ╠═a7f3be2c-1397-11eb-3461-317cabdde53b
# ╟─5bd9edc8-13aa-11eb-0078-95bb6449bf80
# ╟─6057bdec-13a2-11eb-36da-65c95bd6b651
# ╠═67a3c41e-139e-11eb-24a0-9fa40b76e6c5
# ╠═09ab0d56-13a1-11eb-1422-5b1c21afd3c8
# ╠═8521b04e-13a0-11eb-2f17-57d3d45fff46
# ╠═7df29cce-13a1-11eb-23bc-d1d73545b535
# ╟─4171703e-13a3-11eb-3a45-b1e612c6e75a
# ╟─1ebd61ea-148b-11eb-1cc1-45606fbcca6d
# ╠═5d3ccfdc-148b-11eb-11a0-e7261283bc9e
# ╠═89c34bb6-1491-11eb-3a52-8b61e6e09772
# ╠═3ce83ee4-148e-11eb-2bfb-df482e50104b
# ╟─dbe34bec-1489-11eb-392f-bf6de149552d
# ╠═6d651b22-148a-11eb-04fa-938d39f43c44
# ╠═27c945da-2136-11eb-24db-3589966f93e5
# ╟─cbb5a828-212c-11eb-1bb2-c9bf3b849b6c
# ╠═fc48fbea-212c-11eb-0a1c-0bb67c0b00f5
# ╠═0b121b96-212d-11eb-3eb9-a5c108201575
# ╟─03025a36-148c-11eb-28f8-a3a36a284d03
# ╠═5dd13e5c-212d-11eb-2711-55333b0eaba5
# ╟─54f8e3a0-148f-11eb-2ea3-cb515f35458e
# ╠═ef984272-148a-11eb-3c8e-b144778fbe45
# ╟─9c969326-148f-11eb-3ecc-6303da117d28
# ╠═8325aa84-1490-11eb-26e9-392669ca894d
# ╟─7e60aeb8-1490-11eb-0969-5d1734ac7540
# ╠═090a58b8-2128-11eb-175c-c5f286918d04
# ╟─5a9734ec-1491-11eb-39d2-27be371f2942
# ╠═665f820c-1491-11eb-0bc8-7b4b86868f68
# ╟─37b1c064-212f-11eb-1177-f3d0eac900cc
# ╠═86ee4b6e-212e-11eb-3d9d-91d2ea56f74c
# ╟─6f8b6daa-1491-11eb-0183-4b7ad68fd40b
# ╠═f1e6abf8-1490-11eb-260a-7b51e1e5a8f6
# ╠═dcf8a7a0-1490-11eb-0cf4-cb9cf47b4f18
# ╟─aff40de8-212f-11eb-281c-7bd04a0094f2
# ╟─a7857c1e-13a6-11eb-31b9-e32b5798ce52
# ╠═1adb203a-2133-11eb-0d36-9773ad2608d1
# ╠═2a9e3b3a-2131-11eb-0427-3bf829eb489a
# ╠═23ff37d6-2125-11eb-2214-134d00ed47c1
# ╠═96699338-2135-11eb-0e1c-5f9e129f3fd0
# ╟─39dbfada-2125-11eb-0e2a-63d44a37b2d2
# ╠═648a9a54-1494-11eb-1ea7-c188b90ea603
# ╠═b1983f64-2133-11eb-195f-19729b915ca9
# ╠═f1a5b5e4-2133-11eb-147a-1784e80f4437
# ╠═8a4d5824-2134-11eb-2102-09c315642f0c
# ╠═92941a9a-2134-11eb-3d66-294247f292e7
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
# ╟─ff802cf8-13a0-11eb-19d8-d5ffbb1983f6
