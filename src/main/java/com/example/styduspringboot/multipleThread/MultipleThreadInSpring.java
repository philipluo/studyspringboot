package com.example.styduspringboot.multipleThread;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
//import org.testng.annotations.Test;

import java.util.Arrays;
import java.util.List;

@Service
public class MultipleThreadInSpring {

    @Autowired
    private StudyExecutor studyExecutor;

    public void studyExecutor(){
        List<Integer> list = Arrays.asList(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18);
        list.stream().forEach(integer -> studyExecutor.executorA(integer));
        System.out.println("Main thread ends.");
    }

//    @Test
    public void testStudyExecutor(){

    }
}
