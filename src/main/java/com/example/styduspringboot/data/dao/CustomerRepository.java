package com.example.styduspringboot.data.dao;

import com.example.styduspringboot.data.entity.Customer;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CustomerRepository extends JpaRepository<Customer, Integer> {
}
