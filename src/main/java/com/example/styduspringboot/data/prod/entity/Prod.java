package com.example.styduspringboot.data.prod.entity;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;

@ToString
@Setter
@Getter
@Entity
@Table(name = "prod")
public class Prod {

    @Id
    @GeneratedValue(strategy= GenerationType.AUTO)
    private Integer id;
    @Column(name = "prod_name")
    private String prodName;
    @Column(name = "sku_no")
    private int skuNo;

    protected Prod() {}

    public Prod(String prodName, int skuNo){
        this.prodName=prodName;
        this.skuNo=skuNo;
    }

}
