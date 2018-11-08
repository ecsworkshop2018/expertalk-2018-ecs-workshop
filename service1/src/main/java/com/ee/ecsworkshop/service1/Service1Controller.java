package com.ee.ecsworkshop.service1;

import java.util.concurrent.atomic.AtomicLong;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class Service1Controller {
    private static final String message = "Hello, from service1!";
    private final AtomicLong counter = new AtomicLong();

    @RequestMapping("/message")
    public ServiceMessage message() {
        return new ServiceMessage(counter.incrementAndGet(), message);
    }
}
