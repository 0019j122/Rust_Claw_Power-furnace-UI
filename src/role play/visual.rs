pub struct SpriteLayer {
    pub base_body: String,    // 院長基底 (深紅軍服)
    pub blush_alpha: f32,     // 羞恥度 (0.0 ~ 1.0) -> 控制臉部紅暈像素透明度
    pub sweat_drops: bool,    // 是否顯示汗珠像素
    pub clothing_state: u8,   // 0: 嚴肅扣齊, 1: 領口微鬆, 2: 凌亂
}

impl SpriteLayer {
    /// 根據當前互動情緒，自動生成渲染指令給 Star-Office-UI
    pub fn auto_generate_vibe(&mut self, arousal_level: f32) {
        if arousal_level > 0.8 {
            self.blush_alpha = 0.9;
            self.sweat_drops = true;
            self.clothing_state = 1; // 自動觸發「反差」視覺
        }
    }
}