### A Pluto.jl notebook ###
# v0.9.9

using Markdown
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.peek, el) ? Base.peek(el) : missing
        el
    end
end

# ╔═╡ 28e38194-b492-11ea-3f18-4ff371bb60bb
md"""
## Making a character

Characters have four scores: strength, willpower, intellect, vitality. They also have a health score.
"""

# ╔═╡ 025d9f5e-b491-11ea-197c-b71870ef1e34
mutable struct Character
	strength::Int
	willpower::Int
	intellect::Int
	vitality::Int
	tactic::Function
end

# ╔═╡ f7b9f606-b49c-11ea-1c64-2d8977fbd1b0
function random_stats()
	divide_points = map(1:40) do i
		rand(1:4)
	end
	
	stats = map(1:4) do stat
		sum(map(assignment -> assignment == stat, divide_points))
	end
	
end

# ╔═╡ 443e67b0-b492-11ea-3536-8d94ac6c2f21
md"""
## Actions
These are actions that a character can take.
"""

# ╔═╡ 0bc01edc-b493-11ea-3931-0b8a55b54ee5
function sword!(self, enemy)
	#try to reduce the enemy's vitality using your strength
	#resisted by enemy willpower
	
	bonus = self.strength - enemy.willpower
	damage = max(0, rand(1:4) + bonus)
	enemy.vitality = max(0, enemy.vitality - damage)
end

# ╔═╡ 52e0ae4c-b493-11ea-3420-15738150ac29
function firestrike!(self, enemy)
	#try to reduce enemy vitality using your intellect
	
	bonus = self.intellect - enemy.willpower
	damage = max(0, rand(1:4) + bonus)
	enemy.vitality = max(0, enemy.vitality - damage)
end

# ╔═╡ 139cdd8e-b493-11ea-1c9f-05ac3e99f987
function insult!(self, enemy)
	#try to reduce enemy willpower using your own
	#if the enemy's willpower is higher, you lose willpower yourself
	
	bonus = self.willpower - enemy.willpower
	damage = rand(1:4)
	
	if bonus > 0
		enemy.willpower = max(0, enemy.willpower - damage)
	elseif bonus < 0
		self.willpower = max(0, enemy.willpower - damage)
	end
end

# ╔═╡ 2f321ae2-b497-11ea-32d1-d7f6e54586cc
function heal!(self, enemy)
	#restore your own vitality and do no damage
	
	heal = rand(1:4)
	self.vitality = min(20, self.vitality + heal)
end

# ╔═╡ bb0e8000-b4a1-11ea-0fc7-b1d4a1ba800b
md"""
For later convenience: a list of all actions and descriptions for each.
"""

# ╔═╡ a92df2de-b498-11ea-17a0-aff404b60e31
all_actions = [sword!, firestrike!, insult!, heal!]

# ╔═╡ 5dfef844-b49d-11ea-2b32-b5517a5eb6c8
function describe(action)
	names = Dict([
			sword! => "attacks with their sword",
			firestrike! => "casts firestrike",
			insult! => "insults their opponent", 
			heal! => "heals themself"])
	
	names[action]
end

# ╔═╡ 8b1a6b64-b497-11ea-2218-d99f5a3e9aa9
md"""
## Plan your battle

This is where you can make decisions for your battle! Your decisions are programmed as a function that takes yourself as input, and gives one of the four actions as output. It will be run again each turn, so each turn you will get your current state as input, and say what action you want to take.

The most basic function is the random function, as below. It just does a random action each turn.
"""

# ╔═╡ bfc4bc72-b497-11ea-29be-7f82d8f1123d
function randomaction(self)
	choice = rand(all_actions)
end

# ╔═╡ 722d8da0-b491-11ea-022f-37f940ff8271
function random_character()
	stats = random_stats()
	Character(stats..., randomaction)
end

# ╔═╡ 0a269952-b4a2-11ea-28e2-ddde50de80fe
md"""
You can probably think of a better tactic. Write it in the function below.
"""

# ╔═╡ 6f5a1ff6-b498-11ea-03f6-d5a90c5876c9
function yourtactic(self)
	randomaction(self)
end

# ╔═╡ fd5e8f18-b497-11ea-3edc-83122d77e675
md"""
## Execute a battle
"""

# ╔═╡ fd72dc92-b49d-11ea-2455-c904e87084d5
join(["the hero", describe(heal!)], " ")

# ╔═╡ 0d6accd2-b498-11ea-1c74-3531727f1708
function duel!(you, opponent)
	#keep a list of descriptions
	chronicle = []
	
	#a duel has up to 20 turns
	for turn in 1:20
		#check if hero is still alive, if so do their turn
		if you.vitality > 0
			#the hero's turn
			your_action! = you.tactic(you)
			if your_action! in all_actions
				your_action!(you, opponent)
				line = join(["The hero", describe(your_action!)], " ")
				push!(chronicle, line)
			else
				#in case of illegal actions
				line = "The hero tried to do something weird"
				push!(chronicle, line)
			end
		else
			#the villain won
			conclusion = "The villain won!"
			push!(chronicle, conclusion)
			return opponent, chronicle
		end
		
		#check if villain is still alive, if so do their turn
		if opponent.vitality > 0
			#the villain's turn
			opponent_action! = opponent.tactic(opponent)
			opponent_action!(opponent, you)
			line = join(["The villain", describe(opponent_action!)], " ")
			push!(chronicle, line)
		else
			#the hero won
			conclusion = "The hero won!"
			push!(chronicle, conclusion)
			return you, chronicle
		end
	end
	
	conclusion = "A draw!"
	push!(chronicle, conclusion)
	return nothing, chronicle
end

# ╔═╡ 8a27c166-b499-11ea-1cc9-1d8d7e330f17
function fightrandom!(tactic)
	hero = Character(random_stats()..., tactic)
	villain = random_character()
	
	winner, chronicle = duel!(hero, villain)
	
	return chronicle
end

# ╔═╡ 91ff67da-b49a-11ea-2e4b-a3794dd59096
@bind go html"<button>Fight!</button>"

# ╔═╡ c89f2b4a-b49a-11ea-2c9b-99f82e9531e9
begin
	go
	fightrandom!(yourtactic)
end

# ╔═╡ daadc672-b4a2-11ea-04cb-05f268a37de2
md"""
### Scoring your tactic

A summary of your total score over 100 matches:
"""

# ╔═╡ e5a308e4-b4a2-11ea-3ea1-158118c17128
function score_tactic(tactic)
	outcomes = map(1:100) do i
		hero = Character(random_stats()..., tactic)
		villain = random_character()
		winner, chronicle = duel!(hero, villain)
		if winner == hero
			"won"
		elseif winner == villain
			"lost"
		else
			"draw"
		end
	end
	
	total_wins = count(x -> x == "won", outcomes)
	total_losses = count(x -> x == "lost", outcomes)
	total_draws = count(x -> x == "draw", outcomes)
	
	md"""
	Times won: $(total_wins)
	
	Times lost: $(total_losses)
	
	Times ended in draw: $(total_draws)
	"""
end

# ╔═╡ 19d81910-b4a3-11ea-066e-3932248b57f0
score_tactic(yourtactic)

# ╔═╡ Cell order:
# ╟─28e38194-b492-11ea-3f18-4ff371bb60bb
# ╠═025d9f5e-b491-11ea-197c-b71870ef1e34
# ╠═f7b9f606-b49c-11ea-1c64-2d8977fbd1b0
# ╠═722d8da0-b491-11ea-022f-37f940ff8271
# ╟─443e67b0-b492-11ea-3536-8d94ac6c2f21
# ╠═0bc01edc-b493-11ea-3931-0b8a55b54ee5
# ╠═52e0ae4c-b493-11ea-3420-15738150ac29
# ╠═139cdd8e-b493-11ea-1c9f-05ac3e99f987
# ╠═2f321ae2-b497-11ea-32d1-d7f6e54586cc
# ╟─bb0e8000-b4a1-11ea-0fc7-b1d4a1ba800b
# ╠═a92df2de-b498-11ea-17a0-aff404b60e31
# ╠═5dfef844-b49d-11ea-2b32-b5517a5eb6c8
# ╟─8b1a6b64-b497-11ea-2218-d99f5a3e9aa9
# ╠═bfc4bc72-b497-11ea-29be-7f82d8f1123d
# ╟─0a269952-b4a2-11ea-28e2-ddde50de80fe
# ╠═6f5a1ff6-b498-11ea-03f6-d5a90c5876c9
# ╟─fd5e8f18-b497-11ea-3edc-83122d77e675
# ╠═fd72dc92-b49d-11ea-2455-c904e87084d5
# ╠═0d6accd2-b498-11ea-1c74-3531727f1708
# ╠═8a27c166-b499-11ea-1cc9-1d8d7e330f17
# ╟─91ff67da-b49a-11ea-2e4b-a3794dd59096
# ╠═c89f2b4a-b49a-11ea-2c9b-99f82e9531e9
# ╟─daadc672-b4a2-11ea-04cb-05f268a37de2
# ╠═19d81910-b4a3-11ea-066e-3932248b57f0
# ╠═e5a308e4-b4a2-11ea-3ea1-158118c17128
