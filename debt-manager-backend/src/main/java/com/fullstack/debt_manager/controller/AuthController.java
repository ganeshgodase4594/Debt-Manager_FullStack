package com.fullstack.debt_manager.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import com.fullstack.debt_manager.dto.ApiResponse;
import com.fullstack.debt_manager.dto.AuthRequest;
import com.fullstack.debt_manager.dto.AuthResponse;
import com.fullstack.debt_manager.dto.RegisterRequest;
import com.fullstack.debt_manager.entity.User;
import com.fullstack.debt_manager.security.JwtUtil;
import com.fullstack.debt_manager.service.UserService;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {
    
    private final AuthenticationManager authenticationManager;
    private final UserService userService;
    private final JwtUtil jwtUtil;
    
    @PostMapping("/register")
    public ResponseEntity<ApiResponse<AuthResponse>> register(@Valid @RequestBody RegisterRequest request) {
        try {
            User user = userService.createUser(request);
            String jwt = jwtUtil.generateToken(user);
            
            AuthResponse response = new AuthResponse(jwt, user.getId(), user.getUsername(), user.getEmail(), user.getFullName());
            return ResponseEntity.ok(ApiResponse.success("User registered successfully", response));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthResponse>> login(@Valid @RequestBody AuthRequest request) {
        try {
            Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getUsername(), request.getPassword())
            );
            
            User user = (User) authentication.getPrincipal();
            String jwt = jwtUtil.generateToken(user);
            
            AuthResponse response = new AuthResponse(jwt, user.getId(), user.getUsername(), user.getEmail(), user.getFullName());
            return ResponseEntity.ok(ApiResponse.success("Login successful", response));
        } catch (BadCredentialsException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("Invalid username or password"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("Login failed: " + e.getMessage()));
        }
    }
}
