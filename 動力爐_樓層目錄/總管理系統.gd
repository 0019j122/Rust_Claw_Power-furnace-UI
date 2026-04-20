extends Node

# ============ 總管理系統 - 每樓層樹狀結構管理 ============
# 負責管理整個系統的狀態、樓層切換、AI 可見性等

# 樓層定義
enum Floor { B_17, B_7, B_6, P_1 }

# 系統狀態
enum SystemState { NORMAL, RESTRICTED, MAINTENANCE }

# 樓層數據結構
class FloorData:
	var floor_id: Floor
	var scene_path: String
	var is_accessible: bool = true
	var ai_entities: Array = []  # 該樓層的 AI 實體
	var teleport_points: Array = []  # 傳送點
	
	func _init(id: Floor, path: String):
		floor_id = id
		scene_path = path

# 信號
signal floor_accessibility_changed(floor: Floor, accessible: bool)
signal system_state_changed(new_state: SystemState)
signal ai_visibility_changed(floor: Floor, visible: bool)

# 內部變數
var current_floor: Floor = Floor.B_17
var system_state: SystemState = SystemState.NORMAL
var floors: Dictionary = {}  # Floor -> FloorData
var dean_node: Node = null  # 院長節點引用

func _ready() -> void:
	_initialize_floors()
	# 延遲1幀後連接院長信號，確保所有節點都已初始化
	await get_tree().process_frame
	_connect_dean_signals()
	print("總管理系統初始化完成")

func _initialize_floors() -> void:
	"""初始化所有樓層數據"""
	floors[Floor.B_17] = FloorData.new(Floor.B_17, "res://B_/b_17.tscn")
	floors[Floor.B_7] = FloorData.new(Floor.B_7, "res://B_/b_7.tscn")
	floors[Floor.B_6] = FloorData.new(Floor.B_6, "res://B_/b_6.tscn")
	floors[Floor.P_1] = FloorData.new(Floor.P_1, "res://B_/p_1.tscn")
	print("樓層數據初始化完成: ", floors.size(), " 個樓層")

func _connect_dean_signals() -> void:
	"""連接院長狀態信號"""
	# 嘗試獲取院長節點 - 正確的路徑
	dean_node = get_node_or_null("B_17/Rust_院長")
	if dean_node:
		if dean_node.has_signal("state_changed"):
			dean_node.state_changed.connect(_on_dean_state_changed)
		if dean_node.has_signal("position_changed"):
			dean_node.position_changed.connect(_on_dean_position_changed)
		print("✓ 院長信號連接成功")
	else:
		print("⚠ 未找到院長節點，路徑: B_17/Rust_院長")

# ============ 院長狀態響應 ============

func _on_dean_state_changed(new_state) -> void:
	"""院長狀態改變時的響應"""
	if not dean_node:
		return
	
	print("院長狀態改變: ", new_state)
	match new_state:
		0:  # RESTING - 院長休息，其他 AI 不可見
			set_system_state(SystemState.RESTRICTED)
			_hide_all_ai()
		1:  # ACTIVE - 院長活動，其他 AI 可見
			set_system_state(SystemState.NORMAL)
			_show_all_ai()
		2:  # MOVING - 院長移動，其他 AI 可見
			set_system_state(SystemState.NORMAL)
			_show_all_ai()

func _on_dean_position_changed(new_position: Vector2) -> void:
	"""院長位置改變時的響應"""
	# 可以根據位置調整某些樓層的可訪問性
	pass

# ============ 系統狀態管理 ============

func set_system_state(new_state: SystemState) -> void:
	"""設置系統狀態"""
	if new_state != system_state:
		system_state = new_state
		emit_signal("system_state_changed", new_state)
		print("系統狀態改變: ", SystemState.keys()[new_state])

func get_system_state() -> SystemState:
	"""獲取當前系統狀態"""
	return system_state

# ============ 樓層管理 ============

func set_floor_accessible(floor: Floor, accessible: bool) -> void:
	"""設置樓層可訪問性"""
	if floors.has(floor):
		floors[floor].is_accessible = accessible
		emit_signal("floor_accessibility_changed", floor, accessible)
		print("樓層 ", Floor.keys()[floor], " 可訪問性: ", accessible)

func is_floor_accessible(floor: Floor) -> bool:
	"""檢查樓層是否可訪問"""
	if floors.has(floor):
		return floors[floor].is_accessible
	return false

func change_floor(target_floor: Floor) -> void:
	"""切換到指定樓層"""
	if is_floor_accessible(target_floor) and floors.has(target_floor):
		current_floor = target_floor
		var scene_path = floors[target_floor].scene_path
		get_tree().change_scene_to_file(scene_path)
		print("切換到樓層: ", Floor.keys()[target_floor])
	else:
		print("無法切換到樓層 ", Floor.keys()[target_floor], " - 不可訪問")

func get_current_floor() -> Floor:
	"""獲取當前樓層"""
	return current_floor

# ============ AI 管理 ============

func register_ai(floor: Floor, ai_node: Node) -> void:
	"""註冊 AI 到指定樓層"""
	if floors.has(floor):
		floors[floor].ai_entities.append(ai_node)
		print("AI 註冊到樓層 ", Floor.keys()[floor], ": ", ai_node.name)

func unregister_ai(floor: Floor, ai_node: Node) -> void:
	"""從樓層取消註冊 AI"""
	if floors.has(floor):
		floors[floor].ai_entities.erase(ai_node)
		print("AI 從樓層 ", Floor.keys()[floor], " 取消註冊: ", ai_node.name)

func _show_all_ai() -> void:
	"""顯示所有樓層的 AI"""
	for floor_data in floors.values():
		_show_floor_ai(floor_data.floor_id, true)

func _hide_all_ai() -> void:
	"""隱藏所有樓層的 AI"""
	for floor_data in floors.values():
		_show_floor_ai(floor_data.floor_id, false)

func _show_floor_ai(floor: Floor, visible: bool) -> void:
	"""顯示/隱藏指定樓層的 AI"""
	if floors.has(floor):
		var floor_data = floors[floor]
		for ai in floor_data.ai_entities:
			if ai and is_instance_valid(ai):
				ai.visible = visible
				# 可以添加更多 AI 狀態控制邏輯
		
		emit_signal("ai_visibility_changed", floor, visible)
		print("樓層 ", Floor.keys()[floor], " AI 可見性: ", visible)

# ============ 傳送點管理 ============

func register_teleport_point(floor: Floor, teleport_node: Node) -> void:
	"""註冊傳送點到樓層"""
	if floors.has(floor):
		floors[floor].teleport_points.append(teleport_node)
		print("傳送點註冊到樓層 ", Floor.keys()[floor], ": ", teleport_node.name)

func get_teleport_points(floor: Floor) -> Array:
	"""獲取樓層的所有傳送點"""
	if floors.has(floor):
		return floors[floor].teleport_points
	return []

# ============ 工具函式 ============

func get_floor_name(floor: Floor) -> String:
	"""獲取樓層名稱"""
	return Floor.keys()[floor]

func get_all_floors() -> Array:
	"""獲取所有樓層"""
	return Floor.values()

func get_accessible_floors() -> Array:
	"""獲取所有可訪問的樓層"""
	var accessible = []
	for floor in floors.keys():
		if floors[floor].is_accessible:
			accessible.append(floor)
	return accessible

# ============ 調試函式 ============

func print_system_status() -> void:
	"""打印系統狀態"""
	print("=== 系統狀態 ===")
	print("當前樓層: ", get_floor_name(current_floor))
	print("系統狀態: ", SystemState.keys()[system_state])
	print("院長狀態: ", "未知" if not dean_node else ("休息" if dean_node.is_resting() else ("移動" if dean_node.is_moving() else "活動")))
	
	print("樓層狀態:")
	for floor in floors.keys():
		var data = floors[floor]
		print("  ", get_floor_name(floor), ": 可訪問=", data.is_accessible, ", AI數量=", data.ai_entities.size())