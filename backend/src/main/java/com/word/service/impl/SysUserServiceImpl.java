package com.word.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.word.entity.SysUser;
import com.word.mapper.SysUserMapper;
import com.word.service.SysUserService;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class SysUserServiceImpl extends ServiceImpl<SysUserMapper, SysUser> implements SysUserService {

    @Override
    @Cacheable(value = "userCache", key = "#id")
    public SysUser getUserById(Long id) {
        return this.getById(id);
    }

    @Override
    public List<SysUser> getActiveUsers() {
        // 调用 Mapper 自定义 SQL
        return this.baseMapper.selectActiveUsersByStatus(1);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    @CacheEvict(value = "userCache", key = "#user.id")
    public boolean updateUserInfo(SysUser user) {
        // 模拟复杂的业务逻辑和事务控制
        boolean updated = this.updateById(user);
        if (user.getUsername() != null && user.getUsername().contains("error")) {
            throw new RuntimeException("模拟事务回滚：用户名不合法");
        }
        return updated;
    }
}
