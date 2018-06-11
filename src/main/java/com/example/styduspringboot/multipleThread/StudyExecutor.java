package com.example.styduspringboot.multipleThread;

import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Service;

@Service
public class StudyExecutor {

    @Async
    public void executorA(Integer target) {
        System.out.println("Thread "+Thread.currentThread().getId()+", target = " + target);
        Double d = (Double) Math.random() * 1000;
        long random = d.longValue();
        try {
            Thread.sleep(random);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
}
