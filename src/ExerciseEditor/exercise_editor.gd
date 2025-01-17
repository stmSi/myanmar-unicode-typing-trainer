extends Control

@onready var basic_btn: Button = %BasicBtn
@onready var intermediate_btn: Button = %IntermediateBtn
@onready var advance_btn: Button = %AdvancedBtn
@onready var extra_exercise_btn: Button = %ExtraExerciseBtn

@onready var lesson_ids_lbl: Label = %LessonIdsLbl
@onready var lesson_ids: ItemList = %LessonIds

@onready var add_new_lessons_file_btn: Button = %AddNewLessonsFileBtn
@onready var test_exercise_btn: Button = %TestExerciseBtn

@onready var lines_list: ItemList = %LinesList

@onready var line_edit: LineEdit = %LineEdit

@onready var repeats_box: SpinBox = %RepeatsBox
@onready var allow_mistakes_box: SpinBox = %AllowMistakesBox
@onready var randomize_check: CheckButton = %RandomizeCheck
@onready var hide_keyboard_check: CheckButton = %HideKeyboardCheck
@onready var add_messsage_btn: Button = %AddMesssageBtn

@onready var add_update_line_btn: Button = %AddUpdateLineBtn
@onready var reset_btn: Button = %ResetBtn
@onready var remove_line_btn: Button = %RemoveLineBtn


@onready var add_lesson_message: PanelContainer = $AddLessonMessage
@onready var add_lesson_message_text_edit: TextEdit = $AddLessonMessage/VBoxContainer/AddLessonMessageTextEdit

var selected_difficulty: String = '';
var selected_lesson_number: int = 0;
var selected_line_idx: int = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_new_lessons_file_btn.disabled = true
	_toggle_disable_line_buttons(true)
	pass

func _on_basic_btn_pressed() -> void:
	lesson_ids_lbl.text = 'Basic Files:'
	selected_difficulty = 'basic'

	_reset_difficulty_theme_color_override()
	basic_btn.add_theme_color_override("font_color", Color.GOLD)

	_populate_files_list()


func _on_intermediate_btn_pressed() -> void:
	lesson_ids_lbl.text = 'Intermediate Files:'
	selected_difficulty = 'intermediate'

	_reset_difficulty_theme_color_override()
	intermediate_btn.add_theme_color_override("font_color", Color.GOLD)

	_populate_files_list()


func _on_advance_btn_pressed() -> void:
	lesson_ids_lbl.text = 'Advanced Files:'
	selected_difficulty = 'advanced'

	_reset_difficulty_theme_color_override()
	advance_btn.add_theme_color_override("font_color", Color.GOLD)

	_populate_files_list()


func _on_extra_exercise_btn_pressed() -> void:
	lesson_ids_lbl.text = 'Extra Exercise Files:'
	selected_difficulty = 'extra'

	_reset_difficulty_theme_color_override()
	extra_exercise_btn.add_theme_color_override("font_color", Color.GOLD)

	_populate_files_list()


func _on_cancel_btn_pressed() -> void:
	lesson_ids_lbl.text = 'No Difficulty Selected'
	selected_difficulty = ''
	lesson_ids.clear()

	_reset_difficulty_theme_color_override()
	_toggle_disable_line_buttons(true)


func _reset_difficulty_theme_color_override() -> void:
	basic_btn.release_focus()
	intermediate_btn.release_focus()
	advance_btn.release_focus()
	extra_exercise_btn.release_focus()

	basic_btn.remove_theme_color_override("font_color")
	intermediate_btn.remove_theme_color_override("font_color")
	advance_btn.remove_theme_color_override("font_color")
	extra_exercise_btn.remove_theme_color_override("font_color")


func _populate_files_list() -> void:
	lesson_ids.clear()
	add_new_lessons_file_btn.disabled = false

	_toggle_disable_line_buttons(true) # disable buttons
	var files := LessonAccess.get_lesson_files(selected_difficulty)
	files.sort()
	for f in files:
		lesson_ids.add_item(f.get_basename().get_file())
#		lesson_ids.set_item_metadata(-1, f)

	# Scroll to bottom
	if len(files) > 0:
		_scroll_to_bottom(lesson_ids)

	# Reset lines_list, line_edit, button
	_on_lines_list_empty_clicked()
	add_lesson_message_text_edit.text = ''
	lines_list.clear()


func _on_add_lessons_file_btn_pressed() -> void:
	if selected_difficulty == '':
		EventBus.message_popup.emit('Please Choose Difficulty')
		return

	var lesson_number: int = 1 # Default Start number
	var files: PackedStringArray = LessonAccess.get_lesson_files(selected_difficulty)
	files.sort()
	if len(files) > 0:
		var last_file := files[files.size() - 1]
		lesson_number = int(last_file.get_basename().get_file()) + 1 # next number

	var success := LessonAccess.create_new_lesson_file(lesson_number, selected_difficulty)
	if success:
		_populate_files_list()
		lesson_ids.select(files.size())
		_on_lesson_ids_item_selected(files.size())



func _on_lesson_ids_item_selected(index: int) -> void:
	_toggle_disable_line_buttons(false) # enable
	selected_lesson_number = int(lesson_ids.get_item_text(index))

	var lesson_data := LessonAccess.get_lesson_data(selected_lesson_number, selected_difficulty)

	# populate lines_list
	var lines := lesson_data.texts
	lines_list.clear()
	for l in lines:
		lines_list.add_item(l)

	# populate lesson settings
	# Danger:
	#	Do not put above "lines_list" population
	#	becuz value_changed will emit
	#	and save the empty lines_list
	repeats_box.value = int(lesson_data['repeats'])
	allow_mistakes_box.value = int(lesson_data['allow_mistakes'])
	randomize_check.button_pressed = int(lesson_data['randomize'])
	hide_keyboard_check.button_pressed = int(lesson_data['hide_keyboard'])
	add_lesson_message_text_edit.text = lesson_data['message']
	if lesson_data['message']:
		add_messsage_btn.add_theme_color_override("font_color", Color.GOLD)
	else:
		add_messsage_btn.remove_theme_color_override("font_color")

	# Scroll to bottom
	if len(lines) > 0:
		_scroll_to_bottom(lines_list)

	# Reset lines_list, line_edit, button
	_on_lines_list_empty_clicked()


func _on_lines_list_item_selected(index: int) -> void:
	line_edit.text = lines_list.get_item_text(index)

	selected_line_idx = index
	add_update_line_btn.text = "Update Line"
	pass # Replace with function body.


func _on_lines_list_empty_clicked(_at_position: Vector2 = Vector2.ZERO, _mouse_button_index: int = -1) -> void:
	# Reset lines_list, line_edit, button
	line_edit.text = ''
	selected_line_idx = -1
	add_update_line_btn.text = "Add Line"
	lines_list.deselect_all()
	pass # Replace with function body.


func _on_line_edit_text_submitted(_new_text: String) -> void:
	_on_add_update_line_btn_pressed()
	pass # Replace with function body.


func _on_add_update_line_btn_pressed() -> void:
	if line_edit.text.is_empty():
		return

	if selected_difficulty == '':
		EventBus.message_popup.emit("Please Choose Difficulty")
		return
	if selected_lesson_number == 0:
		EventBus.message_popup.emit("Please Choose Lesson Number")
		return

	if selected_line_idx != -1:
		# Update
		lines_list.set_item_text(lines_list.get_selected_items()[0], line_edit.text)
	else:
		# Add
		lines_list.add_item(line_edit.text)
		_scroll_to_bottom(lines_list)
	_save_lesson()

	# Reset shit
	_on_lines_list_empty_clicked()



func _on_remove_line_btn_pressed() -> void:
	if lines_list.get_selected_items().size() == 0:
		return
	var idx := lines_list.get_selected_items()[0]
	lines_list.remove_item(idx)

	# Reset shit
	_on_lines_list_empty_clicked()

	if lines_list.item_count > 0:
		var next_selected_idx : int = min(lines_list.item_count - 1, idx )
		lines_list.select(next_selected_idx)
	_save_lesson()



func _on_reset_btn_pressed() -> void:
	# Reset
	_on_lines_list_empty_clicked()
	pass # Replace with function body.


func _on_lines_list_item_moved() -> void:
	_save_lesson()
	pass # Replace with function body.

func _save_lesson() -> void:
	var texts: PackedStringArray = []

	var i := 0
	while i < lines_list.item_count:
		texts.push_back(lines_list.get_item_text(i))
		i += 1
	var newLesson := LessonData.new(
		texts,
		repeats_box.value,
		allow_mistakes_box.value,
		randomize_check.button_pressed,
		hide_keyboard_check.button_pressed,
		add_lesson_message_text_edit.text,
	)
	LessonAccess.create_update_new_exercise(
		selected_lesson_number,
		selected_difficulty,
		newLesson
	)


func _on_lines_list_delete_item_from_delete_key(_idx: int) -> void:
	_on_remove_line_btn_pressed()


func _on_repeats_box_value_changed(_value: float) -> void:
	_save_lesson()


func _on_allow_mistakes_box_value_changed(_value: float) -> void:
	_save_lesson()


func _on_randomize_check_toggled(_button_pressed: bool) -> void:
	_save_lesson()


func _on_add_messsage_btn_pressed() -> void:
	var tween := get_tree().create_tween()
	add_lesson_message.modulate.a = 0
	add_lesson_message.visible = true
	tween.tween_property(add_lesson_message, "modulate", Color.WHITE, 0.2)
	add_lesson_message_text_edit.grab_focus()


func _on_save_lesson_msg_btn_pressed() -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(add_lesson_message, "modulate", Color(1, 1, 1, 0), 0.2)
	await tween.finished
	add_lesson_message.visible = false
#	_save_lesson()
	LessonAccess.save_message(
		selected_lesson_number,
		selected_difficulty,
		add_lesson_message_text_edit.text
	)

func _on_cancel_lesson_msg_btn_pressed() -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(add_lesson_message, "modulate", Color(1, 1, 1, 0), 0.2)
	await tween.finished
	add_lesson_message.visible = false


func _on_lesson_ids_swap_lesson(lesson1: int, lesson2: int, direction: String) -> void:
	LessonAccess.swap_lesson_contents(lesson1, lesson2, selected_difficulty)
	_populate_files_list()

	var reselect_lesson := lesson1
	if direction == 'up':
			reselect_lesson = lesson2 - 1

	lesson_ids.select(clamp(reselect_lesson, 0, lesson_ids.item_count - 1))
	_on_lesson_ids_item_selected(clamp(reselect_lesson, 0, lesson_ids.item_count - 1))
	lesson_ids.grab_focus()
	pass # Replace with function body.


func _on_lesson_ids_delete_lesson_from_delete_key(idx: int) -> void:

	var confirm_dialog := NativeConfirmationDialog.new()

	confirm_dialog.title = "Delete Lessson: " + lesson_ids.get_item_text(idx)
	confirm_dialog.dialog_text = "Are you sure you want to delete Lesson File: %s" % lesson_ids.get_item_text(idx)
	confirm_dialog.buttons_texts = NativeConfirmationDialog.BUTTONS_TEXTS_YES_NO

	confirm_dialog.confirmed.connect(func() -> void:
		LessonAccess.delete_lesson_file(
			selected_lesson_number,
			selected_difficulty,
		)
		_populate_files_list()
		confirm_dialog.queue_free()
	)
	confirm_dialog.canceled.connect(
		func() -> void:
			confirm_dialog.queue_free()
	)

#	confirm_dialog.cancelled.connect(func(): confirm_dialog.queue_free())
	add_child(confirm_dialog)
	confirm_dialog.show()



func _on_hide_keyboard_check_toggled(_button_pressed: bool) -> void:
	_save_lesson()


func _toggle_disable_line_buttons(disabled: bool) -> void:
	# Do not randomize extra exercises (For Networking for now?)
	if selected_difficulty == 'extra':
		randomize_check.disabled = true
		randomize_check.tooltip_text = "Disabled for extra lessons."
	else:
		randomize_check.disabled = disabled
		randomize_check.tooltip_text = ""

	hide_keyboard_check.disabled = disabled
	add_update_line_btn.disabled = disabled
	reset_btn.disabled = disabled
	remove_line_btn.disabled = disabled
	add_messsage_btn.disabled = disabled
	test_exercise_btn.disabled = disabled
	pass

func _scroll_to_bottom(list: ItemList) -> void:
	var scrollbar: VScrollBar = list.get_v_scroll_bar()
	scrollbar.allow_greater = true
	scrollbar.value = scrollbar.max_value
	scrollbar.allow_greater = false



func _on_test_exercise_btn_pressed() -> void:
	var lesson_data := LessonAccess.get_lesson_data(selected_lesson_number, selected_difficulty)
	SceneChanger.change_to_take_custom_exercises_scene(lesson_data['texts'])
