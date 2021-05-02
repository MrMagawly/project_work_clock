extends Control


onready var timer = get_node("Timer")
onready var audio_stream = get_node("AudioStreamPlayer")
onready var label_clock = get_node("MarginContainer/VBoxContainer/LabelClock")
onready var progress_bar = get_node("MarginContainer/VBoxContainer/ProgressBar")
onready var button_start = get_node("MarginContainer/VBoxContainer/ControlButtons/StartButton")
onready var button_interrupted = get_node("MarginContainer/VBoxContainer/ControlButtons/InterruptedButton")

enum state {SESSION, SHORT_BREAK, LONG_BREAK}

var current_state
var previous_state
var session_count
var max_sessions

var text = {}
var time = {}


func _ready():
	session_count = 0
	max_sessions = 4
	time.session = 1500
	time.short_break = 300
	time.long_break = 1800
	text.short_break = "Start Short Break"
	text.long_break = "Start Long Break"
	text.session = "Start Session"
	current_state = state.SESSION
	previous_state = state.SESSION
	progress_bar.set_value(0)
	button_start.set_disabled(false)
	set_timer_state(time.session, text.session, state.SESSION)


func _physics_process(delta):
	if timer.is_stopped() == false:
		label_clock.text = String(int(timer.get_time_left()))


func _on_InterruptedButton_pressed():
	if timer.is_stopped() and previous_state != state.SESSION: 
		if session_count > 0: 
			decrement_session_count()
	else:
		timer.stop()
	
	if current_state == state.LONG_BREAK:
		set_timer_state(time.long_break, text.long_break, state.LONG_BREAK)
	else:
		set_timer_state(time.short_break, text.short_break, state.SHORT_BREAK)


func _on_StartButton_pressed():
	button_start.set_disabled(true)
	timer.start()


func _on_Timer_timeout():
	match current_state:
		state.SESSION:
			finished_session()
		_:
			set_timer_state(time.session, text.session, state.SESSION)
	audio_stream.play()


func decrement_session_count():
	session_count -= 1
	progress_bar.set_value(session_count)


func finished_session():
	increment_session_count()
	if session_count < max_sessions:
		set_timer_state(time.short_break, text.short_break, state.SHORT_BREAK)
	else:
		set_session_count(0)
		set_timer_state(time.long_break, text.long_break, state.LONG_BREAK)


func increment_session_count():
	session_count += 1
	progress_bar.set_value(session_count)


func set_session_count(value: int):
	session_count = value
	progress_bar.set_value(value)


func set_timer_state(time: int, text: String, state: int):
	timer.set_wait_time(time)
	button_start.set_text(text)
	label_clock.text = String(time)
	button_start.set_disabled(false)
	previous_state = current_state
	current_state = state
