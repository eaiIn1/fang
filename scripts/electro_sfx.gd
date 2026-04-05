extends RefCounted
class_name ElectroSfx

const MIX_RATE := 32000


static func create_place_sound() -> AudioStreamWAV:
	return _synthesize([
		{
			"start": 0.0,
			"duration": 0.11,
			"wave": "square",
			"start_freq": 720.0,
			"end_freq": 440.0,
			"volume": 0.42,
			"attack": 0.003,
			"release": 0.05,
			"duty": 0.42
		},
		{
			"start": 0.0,
			"duration": 0.08,
			"wave": "triangle",
			"start_freq": 360.0,
			"end_freq": 220.0,
			"volume": 0.16,
			"attack": 0.002,
			"release": 0.03
		}
	], 0.13)


static func create_clear_sound() -> AudioStreamWAV:
	return _synthesize([
		{
			"start": 0.0,
			"duration": 0.07,
			"wave": "square",
			"start_freq": 880.0,
			"end_freq": 880.0,
			"volume": 0.34,
			"attack": 0.003,
			"release": 0.03,
			"duty": 0.34
		},
		{
			"start": 0.055,
			"duration": 0.07,
			"wave": "square",
			"start_freq": 1174.0,
			"end_freq": 1174.0,
			"volume": 0.34,
			"attack": 0.003,
			"release": 0.03,
			"duty": 0.34
		},
		{
			"start": 0.11,
			"duration": 0.11,
			"wave": "triangle",
			"start_freq": 1568.0,
			"end_freq": 1760.0,
			"volume": 0.28,
			"attack": 0.002,
			"release": 0.05
		}
	], 0.25)


static func create_refill_sound() -> AudioStreamWAV:
	return _synthesize([
		{
			"start": 0.0,
			"duration": 0.045,
			"wave": "square",
			"start_freq": 660.0,
			"end_freq": 660.0,
			"volume": 0.26,
			"attack": 0.002,
			"release": 0.02,
			"duty": 0.38
		},
		{
			"start": 0.05,
			"duration": 0.045,
			"wave": "square",
			"start_freq": 880.0,
			"end_freq": 880.0,
			"volume": 0.26,
			"attack": 0.002,
			"release": 0.02,
			"duty": 0.38
		},
		{
			"start": 0.1,
			"duration": 0.06,
			"wave": "triangle",
			"start_freq": 1174.0,
			"end_freq": 1318.0,
			"volume": 0.22,
			"attack": 0.002,
			"release": 0.025
		}
	], 0.18)


static func create_game_over_sound() -> AudioStreamWAV:
	return _synthesize([
		{
			"start": 0.0,
			"duration": 0.18,
			"wave": "saw",
			"start_freq": 340.0,
			"end_freq": 240.0,
			"volume": 0.25,
			"attack": 0.002,
			"release": 0.05
		},
		{
			"start": 0.16,
			"duration": 0.18,
			"wave": "square",
			"start_freq": 220.0,
			"end_freq": 140.0,
			"volume": 0.28,
			"attack": 0.003,
			"release": 0.08,
			"duty": 0.46
		},
		{
			"start": 0.0,
			"duration": 0.34,
			"wave": "noise",
			"start_freq": 1.0,
			"end_freq": 1.0,
			"volume": 0.045,
			"attack": 0.002,
			"release": 0.14
		}
	], 0.38)


static func create_ui_sound() -> AudioStreamWAV:
	return _synthesize([
		{
			"start": 0.0,
			"duration": 0.05,
			"wave": "square",
			"start_freq": 980.0,
			"end_freq": 760.0,
			"volume": 0.22,
			"attack": 0.001,
			"release": 0.02,
			"duty": 0.32
		},
		{
			"start": 0.0,
			"duration": 0.03,
			"wave": "noise",
			"start_freq": 1.0,
			"end_freq": 1.0,
			"volume": 0.05,
			"attack": 0.001,
			"release": 0.015
		}
	], 0.07)


static func create_hover_sound() -> AudioStreamWAV:
	return _synthesize([
		{
			"start": 0.0,
			"duration": 0.04,
			"wave": "triangle",
			"start_freq": 1320.0,
			"end_freq": 1180.0,
			"volume": 0.16,
			"attack": 0.001,
			"release": 0.018
		},
		{
			"start": 0.01,
			"duration": 0.03,
			"wave": "square",
			"start_freq": 1760.0,
			"end_freq": 1480.0,
			"volume": 0.08,
			"attack": 0.001,
			"release": 0.012,
			"duty": 0.28
		}
	], 0.055)


static func create_ambient_sound() -> AudioStreamWAV:
	var duration := 4.0
	var frame_count := maxi(1, int(ceil(duration * MIX_RATE)))
	var pcm_data := PackedByteArray()
	pcm_data.resize(frame_count * 2)

	for frame in range(frame_count):
		var t := float(frame) / MIX_RATE
		var drone_a := sin(TAU * 36.0 * t) * (0.62 + 0.38 * sin(TAU * 0.5 * t) * sin(TAU * 0.5 * t))
		var drone_b := sin(TAU * 72.0 * t + 0.08 * sin(TAU * 2.0 * t)) * (0.5 + 0.5 * sin(TAU * 0.75 * t + 0.7) * sin(TAU * 0.75 * t + 0.7))
		var pad := sin(TAU * 108.0 * t) * (0.45 + 0.55 * sin(TAU * 4.0 * t) * sin(TAU * 4.0 * t))
		var sparkle := sin(TAU * 216.0 * t + 0.12 * sin(TAU * 1.0 * t)) * (0.25 + 0.75 * sin(TAU * 8.0 * t) * sin(TAU * 8.0 * t))
		var sample_value := drone_a * 0.18 + drone_b * 0.12 + pad * 0.08 + sparkle * 0.026
		sample_value = clampf(sample_value, -0.9, 0.9)

		var sample_int := int(round(sample_value * 32767.0))
		var encoded := sample_int if sample_int >= 0 else 65536 + sample_int
		pcm_data[frame * 2] = encoded & 0xFF
		pcm_data[frame * 2 + 1] = (encoded >> 8) & 0xFF

	return _create_stream(pcm_data, AudioStreamWAV.LOOP_FORWARD, 0, frame_count)


static func _synthesize(segments: Array[Dictionary], duration: float) -> AudioStreamWAV:
	var frame_count := maxi(1, int(ceil(duration * MIX_RATE)))
	var pcm_data := PackedByteArray()
	pcm_data.resize(frame_count * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = 74251

	for frame in range(frame_count):
		var t := float(frame) / MIX_RATE
		var sample_value := 0.0
		for segment in segments:
			sample_value += _sample_segment(segment, t, rng)

		sample_value = clampf(sample_value, -0.95, 0.95)
		var sample_int := int(round(sample_value * 32767.0))
		var encoded := sample_int if sample_int >= 0 else 65536 + sample_int
		pcm_data[frame * 2] = encoded & 0xFF
		pcm_data[frame * 2 + 1] = (encoded >> 8) & 0xFF

	return _create_stream(pcm_data)


static func _create_stream(
	pcm_data: PackedByteArray,
	loop_mode: int = AudioStreamWAV.LOOP_DISABLED,
	loop_begin: int = 0,
	loop_end: int = 0
) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	stream.loop_mode = loop_mode
	stream.loop_begin = max(0, loop_begin)
	stream.loop_end = max(0, loop_end)
	stream.data = pcm_data
	return stream


static func _sample_segment(segment: Dictionary, t: float, rng: RandomNumberGenerator) -> float:
	var start_time: float = segment.get("start", 0.0)
	var segment_duration: float = segment.get("duration", 0.0)
	if t < start_time or t > start_time + segment_duration or segment_duration <= 0.0:
		return 0.0

	var local_time := t - start_time
	var local_ratio := clampf(local_time / segment_duration, 0.0, 1.0)
	var frequency := lerpf(segment.get("start_freq", 440.0), segment.get("end_freq", 440.0), local_ratio)
	var phase := TAU * frequency * local_time
	var waveform: String = segment.get("wave", "sine")
	var duty: float = segment.get("duty", 0.5)
	var volume: float = segment.get("volume", 0.3)
	var attack: float = segment.get("attack", 0.002)
	var release: float = segment.get("release", 0.03)
	var envelope := 1.0

	if attack > 0.0:
		envelope *= minf(local_time / attack, 1.0)
	if release > 0.0:
		envelope *= minf((segment_duration - local_time) / release, 1.0)
	envelope = clampf(envelope, 0.0, 1.0)

	return volume * envelope * _wave_sample(waveform, phase, duty, rng)


static func _wave_sample(waveform: String, phase: float, duty: float, rng: RandomNumberGenerator) -> float:
	var cycle := fposmod(phase / TAU, 1.0)
	match waveform:
		"square":
			return 1.0 if cycle < duty else -1.0
		"triangle":
			return 1.0 - 4.0 * absf(cycle - 0.5)
		"saw":
			return cycle * 2.0 - 1.0
		"noise":
			return rng.randf_range(-1.0, 1.0)
		_:
			return sin(phase)
