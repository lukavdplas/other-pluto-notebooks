### A Pluto.jl notebook ###
# v0.9.9

using Markdown

# ╔═╡ 96b2c622-af4b-11ea-37cb-b5632e724d05
md"""
# Rolling dice in pluto

Some example code for rolling dice. There is no practical reason to use this, it's more a simple code example. I'm not really trying to be efficient here, but more trying to create intuitive code.

## Our dice bag

We can start with some functions that will represent our dice. 
(Of course, this coud just be one function with the dice type as parameter. But I like the feeling of having a little collection of dice.)
"""

# ╔═╡ 1eb404a2-af4a-11ea-11e1-214483dcc78f
function d4()
	rand(1:4)
end

# ╔═╡ 3b8cf228-af4a-11ea-3937-c7fe2dcee1bc
function d6()
	rand(1:6)
end

# ╔═╡ 52766636-af4a-11ea-3a69-7f34857aa266
function d8()
	rand(1:8)
end

# ╔═╡ 5a0fd4fe-af4a-11ea-2d14-8b0fb7208299
function d10()
	rand(1:10)
end

# ╔═╡ 60bdb4a6-af4a-11ea-236c-2b9cfae18ca4
function d12()
	rand(1:12)
end

# ╔═╡ 6e37ec78-af4a-11ea-01d4-e33059535a14
function d20()
	rand(1:20)
end

# ╔═╡ ac4ab62e-b271-11ea-059b-3908d53aab9d
md"""
We can now roll dice like this:
"""

# ╔═╡ 4b4e4cb4-af4c-11ea-1baa-fb50d4b8247d
d20()

# ╔═╡ 202d7d66-af4c-11ea-2a32-31fd83d92fe8
md"""
## Adding rolls together

We can already use our functions to do more complicated arithmetic.
"""

# ╔═╡ 5da71558-af4c-11ea-029e-db04657f69e2
d6() + d6() + 3

# ╔═╡ 84fcf050-af4c-11ea-1e75-abd3ecfeaa5c
md"""
Now, we can also define our d100. For geometrical reasons, dice sets don't include a 100-sided die. Instead, they roll two d10s. For no reason at all, let's also do that in our program.
"""

# ╔═╡ 77c984cc-af4a-11ea-01cf-abd915a3c775
function d100()
	10 * d10() + d10()
end

# ╔═╡ 31127ba8-af4d-11ea-313e-dff79625c2f9
md"""
To roll multiple dice, I need to write `d6() + d6()`. That gets annoying if we need to roll a lot! Let's make a general roll function, where we can just say how many we want.
"""

# ╔═╡ 6a89e990-af4d-11ea-1e58-ff74a8e0ddc6
function roll_n(number, die)
	rolls = map(1:number) do n
		die()
	end
	
	sum(rolls)
end

# ╔═╡ 93e91a34-af4d-11ea-0449-9f35864e8f8f
roll_n(1,d6)

# ╔═╡ dc7b79cc-af4d-11ea-040e-ab3de56cd9e5
md"""
Let's make an even more general function, with which we can also roll different dice together, and add a fixed bonus.
"""

# ╔═╡ 0309e624-af4d-11ea-3ea9-47414ef97c60
function roll(; d4s = 0, d6s = 0, d8s = 0, d10s = 0, d12s = 0, d20s = 0, bonus = 0)
	sum([roll_n(d4s, d4), 
			roll_n(d6s, d6),
			roll_n(d8s, d8),
			roll_n(d10s, d10),
			roll_n(d12s, d12),
			roll_n(d20s, d20),
			bonus])
end

# ╔═╡ 295b7692-af4d-11ea-3cfa-818f7d9f3579
roll(d6s = 5, bonus = 4)

# ╔═╡ bf16db20-af4c-11ea-3f52-bd213e722c88
md"""
## Functions for our favourite rolls

We can also create some named functions for rolls we need to do often. Some examples:
"""

# ╔═╡ 455e38b8-af4f-11ea-2218-114b04a3454c
function health_potion()
	roll(d4s = 4, bonus = 4)
end

# ╔═╡ eacc937a-af4e-11ea-177b-c531e626c1ac
function fireball()
	roll(d6s = 8)
end

# ╔═╡ b1e1239a-af4f-11ea-013b-23a5e10ae56b
md"""
Of course, these functions can do more than just remember the parameters for the `roll()` function. For instance, a rogue could add whether or not they made a sneak attack with their dagger.
"""

# ╔═╡ ebfccbe2-af4f-11ea-2cdd-dd76623bb1d8
function sneak_attack_bonus()
	roll(d6s = 3)
end

# ╔═╡ fecb3164-af4f-11ea-2ddd-19e111dc6631
function dagger(; sneak = false)
	if sneak
		roll(d4s = 1, bonus = 3) + sneak_attack_bonus()
	else
		roll(d4s = 1, bonus = 3)
	end
end

# ╔═╡ 30b41da8-af50-11ea-29f7-ab16825eed8e
dagger(sneak = true)

# ╔═╡ Cell order:
# ╟─96b2c622-af4b-11ea-37cb-b5632e724d05
# ╠═1eb404a2-af4a-11ea-11e1-214483dcc78f
# ╠═3b8cf228-af4a-11ea-3937-c7fe2dcee1bc
# ╠═52766636-af4a-11ea-3a69-7f34857aa266
# ╠═5a0fd4fe-af4a-11ea-2d14-8b0fb7208299
# ╠═60bdb4a6-af4a-11ea-236c-2b9cfae18ca4
# ╠═6e37ec78-af4a-11ea-01d4-e33059535a14
# ╟─ac4ab62e-b271-11ea-059b-3908d53aab9d
# ╠═4b4e4cb4-af4c-11ea-1baa-fb50d4b8247d
# ╟─202d7d66-af4c-11ea-2a32-31fd83d92fe8
# ╠═5da71558-af4c-11ea-029e-db04657f69e2
# ╟─84fcf050-af4c-11ea-1e75-abd3ecfeaa5c
# ╠═77c984cc-af4a-11ea-01cf-abd915a3c775
# ╟─31127ba8-af4d-11ea-313e-dff79625c2f9
# ╠═6a89e990-af4d-11ea-1e58-ff74a8e0ddc6
# ╠═93e91a34-af4d-11ea-0449-9f35864e8f8f
# ╟─dc7b79cc-af4d-11ea-040e-ab3de56cd9e5
# ╠═0309e624-af4d-11ea-3ea9-47414ef97c60
# ╠═295b7692-af4d-11ea-3cfa-818f7d9f3579
# ╟─bf16db20-af4c-11ea-3f52-bd213e722c88
# ╠═455e38b8-af4f-11ea-2218-114b04a3454c
# ╠═eacc937a-af4e-11ea-177b-c531e626c1ac
# ╟─b1e1239a-af4f-11ea-013b-23a5e10ae56b
# ╠═ebfccbe2-af4f-11ea-2cdd-dd76623bb1d8
# ╠═fecb3164-af4f-11ea-2ddd-19e111dc6631
# ╠═30b41da8-af50-11ea-29f7-ab16825eed8e
