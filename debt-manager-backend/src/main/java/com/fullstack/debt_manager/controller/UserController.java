package com.fullstack.debt_manager.controller;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import com.fullstack.debt_manager.dto.ApiResponse;
import com.fullstack.debt_manager.dto.UserDto;
import com.fullstack.debt_manager.entity.User;
import com.fullstack.debt_manager.service.UserService;

import java.util.List;

@RestController
@RequestMapping("/users")
@RequiredArgsConstructor
public class UserController {
    
    private final UserService userService;
    
    @GetMapping("/me")
    public ResponseEntity<ApiResponse<UserDto>> getCurrentUser(@AuthenticationPrincipal User user) {
        UserDto userDto = userService.convertToDto(user);
        return ResponseEntity.ok(ApiResponse.success(userDto));
    }
    
    @GetMapping("/search")
    public ResponseEntity<ApiResponse<List<UserDto>>> searchUsers(
            @RequestParam String query,
            @AuthenticationPrincipal User currentUser) {
        
        List<UserDto> users = userService.searchUsers(query);
        // Remove current user from search results
        users.removeIf(user -> user.getId().equals(currentUser.getId()));
        
        return ResponseEntity.ok(ApiResponse.success(users));
    }
}
