package com.fullstack.debt_manager.config;

import com.fullstack.debt_manager.security.JwtAuthenticationFilter;
import com.fullstack.debt_manager.security.JwtUtil;
import com.fullstack.debt_manager.service.UserService;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class JwtAuthenticationFilterConfig {

    @Bean
    public JwtAuthenticationFilter jwtAuthenticationFilter(JwtUtil jwtUtil, UserService userService) {
        return new JwtAuthenticationFilter(jwtUtil, userService);
    }
}