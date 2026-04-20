extends AnimatedSprite2D

# 院長狀態 - 觀察螞蟻窩實驗
enum State { RESTING, ACTIVE, MOVING }

@export var speed: float = 100.0  # 移動速度
@export var rest_duration: float = 5.0  # 休息時間（秒）

# 狀態信號 - 其他 AI 和地圖根據這個信號改變可訪問性
signal state_changed(new_state: State)
signal position_changed(new_position: Vector2)

# 內部變數
var current_state: State = State.RESTING
var current_velocity: Vector2 = Vector2.ZERO
var target_position: Vector2 = Vector2.ZERO
var rest_timer: float = 0.0

func _ready() -> void:
	# 初始化狀態
	if sprite_frames and sprite_frames.has_animation("站姿"):
		set_state(State.RESTING)
		play()
		print("✓ 院長已初始化")
	else:
		print("⚠ 院長動畫未找到")

func _process(delta: float) -> void:
	match current_state:
		State.RESTING:
			_handle_resting(delta)
		State.ACTIVE:
			_handle_active(delta)
		State.MOVING:
			_handle_moving(delta)

# ============ 狀態處理函式 ============

func _handle_resting(delta: float) -> void:
	"""院長休息狀態 - 其他 AI 無法被觀察"""
	current_velocity = Vector2.ZERO
	animation = "站姿"
	play()
	
	rest_timer -= delta
	if rest_timer <= 0:
		# 休息結束，轉為活動狀態
		set_state(State.ACTIVE)

func _handle_active(delta: float) -> void:
	"""院長活動狀態 - 其他 AI 可被觀察，但未移動"""
	current_velocity = Vector2.ZERO
	animation = "站姿"
	play()

func _handle_moving(delta: float) -> void:
	"""院長移動狀態 - 執行移動並播放行走動畫"""
	# 計算移動方向
	if current_velocity != Vector2.ZERO:
		# 根據 X 軸方向選擇動畫
		if current_velocity.x > 0:
			animation = "右行走"
		elif current_velocity.x < 0:
			animation = "左行走"
		play()
	
	# 移動角色（檢查速度不為零）
	if current_velocity.length() > 0:
		position += current_velocity.normalized() * speed * delta
	
	# 檢查是否到達目標位置
	if position.distance_to(target_position) < 10:
		position = target_position
		current_velocity = Vector2.ZERO
		set_state(State.ACTIVE)
		emit_signal("position_changed", position)

# ============ API 控制函式（外部調用）============

## 讓院長移動到指定位置
func move_to(pos: Vector2) -> void:
	target_position = pos
	current_velocity = (target_position - position)
	set_state(State.MOVING)
	emit_signal("position_changed", position)

## 讓院長沿指定方向移動指定距離
func move_direction(direction: Vector2, distance: float) -> void:
	target_position = position + direction.normalized() * distance
	current_velocity = direction
	set_state(State.MOVING)

## 讓院長進入休息狀態（其他 AI 無法觀察）
func rest(duration: float = -1.0) -> void:
	if duration > 0:
		rest_timer = duration
	else:
		rest_timer = rest_duration
	set_state(State.RESTING)

## 讓院長停止休息並恢復活動
func wake_up() -> void:
	rest_timer = 0
	set_state(State.ACTIVE)

## 停止當前移動
func stop_moving() -> void:
	current_velocity = Vector2.ZERO
	target_position = position
	set_state(State.ACTIVE)

## 獲取當前狀態
func get_current_state() -> State:
	return current_state

## 檢查院長是否在休息
func is_resting() -> bool:
	return current_state == State.RESTING

## 檢查院長是否在移動
func is_moving() -> bool:
	return current_state == State.MOVING

# ============ 內部狀態管理 ============

func set_state(new_state: State) -> void:
	if new_state != current_state:
		current_state = new_state
		var state_name = State.keys()[new_state] if new_state >= 0 and new_state < State.size() else "未知"
		print("院長狀態改變: ", state_name)
		emit_signal("state_changed", new_state)
