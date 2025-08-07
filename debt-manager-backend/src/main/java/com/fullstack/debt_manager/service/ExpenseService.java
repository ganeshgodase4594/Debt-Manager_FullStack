package com.fullstack.debt_manager.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fullstack.debt_manager.dto.ExpenseDto;
import com.fullstack.debt_manager.dto.ExpenseRequest;
import com.fullstack.debt_manager.entity.Expense;
import com.fullstack.debt_manager.entity.User;
import com.fullstack.debt_manager.repository.ExpenseRepository;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ExpenseService {
    private final ExpenseRepository expenseRepository;
    private final UserService userService;
    
    @Transactional
    public ExpenseDto createExpense(ExpenseRequest request, User creator) {
        User debtor = userService.findById(request.getDebtorId());
        
        if (creator.getId().equals(debtor.getId())) {
            throw new RuntimeException("Cannot create expense for yourself");
        }
        
        Expense expense = new Expense();
        expense.setDescription(request.getDescription());
        expense.setAmount(request.getAmount());
        expense.setCreator(creator);
        expense.setDebtor(debtor);
        expense.setDueDate(request.getDueDate());
        expense.setNotes(request.getNotes());
        expense.setStatus(request.getStatus() != null ? request.getStatus() : expense.getStatus());
        
        Expense saved = expenseRepository.save(expense);
        return convertToDto(saved);
    }
    
    public List<ExpenseDto> getAllExpensesForUser(User user) {
        return expenseRepository.findAllExpensesForUser(user)
                .stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }
    
    public List<ExpenseDto> getCreatedExpenses(User user) {
        return expenseRepository.findByCreatorOrderByCreatedAtDesc(user)
                .stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }
    
    public List<ExpenseDto> getDebtorExpenses(User user) {
        return expenseRepository.findByDebtorOrderByCreatedAtDesc(user)
                .stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }
    
    @Transactional
    public ExpenseDto updateExpense(Long expenseId, ExpenseRequest request, User user) {
        Expense expense = expenseRepository.findById(expenseId)
                .orElseThrow(() -> new RuntimeException("Expense not found"));
        
        if (!expense.getCreator().getId().equals(user.getId())) {
            throw new RuntimeException("You can only update expenses you created");
        }
        
        expense.setDescription(request.getDescription());
        expense.setAmount(request.getAmount());
        expense.setDueDate(request.getDueDate());
        expense.setNotes(request.getNotes());
        
        if (request.getStatus() != null) {
            expense.setStatus(request.getStatus());
        }
        
        // Update debtor if changed
        if (!expense.getDebtor().getId().equals(request.getDebtorId())) {
            User newDebtor = userService.findById(request.getDebtorId());
            if (user.getId().equals(newDebtor.getId())) {
                throw new RuntimeException("Cannot create expense for yourself");
            }
            expense.setDebtor(newDebtor);
        }
        
        Expense saved = expenseRepository.save(expense);
        return convertToDto(saved);
    }
    
    @Transactional
    public void deleteExpense(Long expenseId, User user) {
        Expense expense = expenseRepository.findById(expenseId)
                .orElseThrow(() -> new RuntimeException("Expense not found"));
        
        if (!expense.getCreator().getId().equals(user.getId())) {
            throw new RuntimeException("You can only delete expenses you created");
        }
        
        expenseRepository.delete(expense);
    }
    
    public ExpenseDto getExpenseById(Long expenseId, User user) {
        Expense expense = expenseRepository.findById(expenseId)
                .orElseThrow(() -> new RuntimeException("Expense not found"));
        
        // Check if user has access to this expense
        if (!expense.getCreator().getId().equals(user.getId()) && 
            !expense.getDebtor().getId().equals(user.getId())) {
            throw new RuntimeException("Access denied to this expense");
        }
        
        return convertToDto(expense);
    }
    
    private ExpenseDto convertToDto(Expense expense) {
        return new ExpenseDto(
                expense.getId(),
                expense.getDescription(),
                expense.getAmount(),
                userService.convertToDto(expense.getCreator()),
                userService.convertToDto(expense.getDebtor()),
                expense.getStatus(),
                expense.getCreatedAt(),
                expense.getUpdatedAt(),
                expense.getDueDate(),
                expense.getNotes()
        );
    }
}
