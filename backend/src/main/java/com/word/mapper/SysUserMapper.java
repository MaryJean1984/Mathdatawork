package com.word.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.word.entity.SysUser;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

@Mapper
public interface SysUserMapper extends BaseMapper<SysUser> {
    
    /**
     * 自定义 SQL 查询：根据状态获取活跃用户
     */
    List<SysUser> selectActiveUsersByStatus(@Param("status") Integer status);
}
