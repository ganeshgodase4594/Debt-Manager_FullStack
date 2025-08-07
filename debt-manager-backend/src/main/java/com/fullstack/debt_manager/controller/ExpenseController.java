package com.fullstack.debt_manager.controller;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import com.fullstack.debt_manager.dto.ApiResponse;
import com.fullstack.debt_manager.dto.ExpenseDto;
import com.fullstack.debt_manager.dto.ExpenseRequest;
import com.fullstack.debt_manager.entity.User;
import com.fullstack.debt_manager.service.ExpenseService;

import jakarta.validation.Valid;

import java.util.List;

@RestController
@RequestMapping("/expenses")
@RequiredArgsConstructor
public class ExpenseController {
    
    private final ExpenseService expenseService;
    
    @PostMapping
    public ResponseEntity<ApiResponse<ExpenseDto>> createExpense(
            @Valid @RequestBody ExpenseRequest request,
            @AuthenticationPrincipal User user) {
        
        try {
            ExpenseDto expense = expenseService.createExpense(request, user);
            return ResponseEntity.ok(ApiResponse.success("Expense created successfully", expense));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @GetMapping
    public ResponseEntity<ApiResponse<List<ExpenseDto>>> getAllExpenses(@AuthenticationPrincipal User user) {
        List<ExpenseDto> expenses = expenseService.getAllExpensesForUser(user);
        return ResponseEntity.ok(ApiResponse.success(expenses));
    }
    
    @GetMapping("/created")
    public ResponseEntity<ApiResponse<List<ExpenseDto>>> getCreatedExpenses(@AuthenticationPrincipal User user) {
        List<ExpenseDto> expenses = expenseService.getCreatedExpenses(user);
        return ResponseEntity.ok(ApiResponse.success(expenses));
    }
    
    @GetMapping("/debts")
    public ResponseEntity<ApiResponse<List<ExpenseDto>>> getDebtorExpenses(@AuthenticationPrincipal User user) {
        List<ExpenseDto> expenses = expenseService.getDebtorExpenses(user);
        return ResponseEntity.ok(ApiResponse.success(expenses));
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<ExpenseDto>> getExpense(
            @PathVariable Long id,
            @AuthenticationPrincipal User user) {
        
        try {
            ExpenseDto expense = expenseService.getExpenseById(id, user);
            return ResponseEntity.ok(ApiResponse.success(expense));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<ExpenseDto>> updateExpense(
            @PathVariable Long id,
            @Valid @RequestBody ExpenseRequest request,
            @AuthenticationPrincipal User user) {
        
        try {
            ExpenseDto expense = expenseService.updateExpense(id, request, user);
            return ResponseEntity.ok(ApiResponse.success("Expense updated successfully", expense));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<String>> deleteExpense(
            @PathVariable Long id,
            @AuthenticationPrincipal User user) {
        
        try {
            expenseService.deleteExpense(id, user);
            return ResponseEntity.ok(ApiResponse.success("Expense deleted successfully", null));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
}