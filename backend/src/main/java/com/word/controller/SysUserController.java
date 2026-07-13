package com.word.controller;

import com.word.entity.SysUser;
import com.word.service.SysUserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/users")
public class SysUserController {

    @Autowired
    private SysUserService sysUserService;

    @GetMapping("/{id}")
    public ResponseEntity<SysUser> getUser(@PathVariable Long id) {
        SysUser user = sysUserService.getUserById(id);
        return ResponseEntity.ok(user);
    }

    @GetMapping("/active")
    public ResponseEntity<List<SysUser>> getActiveUsers() {
        List<SysUser> users = sysUserService.getActiveUsers();
        return ResponseEntity.ok(users);
    }

    @PostMapping("/update")
    public ResponseEntity<String> updateUser(@RequestBody SysUser user) {
        boolean success = sysUserService.updateUserInfo(user);
        return success ? ResponseEntity.ok("更新成功") : ResponseEntity.badRequest().body("更新失败");
    }
}
