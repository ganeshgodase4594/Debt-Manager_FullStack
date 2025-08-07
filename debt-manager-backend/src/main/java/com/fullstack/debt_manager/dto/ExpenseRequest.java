package com.fullstack.debt_manager.dto;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import com.fullstack.debt_manager.entity.ExpenseStatus;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;


@Data
public class ExpenseRequest {
    @NotBlank(message = "Description is required")
    private String description;
    
    @NotNull(message = "Amount is required")
    @DecimalMin(value = "0.01", message = "Amount must be greater than 0")
    private BigDecimal amount;
    
    @NotNull(message = "Debtor ID is required")
    private Long debtorId;
    
    private LocalDateTime dueDate;
    private String notes;
    private ExpenseStatus status;
}