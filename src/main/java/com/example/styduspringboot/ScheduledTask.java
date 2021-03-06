package com.example.styduspringboot;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.text.SimpleDateFormat;
import java.util.Date;

@Component
public class ScheduledTask {

    private Logger logger = LoggerFactory.getLogger(ScheduledTask.class);

    private static final SimpleDateFormat dateFormat = new SimpleDateFormat("HH:mm:ss");
    private int fixedDelayCount = 1;
    private int fixedRateCount = 1;
    private int initialDelayCount = 1;
    private int cronCount = 1;

//    @Scheduled(fixedDelay = 5000)        //fixedDelay = 5000表示当前方法执行完毕5000ms后，Spring scheduling会再次调用该方法
//    public void testFixDelay() {
//        logger.info("===fixedDelay: 第{}次执行方法", fixedDelayCount++);
//    }
//
//    @Scheduled(fixedRate = 5000)        //fixedRate = 5000表示当前方法开始执行5000ms后，Spring scheduling会再次调用该方法
//    public void testFixedRate() {
//        logger.info("===fixedRate: 第{}次执行方法", fixedRateCount++);
//    }
//
//    @Scheduled(initialDelay = 1000, fixedRate = 5000)   //initialDelay = 1000表示延迟1000ms执行第一次任务
//    public void testInitialDelay() {
//        logger.info("===initialDelay: 第{}次执行方法", initialDelayCount++);
//    }
//
//    @Scheduled(initialDelay = 1000, fixedDelay = 10 * 1000)
//    public void runTask1(){
//        logger.info("runTask1，第{}次执行方法. 当前时间：" + dateFormat.format(new Date()));
//    }
//
//    @Scheduled(cron = "${jobs.cron}")
//    public void runTask2ByCronTab(){
//        logger.info("runTask2ByCronTab，当前时间：" + dateFormat.format(new Date()));
//    }

}
