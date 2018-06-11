package com.example.styduspringboot.data.prod.dao;

import com.example.styduspringboot.data.prod.entity.Prod;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Created by philipl on 2018/6/10.
 */
public interface ProdRepository extends JpaRepository<Prod, Integer> {
}
