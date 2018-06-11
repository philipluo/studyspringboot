package com.example.styduspringboot;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class StyduspringbootApplication {

	public static void main(String[] args) {
		SpringApplication.run(StyduspringbootApplication.class, args);
	}
}
