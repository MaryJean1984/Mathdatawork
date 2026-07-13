package com.word.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.io.Serializable;

@Data
@TableName("dictation_detail")
public class DictationDetail implements Serializable {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long recordId;
    private String word;
    private Boolean isCorrect;
}
