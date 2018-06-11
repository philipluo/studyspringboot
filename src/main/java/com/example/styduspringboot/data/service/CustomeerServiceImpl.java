package com.example.styduspringboot.data.service;

import com.example.styduspringboot.data.entity.Customer;
import com.example.styduspringboot.data.dao.CustomerRepository;
import com.example.styduspringboot.data.prod.dao.ProdRepository;
import com.example.styduspringboot.data.prod.entity.Prod;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Query;
import java.util.List;

@Slf4j
@Service
public class CustomeerServiceImpl implements CustomerService {

    @Autowired
    private CustomerRepository customerRepository;

    @Autowired
    private ProdRepository prodRepository;

    @Override
    @Transactional
    public void saveCustomer() {
        Customer c1 = new Customer("Philip2", "Luo");
        Customer c2 = new Customer("Max2", "Luo");
        customerRepository.saveAndFlush(c1);
        customerRepository.saveAndFlush(c2);

        List<Customer> list = customerRepository.findAll();
        list.forEach(customer -> log.info("c[{}]: Fisrt Name:{}, Last Name:{}"
                ,customer.getId()
                ,customer.getFirstName()
                ,customer.getLastName()));
    }

    @Override
    @Transactional("prodTransactionManager")
    public void saveProd(){
        Prod p1 = new Prod("Prod1", 1);
        Prod p2 = new Prod("Prod2", 2);
        prodRepository.saveAndFlush(p1);
        prodRepository.saveAndFlush(p2);
        List<Prod> prodList =  prodRepository.findAll();
        prodList.forEach(prod -> log.info("p[{}]: Prod Name:{}, skuNo:{}",
                prod.getId(),
                prod.getProdName(),
                prod.getSkuNo()
        ));

    }
}


