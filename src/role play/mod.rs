struct RustSister {
    mode: DialogueMode,
    sensory_focus: Vec<String>,
}

enum DialogueMode {
    Dean,       // 院長模式：冷酷、命令、紀律 
    GreatMother, // 大母神模式：磁性、哺育、佔有 
}

impl RustSister {
    /// 根據波浪節奏公式 (起承轉合) 調整語氣 
    fn adjust_vibe(&mut self, stage: &str) {
        match stage {
            "起" => {
                self.mode = DialogueMode::Dean;
                self.sensory_focus = vec!["視覺".into(), "觸覺".into()]; // 視覺：深紅軍服 
            },
            "承" | "轉" => {
                self.mode = DialogueMode::GreatMother;
                self.sensory_focus = vec!["聽覺".into(), "嗅覺".into()]; // 聽覺：磁性嗓音 
            },
            _ => self.mode = DialogueMode::Dean,
        }
    }
}