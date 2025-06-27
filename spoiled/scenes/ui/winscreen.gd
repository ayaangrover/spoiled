extends Control

var time_taken: float = 0.0
var death_count: int = 0

@onready var stats_label: Label = $StatsLabel

func _ready():
	stats_label.text = "Time: %.2f seconds\nDeaths: %d" % [time_taken, death_count]
