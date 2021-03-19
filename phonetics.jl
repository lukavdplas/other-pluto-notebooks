### A Pluto.jl notebook ###
# v0.14.0

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

# ╔═╡ b9525aa6-8666-11eb-36b2-d1bd38e7e220
using Plots

# ╔═╡ 991d3ef2-8668-11eb-028c-97116fa32dac
using DSP

# ╔═╡ 3021bf9e-8664-11eb-1778-53a498f49fce
begin
	import Base: show, get
	import Random: randstring
	import Markdown: htmlesc, withtag
	
	struct Microphone end
	
	function show(io::IO, ::MIME"text/html", microphone::Microphone)
		mic_id = randstring('a':'z')
		mic_btn_id = randstring('a':'z')
		microphone
		withtag(() -> (), io, :audio, :id => mic_id)
		print(io, """<input type="button" id="$mic_btn_id" class="mic-button stop" value="Stop">""")
		withtag(io, :script) do 
        print(io, """
            const player = document.getElementById('$mic_id');
            const stop = document.getElementById('$mic_btn_id');
        
            const handleSuccess = function(stream) {
            const context = new AudioContext({ sampleRate: 44100 });
            const analyser = context.createAnalyser();
            const source = context.createMediaStreamSource(stream);
        
            source.connect(analyser);
            
            const bufferLength = analyser.frequencyBinCount;
            
            let dataArray = new Float32Array(bufferLength);
            let animFrame;
            
            const streamAudio = () => {
                animFrame = requestAnimationFrame(streamAudio);
                analyser.getFloatTimeDomainData(dataArray);
                player.value = dataArray;
                player.dispatchEvent(new CustomEvent("input"));
            }
        
            streamAudio();
        
            stop.onclick = e => {
                source.disconnect(analyser);
                cancelAnimationFrame(animFrame);
            }
            }
        
            navigator.mediaDevices.getUserMedia({ audio: true, video: false })
            .then(handleSuccess)
        """
        )
		end
		withtag(io, :style) do 
			print(io, """
				.mic-button {
					border: none;
					border-radius: 6px;
					color: white;
					padding: 15px 32px;
					text-align: center;
					text-decoration: none;
					display: inline-block;
					font-size: 16px;
					font-family: "Alegreya Sans", sans-serif;
					margin: 4px 2px;
					cursor: pointer;
				}
				.mic-button.stop {
					background-color: darkred;
				}
				.mic-button.start {
					background-color: darkgreen;
				}
			"""
			)
		end
	end
	
	get(microphone::Microphone) = microphone
end

# ╔═╡ 828bad7a-8665-11eb-04b6-1f06c7145b2a
@bind audio Microphone()

# ╔═╡ 9fa3ae19-946c-4687-996d-646f32a20b83
audio

# ╔═╡ d5355124-8666-11eb-1baa-dfbf801442ac
plot(
	audio,
	label = nothing,
	ylims = (-0.1, 0.1)
)

# ╔═╡ c332b5f5-c74e-4c3b-a044-a6badebb8b67
makespectogram = false

# ╔═╡ a1023ce6-8668-11eb-21f0-9f7f6867e8ff
spectogram = if makespectogram
	DSP.Periodograms.spectrogram(audio)
end

# ╔═╡ a32b7232-8669-11eb-15a5-3ba680e5f5cb
samplerate = 44100

# ╔═╡ ee73c11e-8668-11eb-35e9-45446612b2fa
if makespectogram
	let
		times = spectogram.time ./ samplerate
		frequencies = spectogram.freq .* samplerate
		power = transpose(spectogram.power)

		heatmap(
			times, frequencies, power,
			xlabel = "time (s)", ylabel = "frequency"
		)
	end
end

# ╔═╡ Cell order:
# ╠═3021bf9e-8664-11eb-1778-53a498f49fce
# ╠═828bad7a-8665-11eb-04b6-1f06c7145b2a
# ╠═9fa3ae19-946c-4687-996d-646f32a20b83
# ╠═b9525aa6-8666-11eb-36b2-d1bd38e7e220
# ╠═d5355124-8666-11eb-1baa-dfbf801442ac
# ╠═991d3ef2-8668-11eb-028c-97116fa32dac
# ╠═c332b5f5-c74e-4c3b-a044-a6badebb8b67
# ╠═a1023ce6-8668-11eb-21f0-9f7f6867e8ff
# ╠═a32b7232-8669-11eb-15a5-3ba680e5f5cb
# ╠═ee73c11e-8668-11eb-35e9-45446612b2fa
