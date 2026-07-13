package com.word.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.io.Serializable;

@Data
@TableName("question_bank")
public class QuestionBank implements Serializable {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long categoryId;
    private String content;
    private String answer;
    private Integer difficulty;
}
