extends Control

@onready var blocker: ColorRect = $Blocker
@onready var loading_label: Label = $Panel/VBoxContainer/LoadingLabel
@onready var progress_label: Label = $Panel/VBoxContainer/ProgressLabel

func _ready() -> void:
	hide()
	top_level = true
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 100
	blocker.set_anchors_preset(Control.PRESET_FULL_RECT)
	PlayerManager.catchup_started.connect(_on_catchup_started)
	PlayerManager.catchup_progress.connect(_on_catchup_progress)
	PlayerManager.catchup_finished.connect(_on_catchup_finished)

func _on_catchup_started() -> void:
	show()

func _on_catchup_progress(remaining_ticks: int) -> void:
	progress_label.text = "%s ticks remaining" % remaining_ticks

func _on_catchup_finished() -> void:
	hide()
