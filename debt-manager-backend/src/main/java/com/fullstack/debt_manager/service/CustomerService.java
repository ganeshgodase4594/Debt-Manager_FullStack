package com.fullstack.debt_manager.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fullstack.debt_manager.dto.UserDto;
import com.fullstack.debt_manager.entity.Customer;
import com.fullstack.debt_manager.entity.User;
import com.fullstack.debt_manager.repository.CustomerRepository;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CustomerService {
    private final CustomerRepository customerRepository;
    private final UserService userService;

    
    @Transactional
    public UserDto addCustomer(Long customerUserId, User user) {
        User customerUser = userService.findById(customerUserId);
        
        if (user.getId().equals(customerUser.getId())) {
            throw new RuntimeException("Cannot add yourself as customer");
        }
        
        if (customerRepository.existsByUserAndCustomerUser(user, customerUser)) {
            throw new RuntimeException("User is already in your customer list");
        }
        
        Customer customer = new Customer();
        customer.setUser(user);
        customer.setCustomerUser(customerUser);
        customerRepository.save(customer);
        

        
        return userService.convertToDto(customerUser);
    }
    
    public List<UserDto> getCustomers(User user) {
        return customerRepository.findByUser(user)
                .stream()
                .map(customer -> userService.convertToDto(customer.getCustomerUser()))
                .collect(Collectors.toList());
    }
    
    @Transactional
    public void removeCustomer(Long customerUserId, User user) {
        User customerUser = userService.findById(customerUserId);
        Customer customer = customerRepository.findByUserAndCustomerUser(user, customerUser)
                .orElseThrow(() -> new RuntimeException("Customer not found"));
        
        customerRepository.delete(customer);
    }
}
