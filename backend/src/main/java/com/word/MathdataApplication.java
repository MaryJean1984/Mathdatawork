package com.word;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.transaction.annotation.EnableTransactionManagement;
import org.mybatis.spring.annotation.MapperScan;

@SpringBootApplication
@EnableCaching
@EnableTransactionManagement
@MapperScan("com.word.mapper")
public class MathdataApplication {
    public static void main(String[] args) {
        SpringApplication.run(MathdataApplication.class, args);
    }
}
