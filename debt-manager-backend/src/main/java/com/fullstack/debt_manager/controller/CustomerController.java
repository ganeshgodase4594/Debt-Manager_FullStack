package com.fullstack.debt_manager.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import com.fullstack.debt_manager.dto.ApiResponse;
import com.fullstack.debt_manager.dto.UserDto;
import com.fullstack.debt_manager.entity.User;
import com.fullstack.debt_manager.service.CustomerService;

import java.util.List;

@RestController
@RequestMapping("/customers")
@RequiredArgsConstructor
public class CustomerController {
    
    private final CustomerService customerService;
    
    @GetMapping
    public ResponseEntity<ApiResponse<List<UserDto>>> getCustomers(@AuthenticationPrincipal User user) {
        List<UserDto> customers = customerService.getCustomers(user);
        return ResponseEntity.ok(ApiResponse.success(customers));
    }
    
    @PostMapping("/{userId}")
    public ResponseEntity<ApiResponse<UserDto>> addCustomer(
            @PathVariable Long userId,
            @AuthenticationPrincipal User user) {
        
        try {
            UserDto customer = customerService.addCustomer(userId, user);
            return ResponseEntity.ok(ApiResponse.success("Customer added successfully", customer));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @DeleteMapping("/{userId}")
    public ResponseEntity<ApiResponse<String>> removeCustomer(
            @PathVariable Long userId,
            @AuthenticationPrincipal User user) {
        
        try {
            customerService.removeCustomer(userId, user);
            return ResponseEntity.ok(ApiResponse.success("Customer removed successfully", null));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
}