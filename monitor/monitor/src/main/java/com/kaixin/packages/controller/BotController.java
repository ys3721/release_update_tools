package com.kaixin.packages.controller;

import com.alibaba.fastjson.JSON;
import com.kaixin.packages.util.AllUtil;
import org.dom4j.DocumentException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.util.Set;

@RestController
public class BotController {

    @Value("${scheduling.platmName}")
    private String[] platmName;
    @Value("${scheduling.filePath}")
    private String filePareant;

    /**
     * 飞书机器人 校验url
     * @param httpRequest
     * @param httpResponse
     * @return
     * @throws IOException
     */
    @RequestMapping("/feiShuValid")
    public String valid(HttpServletRequest httpRequest, HttpServletResponse httpResponse) throws IOException {
        BufferedReader br = httpRequest.getReader();

        String str, wholeStr = "";
        while((str = br.readLine()) != null){
            wholeStr += str;
        }
        System.out.println(wholeStr);

        return wholeStr;
    }

    @RequestMapping("/getAllIP")
    public String getAllIP(HttpServletRequest httpRequest, HttpServletResponse httpResponse) throws IOException, DocumentException {
        BufferedReader br = httpRequest.getReader();
        Set<String> allIP = AllUtil.getAllIP(filePareant, platmName);
        return JSON.toJSONString(allIP);
    }



}
