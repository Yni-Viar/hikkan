extends GridContainer
## Keybinds manager
## Made by Yni, licensed under MIT License.

var settings_key: Dictionary[String, String] = {
	"CL": "look",
	"C": "click",
	"CRL": "camera_rotate_left",
	"CRR": "camera_rotate_right",
	"TVM": "toggle_mode",
	"VN": "vn_continue" #,
	#"I": "inventory"
}
var listen_to_keybind: bool = false
var current_setting_to_change: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	re_parse()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if listen_to_keybind && current_setting_to_change >= 0 && current_setting_to_change < settings_key.size():
		if event is InputEventKey:
			Settings.set_keybind(settings_key[settings_key.keys()[current_setting_to_change]], 0, event.physical_keycode)
		if event is InputEventMouseButton:
			Settings.set_keybind(settings_key[settings_key.keys()[current_setting_to_change]], 1, event.button_index)
		re_parse()
		listen_to_keybind = false

func re_parse():
	for str in settings_key.keys():
		if get_node_or_null(str + "Button") != null:
			get_node(str + "Button").text = InputMap.action_get_events(settings_key[str])[0].as_text()
	

func _on_cl_button_pressed() -> void:
	listen_to_keybind = true
	$CLButton.text = "KEY_LISTENING"
	current_setting_to_change = 0


func _on_c_button_pressed() -> void:
	listen_to_keybind = true
	$CButton.text = "KEY_LISTENING"
	current_setting_to_change = 1


func _on_crl_button_pressed() -> void:
	listen_to_keybind = true
	$CRLButton.text = "KEY_LISTENING"
	current_setting_to_change = 2


func _on_crr_button_pressed() -> void:
	listen_to_keybind = true
	$CRRButton.text = "KEY_LISTENING"
	current_setting_to_change = 3


func _on_tvm_button_pressed() -> void:
	listen_to_keybind = true
	$TVMButton.text = "KEY_LISTENING"
	current_setting_to_change = 4


func _on_i_button_pressed() -> void:
	listen_to_keybind = true
	$IButton.text = "KEY_LISTENING"
	current_setting_to_change = 6


func _on_vn_button_pressed() -> void:
	listen_to_keybind = true
	$VNButton.text = "KEY_LISTENING"
	current_setting_to_change = 5
