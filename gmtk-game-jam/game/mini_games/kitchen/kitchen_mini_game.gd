extends MiniGame

const TABLE_MINI_GAME_PACKED := preload("uid://c3thcmvc25bv6")

var _table_mini_game: MiniGame

@onready var table: Interactable = $Table
@onready var table_layer: CanvasLayer = $TableLayer
@onready var player: Player = $Player


func _ready() -> void:
	super()
	table_layer.hide()


func _on_chef_interacted() -> void:
	print("Spoke to chef")
	table.enabled = true


func _on_table_interacted() -> void:
	if _table_mini_game:
		return

	player.freeze()

	_table_mini_game = TABLE_MINI_GAME_PACKED.instantiate()
	_table_mini_game.exited.connect(_on_table_mini_game_exited)
	table_layer.add_child(_table_mini_game)
	table_layer.show()


func _on_table_mini_game_exited() -> void:
	_table_mini_game = null
	table_layer.hide()
	player.unfreeze()
