extends RichTextLabel

var raw_text := '<Text Are not loaded yet.>'
var written_text := ''

@export var correct_color: Color = Color.GREEN
@export var error_color: Color = Color.RED

@export var current_char_color: Color = Color.LIGHT_SKY_BLUE
@export var current_char_bgcolor: Color = Color.DARK_SLATE_BLUE

@export var is_popup: bool = true

var disable_highlight_curr_char: bool = false
var prevent_typing_pass_error: bool = false

func _ready() -> void:
	EventBus.exercise_loaded.connect(self._set_raw_text)
	EventBus.written_string_changed.connect(self._on_written_string_changed)

	disable_highlight_curr_char = GeneralSettings.get_hightlight_current_character_disabled()
	GeneralSettings.hightlight_current_char_disabled_changed.connect(
		func(disabled: bool) -> void:
			disable_highlight_curr_char = disabled
			_on_written_string_changed(written_text)
	)

	prevent_typing_pass_error = GeneralSettings.get_prevent_typing_pass_error_character()
	GeneralSettings.prevent_typing_pass_error_char_changed.connect(
		func(prevent: bool) -> void:
			prevent_typing_pass_error = prevent
	)

func _set_raw_text(t: String, _idx: int, _e: PackedStringArray) -> void:
	raw_text = t
	_on_written_string_changed('')


func _on_written_string_changed(s: String) -> void:
	written_text = s
	self.text = ""
	clear()

	var i: int = 0
	var correct: bool = false
	var wrong: bool = false
	while(i < len(written_text) and i < len(raw_text)):
		if written_text[i] == raw_text[i]:

			# didn't corrent before... start applying 'green' color
			if not correct:

				# if previous char was wrong, stop applying 'red' color
				if wrong:
					wrong = false
					pop()

				correct = true
				push_color(correct_color)

		# wrong character was written
		# written_text[i] != raw_text[i]
		else:

			if raw_text[i] == ' ': # special case for 'Space' characters
				push_color(error_color)
				add_text('_')
				pop()
				i += 1
				continue


			if not wrong: # didn't wrong before.. start apply 'red' color

				# if previous char was correct, stop applying 'green'
				if correct:
					correct = false
					pop()

				wrong = true
				push_color(error_color)

		# Advanced
		add_text(raw_text[i])
		i += 1

	if wrong or correct:
		pop()

	if is_popup or not disable_highlight_curr_char:
		# color the current character where cursor will locate
		if not (wrong and prevent_typing_pass_error):
			# don't highlight cur char when both err and prevent are true

			if(i < len(raw_text)):
				_color_cursor_character(i)
				i += 1


	## show the rest
	while(i < len(raw_text)):
		add_text(raw_text[i])
		i += 1

	## End of while loop

func _color_cursor_character(i: int = 0) -> void:
	push_color(current_char_color)
	push_bgcolor(current_char_bgcolor)
	push_underline()
	push_bold()
	push_customfx(RichTextPulse.new(), {freq=15.0, height=6.0})

	if raw_text[i] == ' ': # special case for 'Space' characters
		add_text('_')
	else:
		add_text(raw_text[i])
	pop()
	pop()
	pop()
	pop()
	pop()
