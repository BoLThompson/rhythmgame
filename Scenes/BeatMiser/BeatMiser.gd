extends Node
class_name BeatMiser

const midiplayerscene := preload("res://addons/midi/MidiPlayer.tscn")

#var inputTimes: Array = [];
var lastBeat: int = Time.get_ticks_msec();

var window_msec: int = 110;
var penalize := true;

signal DownBeat;

var mp: MidiPlayer;

func _ready() -> void:
	mp = midiplayerscene.instantiate();
	
	mp.midi_event.connect(
		func(_channel, event):
			if (event.type == 0x90 && event.note == 0):
				DownBeat.emit();
	)
	DownBeat.connect(
		func():
			lastBeat = Time.get_ticks_msec();
	)
	
	mp.set_file("res://assets/music/midi/synthy_long_metronome.mid");
	mp.set_soundfont("res://assets/music/soundfont/fb01.sf2");
	
	add_child(mp);
	mp.play();

func upTempo() ->void:
	mp.set_tempo(mp.tempo + 2);

func _process(_delta: float) -> void:
	if (Input.is_action_just_pressed("ui_accept")):
		#handling slightly late presses is trivial
		if (Time.get_ticks_msec() - lastBeat < window_msec):
			print("hit late") #late success
		#otherwise, wait and see if a beat is coming
		else:
			var waiter = BeatWaiter.new();
			waiter.BeatSignal = DownBeat;
			waiter.MaxWaitTime = (window_msec / 1000.0);
			call_deferred("add_child", waiter);
			var success = await waiter.Interrupt;
			if (success): 
				print("hit early") #early success
			else: 
				print("miss")
				if penalize: upTempo();
