package com.karate.runner;

import com.intuit.karate.junit5.Karate;

public class TestRunner {
    @Karate.Test
    Karate testAll() {
        // "classpath:" tells Karate to search every folder in your test directory
        return Karate.run("classpath:").tags("~@ignore");
    }
}
