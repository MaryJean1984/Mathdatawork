package com.word.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.word.entity.SysUser;
import java.util.List;

public interface SysUserService extends IService<SysUser> {
    
    /**
     * 根据 ID 获取用户（集成 Redis 缓存）
     */
    SysUser getUserById(Long id);

    /**
     * 获取所有活跃用户
     */
    List<SysUser> getActiveUsers();

    /**
     * 更新用户信息（包含事务处理和缓存失效）
     */
    boolean updateUserInfo(SysUser user);
}
