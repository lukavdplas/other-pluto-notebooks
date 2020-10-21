### A Pluto.jl notebook ###
# v0.11.14

using Markdown
using InteractiveUtils

# ╔═╡ 82c2133a-9aa2-11ea-2af0-6944df8fd507
using Random

# ╔═╡ 527f2082-9a9e-11ea-3cd5-3bd80dc638b5
md"""
# Text generation

I recommend that you read this notebook after you have read `reading-books`. That one provides a more general introduction to processing text, and we will be using many of the same functions.

This notebook focuses on the task of text generation. In this case, we don't really care about getting a particular message across. Instead, we will use it as a way to test a model of a language.

Essentially, we will build a model that is supposed to understand what English text normally looks like. To put our model to the test, we ask it to generate some text for us. The more normal the output looks, the better the model.

Let's start by importing some text. We import the novel _Emma_ by Jane Austen. This text provides enough words to build a small model, without overloading the memory.
"""

# ╔═╡ 2b46c964-9a9d-11ea-31c5-b3bc11d9a812
#all text
emma = begin
	raw_text = open("emma.txt") do file
		read(file, String)
	end
	
	#the txt file contains a lot of information about copyright and so on
	#so we filter that out first
	lines = split(raw_text, r"\n")
	relevant_lines = lines[32:end - 368]
	join(relevant_lines, "\n")
end ;

# ╔═╡ 9b3fff4c-9a9d-11ea-05ac-97edd38fc6bd
md"""
## Words

We will use a function `splitwords` to separate a text into word and punctuation tokens.
"""

# ╔═╡ 842e1104-9a9d-11ea-007a-1177ccf83a73
function splitwords(text) :: Array{String}
	#clean up whitespace
	cleantext = replace(text, r"\s+" => " ")
	
	#split on whitespace or other word boundaries
	tokens = split(cleantext, r"(\s|\b)")
end

# ╔═╡ 864effb6-9a9d-11ea-3cf3-09ba9dbc089a
words = splitwords(emma)

# ╔═╡ fa5c3b26-9aa7-11ea-20f2-c3c415c728c2
md"""
We count $(length(words)) words in total.
"""

# ╔═╡ 3eff1bce-9c4f-11ea-2e60-5176fce70953
md"""
## A word-based generator

We now have enough to make the simplest model we can think of. We will just keep randomly picking words from the text to generate a short paragraph.
"""

# ╔═╡ 7330c8d4-9c4f-11ea-23f8-17b9be0dc3e7
function generate_words(max_length)
	wordlist = map(1:max_length) do x
		rand(words)
	end
	join(wordlist, " ")
end

# ╔═╡ a9b2afa8-9c4f-11ea-25a5-c157ada79310
md"""
$(generate_words(100))
"""

# ╔═╡ ca545d6a-9c4f-11ea-07ec-ad4ae8e1ba64
md"""
This sound somewhat Austen-y, but it definitely doesn't look like real English.
"""

# ╔═╡ b7015ae0-9aa8-11ea-341e-19b682aef24e
md"""
## Making an ngram model

Just using words is only going to do so much for us. Clearly, the order in which words appear matters. So what to do?

We could just generate random paragraphs from the book, which would sound like proper English. But then we're just copying Austen. We need to make some kind of generalisations in order to produce something new.

To do this, we will look at small windows of context. We use this by defining an _ngram_ model. Ngrams are short fragments of a given length _n_ that appeared next to each other in the text.
"""

# ╔═╡ 5ca175f0-9a9f-11ea-176c-77c66121bc6a
function ngrams(sequence, n)
	#return an empty array if the sequence is too short
	if length(sequence) < n
		return []
	end
	
	starting_indices = 1:length(sequence) - (n - 1)
	ngrams = map(starting_indices) do i
		sequence[i:i+(n-1)]
	end
end

# ╔═╡ 8b12a80c-9aa9-11ea-3abf-e5e84bb1fd5f
md"""
We now have a list with all our bigrams. This is cool, but not very efficient. We want to be able to look up possible continuations quickly.
"""

# ╔═╡ 791e6a82-9aa9-11ea-2c87-17884cb3be96
function ngram_frequencies(all_ngrams)
	all_ngrams
	
	history = ngram -> ngram[1:end - 1]
	
	frequencies = Dict()
	for ngram in all_ngrams
		continuation_dict = get(frequencies, history(ngram), Dict())
		continuation_dict[last(ngram)] = get(continuation_dict, last(ngram), 0) + 1
		frequencies[history(ngram)] = continuation_dict
	end
	frequencies
end

# ╔═╡ 0fa61c2e-9aab-11ea-0b8c-8129498a31e3
bigram_frequencies = ngram_frequencies(ngrams(words, 2))

# ╔═╡ dd77f9c6-9c50-11ea-13e0-4f287ce02ddd
md"""
With this dictionary, we can look up all the words that followed "Emma".
"""

# ╔═╡ 6ba7b9de-9ab9-11ea-0f15-b1d4ac313677
bigram_frequencies[["Emma"]]

# ╔═╡ 4b510664-9ac7-11ea-2ecd-7d03e3b103c5
md"""
## Using ngrams for text generation
"""

# ╔═╡ a95f550a-9abb-11ea-1a9e-ab2ff090ec10
function choose_continuation(sequence, frequencies)
	#get dictionaries
	conts = frequencies[sequence]
	
	#make an array where each value is repeated every time for its frequency
	reps = token -> repeat([token], conts[token])
	repeated_tokens = [item for token in keys(conts) for item in reps(token)]
	
	#choose one randomly
	rand(repeated_tokens)
end

# ╔═╡ 0d8c7180-9ac3-11ea-0588-d398bd50d367
function choose_start(frequencies)
	#generate a dict with history frequencies
	history_count = history -> sum(values(frequencies[history]))
	history_freqs = Dict(hist => history_count(hist) for hist in keys(frequencies))
	
	#pick a value like before
	reps = history -> repeat([history], history_freqs[history])
	repeated_histories = [item for history in keys(history_freqs) for item in reps(history)]
	rand(repeated_histories)
end

# ╔═╡ 30c4868e-9ac4-11ea-03e5-b177d8aa6103
function generate(frequencies, max_length)
	
	sequence = choose_start(frequencies)
		
	n = length(rand(keys(frequencies))) + 1
	while length(sequence) < max_length
		history = sequence[end + 2 - n : end]
		cont = choose_continuation(history, frequencies)
		sequence = vcat(sequence, [cont])
	end
	
	join(sequence, " ")
end

# ╔═╡ 64a917a2-9ac5-11ea-1e37-ab6629ce2f79
begin
	bigram_sample = generate(bigram_frequencies, 100)
	md"""
	Let's generate some text!
	
	$(bigram_sample)
	"""
end

# ╔═╡ f30f172e-9ac7-11ea-3e8c-133817a3136e
md"""
We can compare this to a trigram and fourgram model, which should do better.
"""

# ╔═╡ 21a58050-9ac8-11ea-3650-6b9cf63b651a
trigram_frequencies = ngram_frequencies(ngrams(words, 3))

# ╔═╡ 329a79f6-9ac8-11ea-1417-1ffa794a9bea
begin
	trigram_sample = generate(trigram_frequencies, 100)
	md"""
	Generated by the trigram model:
	
	
	$(trigram_sample)
	"""
end

# ╔═╡ 9a0b173e-9ac9-11ea-3df4-dddf7b68d851
fourgram_frequencies = ngram_frequencies(ngrams(words,4))

# ╔═╡ a7cfc162-9ac9-11ea-088d-dfb7312102ad
begin
	fourgram_sample = generate(fourgram_frequencies, 100)
	md"""
	Generated by the fourgram model:
	
	
	$(fourgram_sample)
	"""
end

# ╔═╡ 0bb862fa-9acb-11ea-2400-951f7813685c
md"""
## Sentences

We treated our text as one big list of words. You could see that in our sentence generator: it just generated a stream of words without beginning or end.

A lot of the time, it makes sense to break up the text into sentences. For our generator, this will allow us to start at words that often begin sentences, and end when the sentence should be over.
"""

# ╔═╡ 1adfcd76-9c57-11ea-308b-cd604fc1f5ad
function is_sentence_boundary(index, words) ::Bool
	current_token = words[index]
	prev_token = index > 1 ? words[index-1] : ""
	
	if occursin(r"[\.\?!]", current_token)
		if prev_token != "Mr" && prev_token != "Mrs"
			return true
		else
			return false
		end
	else
		return false
	end
end

# ╔═╡ 2382258c-9c57-11ea-1416-b3392635d221
function split_sentences(words) #::Array{Array{String}}
	#get all indices with a begin or end
	boundary_indices = filter(i -> is_sentence_boundary(i, words), 1:length(words)-1)
	
	#indices of starts and stops
	starting_indices = vcat([1], boundary_indices .+ 1)
	stopping_indices = vcat(boundary_indices, [length(words)])
	
	#create slices for each start/stop index pair
	sentences = map(1:length(starting_indices)) do i
		start = starting_indices[i]
		stop = stopping_indices[i]
		sentence = words[start:stop]
	end
end

# ╔═╡ a96c8e36-9acb-11ea-0f11-8511d28802c2
sentences = split_sentences(words)

# ╔═╡ d0c0dcbc-9acb-11ea-0142-b92d971d8689
md"""
We count $(length(sentences)) sentences.
"""

# ╔═╡ 5ca3f06a-9acd-11ea-2046-f78228f33277
function pad_sentence(sentence, n)
	start_padding = repeat(["(START)"], n - 1)
	stop_padding = ["(STOP)"]
	vcat(start_padding, sentence, stop_padding)
end

# ╔═╡ 3c8e9a4a-9c57-11ea-0a2e-35f2c5fd7dfb
function sentence_ngrams(sentences, n)
	ngrams_per_sentence = map(sentences) do sent
		padded = pad_sentence(sent, n)
		ngrams(padded, n)
	end
	
	[ngram for ngrams in ngrams_per_sentence for ngram in ngrams]	
end

# ╔═╡ f234d0f8-9ace-11ea-213f-1d2a09db9ed7
sentence_ngram_frequencies = ngram_frequencies(sentence_ngrams(sentences, 4))

# ╔═╡ 404cbd3c-9acf-11ea-353e-67a257df259a
function generate_sentence(frequencies)
	n = length(rand(keys(frequencies))) + 1
	sentence = repeat(["(START)"], n - 1)
		
	while sentence[end] != "(STOP)"
		history = sentence[end + 2 - n : end]
		cont = choose_continuation(history, frequencies)
		sentence = vcat(sentence, [cont])
	end
	
	#remove padding
	sentence = sentence[n : end - 1]
	
	#join
	join(sentence, " ")
end

# ╔═╡ 1e469702-9ad0-11ea-0736-0bbc5614f973
map(1:10) do i
	generate_sentence(sentence_ngram_frequencies)
end

# ╔═╡ Cell order:
# ╟─527f2082-9a9e-11ea-3cd5-3bd80dc638b5
# ╠═2b46c964-9a9d-11ea-31c5-b3bc11d9a812
# ╟─9b3fff4c-9a9d-11ea-05ac-97edd38fc6bd
# ╠═842e1104-9a9d-11ea-007a-1177ccf83a73
# ╠═864effb6-9a9d-11ea-3cf3-09ba9dbc089a
# ╟─fa5c3b26-9aa7-11ea-20f2-c3c415c728c2
# ╟─3eff1bce-9c4f-11ea-2e60-5176fce70953
# ╠═7330c8d4-9c4f-11ea-23f8-17b9be0dc3e7
# ╠═a9b2afa8-9c4f-11ea-25a5-c157ada79310
# ╟─ca545d6a-9c4f-11ea-07ec-ad4ae8e1ba64
# ╟─b7015ae0-9aa8-11ea-341e-19b682aef24e
# ╠═5ca175f0-9a9f-11ea-176c-77c66121bc6a
# ╟─8b12a80c-9aa9-11ea-3abf-e5e84bb1fd5f
# ╠═791e6a82-9aa9-11ea-2c87-17884cb3be96
# ╠═0fa61c2e-9aab-11ea-0b8c-8129498a31e3
# ╟─dd77f9c6-9c50-11ea-13e0-4f287ce02ddd
# ╠═6ba7b9de-9ab9-11ea-0f15-b1d4ac313677
# ╟─4b510664-9ac7-11ea-2ecd-7d03e3b103c5
# ╠═82c2133a-9aa2-11ea-2af0-6944df8fd507
# ╠═a95f550a-9abb-11ea-1a9e-ab2ff090ec10
# ╠═0d8c7180-9ac3-11ea-0588-d398bd50d367
# ╠═30c4868e-9ac4-11ea-03e5-b177d8aa6103
# ╟─64a917a2-9ac5-11ea-1e37-ab6629ce2f79
# ╟─f30f172e-9ac7-11ea-3e8c-133817a3136e
# ╠═21a58050-9ac8-11ea-3650-6b9cf63b651a
# ╟─329a79f6-9ac8-11ea-1417-1ffa794a9bea
# ╠═9a0b173e-9ac9-11ea-3df4-dddf7b68d851
# ╟─a7cfc162-9ac9-11ea-088d-dfb7312102ad
# ╟─0bb862fa-9acb-11ea-2400-951f7813685c
# ╠═1adfcd76-9c57-11ea-308b-cd604fc1f5ad
# ╠═2382258c-9c57-11ea-1416-b3392635d221
# ╠═a96c8e36-9acb-11ea-0f11-8511d28802c2
# ╟─d0c0dcbc-9acb-11ea-0142-b92d971d8689
# ╠═5ca3f06a-9acd-11ea-2046-f78228f33277
# ╠═3c8e9a4a-9c57-11ea-0a2e-35f2c5fd7dfb
# ╠═f234d0f8-9ace-11ea-213f-1d2a09db9ed7
# ╠═404cbd3c-9acf-11ea-353e-67a257df259a
# ╠═1e469702-9ad0-11ea-0736-0bbc5614f973
