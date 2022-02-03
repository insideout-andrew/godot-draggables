extends Area2D
class_name Draggable


signal picked_up(_draggable)
signal dropped(_draggable)


export var disabled := false
export var follow_speed := 15.0
export var return_speed := 25.0


var held := false setget _set_held
var hovered := false setget _set_hovered


var snapped_dropzone #: Area2D
var dropzone #: Area2D


func _set_held(x : bool):
	if not disabled and held != x:
		held = x
		if held:
			emit_signal("picked_up", self)
			_set_dropzone_accepts(true)
			#setting deferred here so this takes precedence over any dropzones connected to draggables being picked up
			#setting this to null so right after picking something up it positions at the mouse instead of the snapped_dropzone position
			set_deferred("snapped_dropzone", null)
#			$CollisionShape2D.modulate = Color.red
		else:
			emit_signal("dropped", self)
			_set_dropzone_accepts(false)
			if snapped_dropzone:
#				dropzone = snapped_dropzone
				dropzone.emit_signal("draggable_dropped", self, snapped_dropzone)
#			$CollisionShape2D.modulate = Color.white
	
	
func _set_hovered(x : bool):
	if not disabled and hovered != x and not _get_current_held_draggable():
		hovered = x
#		if hovered:
#			$CollisionShape2D.modulate = Color.blue
#		else:
#			$CollisionShape2D.modulate = Color.white

#anytime a draggable is picked up, go through all dropzones and set accepts_draggable to {value}
func _set_dropzone_accepts(value):
	var dropzones = get_tree().get_nodes_in_group("Dropzone")
	for dropzone in dropzones:
		if value:
			dropzone.on_draggable_picked_up(self)
		else:
			dropzone.on_draggable_dropped(self, dropzone)


func _ready():
#	$CollisionShape2D.shape.extents = size
	connect("input_event", self, "_on_input_event")
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	
	
func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.pressed and held:
		get_tree().get_root().set_input_as_handled()
		self.held = false
		self.hovered = false


func _on_input_event(_viewport : Node, event : InputEvent, _shape : int) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		get_tree().get_root().set_input_as_handled()
		self.held = true


func _process(delta):
	if held:
		if snapped_dropzone:
			position = lerp(position, snapped_dropzone.position, follow_speed * delta)
		else:
			position = lerp(position, get_global_mouse_position(), follow_speed * delta)
	else:
		if dropzone:
			position = lerp(position, dropzone.position, return_speed * delta)


func _on_mouse_entered() -> void:
	if not held:
		self.hovered = true


func _on_mouse_exited() -> void:
	if not held:
		self.hovered = false


func _get_current_held_draggable() -> Area2D:
	var draggables = get_tree().get_nodes_in_group("Draggable")
	var draggable
	for d in draggables:
		if d.held:
			draggable = d
			break
	return draggable


#public functions

func set_snapped_dropzone(_dropzone : Area2D) -> void:
	self.snapped_dropzone = _dropzone
		

func set_dropzone(_dropzone : Area2D, _move_immediately : bool = false) -> void:
	self.dropzone = _dropzone
	if _move_immediately:
		position = _dropzone.position
