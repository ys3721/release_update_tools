package com.kaixin.packages;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class Start {
    private final static Logger logger = LoggerFactory.getLogger(Start.class);
    public static void main(String[] args) {
        SpringApplication.run(Start.class, args);
    }





}