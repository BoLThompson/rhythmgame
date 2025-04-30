extends Node
class_name BeatMiser

const midiplayerscene := preload("res://addons/midi/MidiPlayer.tscn")

#var inputTimes: Array = [];
var lastBeat: int = Time.get_ticks_msec();

@export var window_msec: int = 110;
var penalize := true;

@export var InputsToPenalize: Array[String] = [];

@export var BPM_Penalty: int = 4;

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
	mp.set_tempo(mp.tempo + BPM_Penalty);

var waiter: BeatWaiter = null;
func _input(event: InputEvent) -> void:
	#don't double-penalize for nearly simultaneous 2+ input attempts
	if (waiter != null): return;
	
	for key in InputsToPenalize:
		if (event.is_action_pressed(key)):
			#handling slightly late presses is trivial
			if (Time.get_ticks_msec() - lastBeat < window_msec):
				print("hit late") #late success
			#otherwise, wait and see if a beat is coming
			else:
				waiter = BeatWaiter.new();
				waiter.BeatSignal = DownBeat;
				waiter.MaxWaitTime = (window_msec / 1000.0);
				call_deferred("add_child", waiter);
				var success = await waiter.Interrupt;
				waiter = null;
				if (success): 
					print("hit early") #early success
				else: 
					print("miss")
					if penalize: upTempo();
			break;
