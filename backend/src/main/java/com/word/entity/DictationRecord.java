package com.word.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.io.Serializable;

@Data
@TableName("dictation_record")
public class DictationRecord implements Serializable {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long userId;
    private String audioUrl;
    private String recognizedText;
    private Integer status; // 0-处理中 1-完成 2-失败
}
