extends VBoxContainer
class_name CPMProgressRadical

@onready var cpm_lbl: RichTextLabel = $CPM

var cpm: int

@export var average_cpm: int = 150
@export var professional_cpm: int = 250

@export var lower_average_cpm_color: Color = Color.DARK_CYAN
@export var above_average_cpm_color: Color = Color.MEDIUM_SPRING_GREEN
@export var professional_cpm_color: Color = Color.MEDIUM_PURPLE
@onready var next_target: RichTextLabel = $NextTarget


func _ready() -> void:
	var stats := UserProfileManager.load_stats()
	if stats.size() == 0:
		return
	var stat := stats[stats.size() - 1]
	cpm = stat.char_per_min
	show_cpm()

func show_cpm() -> void:
	cpm_lbl.clear()
	next_target.clear()
	cpm_lbl.add_text("Character Per Min (CPM): ")

	var level := ""
	if cpm >= professional_cpm:
		cpm_lbl.push_color(professional_cpm_color)
		level = "Professional"
		next_target.visible = false

	elif cpm >= average_cpm:
		cpm_lbl.push_color(above_average_cpm_color)
		level = "Above Average"

		next_target.add_text("Next CPM GOAL: ")
		next_target.push_color(professional_cpm_color)
		next_target.add_text(str(professional_cpm) + " (Professional Level)")
		next_target.pop()

	elif cpm < average_cpm:
		cpm_lbl.push_color(lower_average_cpm_color)
		level = "Below Average"

		next_target.add_text("Next CPM GOAL: ")
		next_target.push_color(above_average_cpm_color)
		next_target.add_text(str(average_cpm) + " (Average Level)")
		next_target.pop()

	cpm_lbl.add_text(str(cpm) + " (" + level + ")")
	cpm_lbl.pop()
