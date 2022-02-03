extends Node2D


onready var draggables = $Draggables.get_children()
onready var dropzones = $Dropzones.get_children()


func _ready():
	for i in len(draggables):
		#set a draggable's dropzone
		#if the second parameter is true, it will move immediately with no transition
		draggables[i].set_dropzone(dropzones[i], true)
		#draggables also have `picked_up` and `dropped` signals you can use if needed

	for dropzone in dropzones:
		#this runs anytime a draggable is picked up
		#a dropzone will check this function to see if it should accept a held draggable
		dropzone.set_accepts(self, "_on_dropzone_accepts")
		
		#this runs when a draggable "snaps" into place on a dropzone, but is not yet dropped
		dropzone.connect("draggable_snapped", self, "_on_draggable_snapped")

		#this runs when a draggable is actually dropped into place
		#you might run something like `_draggable.set_dropzone(_dropzone)` or whatever else you want
		dropzone.connect("draggable_dropped", self, "_on_draggable_dropped")


#_dropzone will not accept the _draggable, if it does already has one
func _on_dropzone_accepts(_draggable : Draggable, _dropzone : Dropzone) -> bool:
	return not _dropzone.get_current_draggable()


#when a draggable snaps on a dropzone, if the dropzone is occu
func _on_draggable_snapped(_draggable : Draggable, _dropzone : Dropzone) -> void:
	print(_draggable.name, ' snapped to ', _dropzone.name)


#runs when a draggable is dropped on a dropzone
func _on_draggable_dropped(_draggable : Draggable, _dropzone : Dropzone) -> void:
	_draggable.set_dropzone(_dropzone)
