package com.example.styduspringboot;

import com.example.styduspringboot.data.entity.Customer;
import com.example.styduspringboot.data.dao.CustomerRepository;
import com.example.styduspringboot.data.service.CustomerService;
import com.example.styduspringboot.multipleThread.MultipleThreadInSpring;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;

import javax.transaction.Transactional;
import java.util.List;

//@Configuration   //标注一个类是配置类，spring boot在扫到这个注解时自动加载这个类相关的功能，比如前面的文章中介绍的配置AOP和拦截器时加在类上的Configuration
//@EnableAutoConfiguration()  //启用自动配置 该框架就能够进行行为的配置，以引导应用程序的启动与运行, 根据导入的starter-pom 自动加载配置
//@ComponentScan(value={"com.*","com.example.styduspringboot.data"})
//@EnableJpaRepositories(basePackages={"com.example.styduspringboot.data"})
//@EntityScan("com.example.styduspringboot.data")
@RunWith(SpringRunner.class)
@SpringBootTest(value = "")
public class StyduspringbootApplicationTests {

	@Autowired
	private MultipleThreadInSpring multipleThreadInSpring;

	@Autowired
	private CustomerService customerService;

	@Autowired
	private CustomerRepository customerRepository;

	@Test
	public void contextLoads() {
		System.out.println("test");
	}

	@Test
	public void testStudyExecutor(){
		multipleThreadInSpring.studyExecutor();
		System.out.println("end");
	}

	@Test
//	@Transactional
	public void testCustomerRepository(){
		customerService.saveCustomer();
		customerService.saveProd();
//		Customer c1 = new Customer("Philip", "Luo");
//		Customer c2 = new Customer("Max", "Luo");
//		customerRepository.saveAndFlush(c1);
//		customerRepository.saveAndFlush(c2);
//
//		List<Customer> list = customerRepository.findAll();
//		list.forEach(System.out::println);
	}

}
