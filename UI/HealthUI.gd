extends Control


const HEART_ICON_SIZE = 15

var hearts = 1 setget set_hearts
var max_hearts = 1 setget set_max_hearts

onready var heart_ui_full = $HeartUIFull
onready var heart_ui_empty = $HeartUIEmpty


func set_hearts(value):
	hearts = clamp(value, 0, max_hearts)
	if heart_ui_full != null:
		heart_ui_full.rect_size.x = hearts * HEART_ICON_SIZE


func set_max_hearts(value):
	max_hearts = max(value, 1)
	self.hearts = min(hearts, max_hearts)
	if heart_ui_empty != null:
		heart_ui_empty.rect_size.x = max_hearts * HEART_ICON_SIZE


func _ready():
	self.max_hearts = PlayerStats.max_health
	self.hearts = PlayerStats.health
	# warning-ignore:return_value_discarded
	PlayerStats.connect("health_changed", self, "set_hearts")
	# warning-ignore:return_value_discarded
	PlayerStats.connect("max_health_changed", self, "set_max_hearts")

