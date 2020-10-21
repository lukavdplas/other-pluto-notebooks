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

# ╔═╡ a27cd2d2-05b2-11eb-00ec-859fa591c011
md"""
# Functions
"""

# ╔═╡ 21950ee6-07e2-11eb-27ed-93fc387df1b9
abstract type Graph end

# ╔═╡ 21294238-05a8-11eb-3bfc-bbaeaac79e26
struct BasicGraph <: Graph
	nodes::Array{Int}
	edges::Array{Tuple{Int,Int}}
	gems::Dict{Int,Int}
	directed::Bool
	
	BasicGraph(nodes, edges, gems, directed) = new(nodes, edges, gems, directed)
end

# ╔═╡ d30d877a-05a8-11eb-135f-fd79d18dfe04
function edge(g::Graph, from, to)
	if (from, to) in g.edges
		return true
	elseif !(g.directed) && ((to, from) in g.edges)
		return true
	else
		return false
	end
end

# ╔═╡ b3312d6c-05a8-11eb-2c72-bfc3546db5aa
function neighbours(g::Graph, node)
	filter(g.nodes) do node2
		node2 != node && edge(g, node, node2)
	end
end

# ╔═╡ a84f12ce-05a8-11eb-0668-9758a7ccec4a
function distance(g::Graph, from::Int, to::Int)
	if typeof(g) == BasicGraph
		if from == to
			return 0
		end

		old = []
		frontier = [from]
		for distance in 1:length(g.edges)
			new_frontier = []
			for node in frontier
				for new_node in neighbours(g, node)
					if new_node == to
						return distance
					elseif !(new_node in frontier || new_node in old)
						append!(new_frontier, [new_node])
					end
				end
			end
			old = append!(old, frontier)
			frontier = new_frontier
		end

		return Inf
	else
		return g.dist[from, to]
	end
	
end

# ╔═╡ d77115a0-07df-11eb-181b-d55f1d6cc99c
function distance_matrix(g::BasicGraph)
	distances = zeros(Int64, length(g.nodes), length(g.nodes))
	
	for node1 in g.nodes
		for node2 in g.nodes
			distances[node1, node2] = distance(g, node1, node2)
		end
	end
	
	distances
end

# ╔═╡ ff7af000-07e1-11eb-23a9-1f1841374bd7
struct FastGraph <: Graph
	nodes::Array{Int}
	edges::Array{Tuple{Int,Int}}
	gems::Dict{Int,Int}
	directed::Bool
	dist::Array{Int,2}
	
	#construct a new graph
	FastGraph(size, edges, gems,directed) = let
		basic = BasicGraph(1:size, edges, gems,directed)
		distances = distance_matrix(basic)
		new(1:size, edges, gems, directed, distances)
	end
	
	#for making copies
	FastGraph(nodes, e, g, dir, dist) = new(nodes, e, g, dir, dist)
end

# ╔═╡ bb5da710-05ab-11eb-23c9-c35f1bed8bdd
function gems(g::Graph, node)
	g.gems[node]
end

# ╔═╡ 3f17a212-05a8-11eb-1118-d90f42c97e12
function move(g::Graph, from, to)
	d = distance(g, from, to)
	if d > gems(g, from)
		return nothing
	else
		#move gems
		new_gems = map(g.nodes) do node
			if node == from
				node => gems(g, node) - d
			elseif node == to
				node => gems(g, node) + d
			else
				node => gems(g, node)
			end
		end
		
		#construct resulting graph
		if typeof(g) == FastGraph
			return FastGraph(g.nodes, g.edges, Dict(new_gems), g.directed, g.dist)
		else
			return BasicGraph(g.nodes, g.edges, Dict(new_gems), g.directed)
		end
	end
end

# ╔═╡ 4eb4cc50-05ac-11eb-3929-0991223ba7eb
function all_moves(g)
	moves = []
	for from in g.nodes
		for to in g.nodes
			if from != to
				new_graph = move(g, from, to)
				if new_graph != nothing
					append!(moves, [(from, to)])
				end
			end
		end
	end
	return moves
end

# ╔═╡ 6fb9efa4-05b4-11eb-102f-576f9ac311ce
function error(state::Graph, goal::Graph)
	differences = map(state.nodes) do node
		abs(gems(state, node) - gems(goal, node))
	end
	sum(differences)
end

# ╔═╡ 77003efa-05b2-11eb-0f6c-7df1d93fb7f3
md"""
# Graph specifications
"""

# ╔═╡ 6b966daa-05a8-11eb-1f56-4b777ec437ba
nodes = 8

# ╔═╡ 72c828de-05a8-11eb-014f-fd65b68c2305
edges = [(1,2), (2,3), (3,4), (5,6), (6,7), (7,8), (3, 6)]

# ╔═╡ 9291c3ac-05ab-11eb-2275-87a73fbdbb91
start_gems = Dict(
	1 => 5, 
	2 => 0, 
	3 => 0, 
	4 => 2, 
	5 => 4,
	6 => 0,
	7 => 6,
	8 => 3
)

# ╔═╡ 47753e80-05b0-11eb-0424-a772a3c020e8
goal_gems = Dict(
	1 => 4, 
	2 => 3, 
	3 => 0, 
	4 => 4, 
	5 => 5,
	6 => 0,
	7 => 4,
	8 => 0
)

# ╔═╡ b2b9cb9e-0631-11eb-0405-6144add60061
total_moves = 6

# ╔═╡ 121f95a6-065e-11eb-25bb-335b5f1a17c7
directed = false

# ╔═╡ 92e6f276-05a8-11eb-3b8f-6948622e18c6
g = FastGraph(nodes, edges, start_gems, directed)

# ╔═╡ dcbeef76-05ac-11eb-357f-93321d904dbb
function solve(start::Graph, goal::Graph, max_moves::Int; history = [])
	if max_moves == 0
		if start.gems == goal.gems
			return []
		else
			return nothing
		end
	end
	
	moves = all_moves(start)
	
	heuristic(m) = error(move(start, m...), goal)
	sort!(moves, by=heuristic)
	
	for (from, to) in moves
		if g.directed || !((to, from) in history) #don't undo moves
			hist = [history..., (from, to)]
			next = move(start, from, to)
			solved = solve(next, goal, max_moves - 1, history = hist)
			if solved != nothing
				return [(from, to), solved...]
			end
		end
	end
end

# ╔═╡ 7c2da0c2-05b0-11eb-3e9b-cbb4960deb01
goal = FastGraph(nodes, edges, goal_gems, directed)

# ╔═╡ 9749dc66-05b2-11eb-1b7e-4b9bc4ae7750
md"""
## Solution
"""

# ╔═╡ 90250f9e-0631-11eb-125e-b12e310ef064
@bind search html"<input type=checkbox> search for solution"

# ╔═╡ 43eeec5c-05b0-11eb-0a63-0bdedeefc269
if search
	solve(g, goal, total_moves)
end

# ╔═╡ Cell order:
# ╟─a27cd2d2-05b2-11eb-00ec-859fa591c011
# ╠═21950ee6-07e2-11eb-27ed-93fc387df1b9
# ╠═21294238-05a8-11eb-3bfc-bbaeaac79e26
# ╠═ff7af000-07e1-11eb-23a9-1f1841374bd7
# ╠═d30d877a-05a8-11eb-135f-fd79d18dfe04
# ╠═b3312d6c-05a8-11eb-2c72-bfc3546db5aa
# ╠═a84f12ce-05a8-11eb-0668-9758a7ccec4a
# ╠═d77115a0-07df-11eb-181b-d55f1d6cc99c
# ╠═bb5da710-05ab-11eb-23c9-c35f1bed8bdd
# ╠═3f17a212-05a8-11eb-1118-d90f42c97e12
# ╠═4eb4cc50-05ac-11eb-3929-0991223ba7eb
# ╠═6fb9efa4-05b4-11eb-102f-576f9ac311ce
# ╠═dcbeef76-05ac-11eb-357f-93321d904dbb
# ╟─77003efa-05b2-11eb-0f6c-7df1d93fb7f3
# ╠═6b966daa-05a8-11eb-1f56-4b777ec437ba
# ╠═72c828de-05a8-11eb-014f-fd65b68c2305
# ╠═9291c3ac-05ab-11eb-2275-87a73fbdbb91
# ╠═47753e80-05b0-11eb-0424-a772a3c020e8
# ╠═b2b9cb9e-0631-11eb-0405-6144add60061
# ╠═121f95a6-065e-11eb-25bb-335b5f1a17c7
# ╠═92e6f276-05a8-11eb-3b8f-6948622e18c6
# ╠═7c2da0c2-05b0-11eb-3e9b-cbb4960deb01
# ╟─9749dc66-05b2-11eb-1b7e-4b9bc4ae7750
# ╟─90250f9e-0631-11eb-125e-b12e310ef064
# ╠═43eeec5c-05b0-11eb-0a63-0bdedeefc269
