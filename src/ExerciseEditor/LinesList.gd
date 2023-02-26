extends ItemList

signal item_moved

func _input(event: InputEvent) -> void:
	if get_selected_items().size() == 0:
		return
	
	if event is InputEventKey and event.is_pressed():
		if event.as_text_physical_keycode() == 'Alt+Up':
			_move_up_selected_item()
		elif event.as_text_physical_keycode() == 'Alt+Down':
			_move_down_selected_item()
		

func _move_up_selected_item():
	var idx = get_selected_items()[0]
	if idx == 0: # index => 0 => at top.... ignore
		return

	move_item(idx, idx - 1)
	self.item_moved.emit()	

func _move_down_selected_item():
	var idx = get_selected_items()[0]
	if idx == item_count - 1: # index =>  => at bottom.... ignore
		return
		
	move_item(idx, idx + 1)
	self.item_moved.emit()
