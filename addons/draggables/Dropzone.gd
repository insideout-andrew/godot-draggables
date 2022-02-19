extends Area2D
class_name Dropzone


signal draggable_dropped(_draggable, _dropzone) #this is emitted from the draggable script...
signal draggable_snapped(_draggable, _dropzone)


var _accepts_method_node : Node
var _accepts_method : String


var accepts_draggable := false setget _set_accepts_draggable


#set the `accepts_draggable` truthyness based on the _accepts_method_node's method
func _set_accepts_draggable(x):
	if accepts_draggable != x:
		accepts_draggable = x
#		if accepts_draggable:
#			$CollisionShape2D.modulate = Color.yellow
#		else:
#			$CollisionShape2D.modulate = Color.white


#connect any signals
func _ready() -> void:
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	
	
func _on_mouse_entered() -> void:
	var current_draggable = _get_current_held_draggable()
	if accepts_draggable and current_draggable:
		emit_signal("draggable_snapped", current_draggable, self)
		current_draggable.set_snapped_dropzone(self)

	
func _on_mouse_exited() -> void:
	var current_draggable = _get_current_held_draggable()
	if current_draggable:
		current_draggable.call_deferred("set_snapped_dropzone", null) #deferring this call so it doesn't happen before draggable's _unhandled_input and the snapped dorpzone doesn't turn null too early


func on_draggable_picked_up(_draggable : Area2D) -> void:
	if _accepts_method_node and _accepts_method and _accepts_method_node.has_method(_accepts_method):
		self.accepts_draggable = _accepts_method_node.call(_accepts_method, _draggable, self)


func on_draggable_dropped(_draggable : Area2D, _dropzone : Area2D) -> void:
	self.accepts_draggable = false
	
	
func _get_current_held_draggable() -> Area2D:
	var draggables = get_tree().get_nodes_in_group("Draggable")
	var draggable
	for d in draggables:
		if d.held:
			draggable = d
			break
	return draggable
	


#the parent of the dropzone needs to set these in order to determine if the dropzone accepts draggables or not
func set_accepts(node : Node, method : String) -> void:
	_accepts_method_node = node
	_accepts_method = method


func get_current_draggable() -> Area2D:
	var all_draggables = get_tree().get_nodes_in_group("Draggable")
	var current_draggable
	for d in all_draggables:
		if d.dropzone == self:
			current_draggable = d
			break
	return current_draggable
