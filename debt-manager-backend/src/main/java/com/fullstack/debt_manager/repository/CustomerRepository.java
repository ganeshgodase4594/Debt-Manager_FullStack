package com.fullstack.debt_manager.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import org.springframework.stereotype.Repository;

import com.fullstack.debt_manager.entity.Customer;
import com.fullstack.debt_manager.entity.User;

import java.util.List;
import java.util.Optional;

@Repository
public interface CustomerRepository extends JpaRepository<Customer, Long> {
    List<Customer> findByUser(User user);
    Optional<Customer> findByUserAndCustomerUser(User user, User customerUser);
    boolean existsByUserAndCustomerUser(User user, User customerUser);
}
