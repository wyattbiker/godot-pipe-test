extends Control

var pipe
var thread
var info

func _ready():
	if OS.get_name() == "Windows":
		info = OS.execute_with_pipe("cmd.exe", [])
	else:
		var args = ["-c","uname"]
		#args = ["--version"]
		args=[]
		info = OS.execute_with_pipe("/usr/bin/bash", args)
		pass
	pipe = info["stdio"]
	print(info)
	thread = Thread.new()
	thread.start(_thread_func)
	get_window().close_requested.connect(clean_func)

func _thread_func():
	# read stdin and add to TextEdit.
	while pipe.is_open() and pipe.get_error() == OK:
		_add_char.call_deferred(char(pipe.get_8()))

func _add_char(c):
	#print(c)
	$TextEdit.text += c
	$TextEdit.scroll_vertical = $TextEdit.get_v_scroll_bar().max_value

func _on_line_edit_text_submitted(new_text: String) -> void:
	# send command to stdin.
	var cmd = new_text + "\n"
	var buffer = cmd.to_utf8_buffer()
	#var err=pipe.get_error()
	pipe.store_buffer(buffer)
	#err=pipe.get_error()
	$LineEdit.text = ""

func clean_func():
	# close pipe and cleanup.
	pipe.close()
	thread.wait_to_finish()
