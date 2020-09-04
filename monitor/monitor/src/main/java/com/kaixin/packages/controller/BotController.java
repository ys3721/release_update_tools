package com.kaixin.packages.controller;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;

@RestController
public class BotController {

    @RequestMapping("/")
    public String valid(HttpServletRequest httpRequest, HttpServletResponse httpResponse) throws IOException {
        BufferedReader br = httpRequest.getReader();

        String str, wholeStr = "";
        while((str = br.readLine()) != null){
            wholeStr += str;
        }
        System.out.println(wholeStr);

        return wholeStr;
    }
}