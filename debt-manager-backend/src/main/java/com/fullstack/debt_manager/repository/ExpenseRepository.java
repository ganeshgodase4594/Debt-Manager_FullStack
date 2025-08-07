package com.fullstack.debt_manager.repository;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.fullstack.debt_manager.entity.Expense;
import com.fullstack.debt_manager.entity.User;

import java.util.List;

@Repository
public interface ExpenseRepository extends JpaRepository<Expense, Long> {
    List<Expense> findByCreatorOrderByCreatedAtDesc(User creator);
    List<Expense> findByDebtorOrderByCreatedAtDesc(User debtor);
    
    @Query("SELECT e FROM Expense e WHERE e.creator = :user OR e.debtor = :user ORDER BY e.createdAt DESC")
    List<Expense> findAllExpensesForUser(@Param("user") User user);
    
    @Query("SELECT e FROM Expense e WHERE (e.creator = :user1 AND e.debtor = :user2) OR (e.creator = :user2 AND e.debtor = :user1) ORDER BY e.createdAt DESC")
    List<Expense> findExpensesBetweenUsers(@Param("user1") User user1, @Param("user2") User user2);
}
