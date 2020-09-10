package com.kaixin.packages.controller;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.jcraft.jsch.JSchException;
import com.kaixin.packages.model.feishubean.Content;
import com.kaixin.packages.model.feishubean.CustomBotReq;
import com.kaixin.packages.util.AllUtil;
import org.dom4j.DocumentException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Arrays;
import java.util.Set;

import static com.kaixin.packages.util.AllUtil.doPost;

@RestController
public class BotController {
    private final static Logger logger = LoggerFactory.getLogger(BotController.class);

    @Value("${scheduling.platmName}")
    private String[] platmName;
    @Value("${scheduling.filePath}")
    private String filePareant;
    @Value("${scheduling.webhook}")
    private String[] webHook;

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
        Set<String> allIP = AllUtil.getAllIP(filePareant, platmName);
        return JSON.toJSONString(allIP);
    }

    @RequestMapping("/getAllIpDiy")
    public String getAllIpDiy(HttpServletRequest httpRequest, HttpServletResponse httpResponse) throws IOException, DocumentException {
        String filePareantTemp = httpRequest.getParameter("filePareant");
        String platmNameTemp = httpRequest.getParameter("platmName");
        Set<String> allIP = AllUtil.getAllIP(filePareantTemp, Arrays.asList(platmNameTemp).toArray(new String[0]));
        return JSON.toJSONString(allIP);
    }

    @RequestMapping("/feiShuAgentInit")
    public JSONObject feiShuAgentInit(HttpServletRequest httpRequest, HttpServletResponse httpResponse) throws IOException, DocumentException, JSchException {
        String ip = httpRequest.getParameter("ip");
        AllUtil.initAgent(ip);
        JSONObject jsonObject = new JSONObject();
        jsonObject.put("result",AllUtil.checkMetricbeatPid(ip));
        return jsonObject;
    }
    @RequestMapping("/feiShuAgentCheck")
    public JSONObject feiShuAgentCheck(HttpServletRequest httpRequest, HttpServletResponse httpResponse) throws IOException, DocumentException, JSchException {
        String ip = httpRequest.getParameter("ip");
        JSONObject jsonObject = new JSONObject();
        jsonObject.put("result",AllUtil.checkMetricbeatPid(ip));
        return jsonObject;
    }

    @RequestMapping("/feiShuAgentOper")
    public JSONObject feiShuAgentOper(HttpServletRequest httpRequest, HttpServletResponse httpResponse)
            throws IOException, DocumentException, JSchException {
        //获取body数据
        BufferedReader reader = new BufferedReader(new InputStreamReader(httpRequest.getInputStream()));
        String line = null;
        StringBuilder sb = new StringBuilder();
        while((line = reader.readLine())!=null){
            sb.append(line);
        }
        String postContent = sb.toString();
        JSONObject jsonObject = JSONObject.parseObject(postContent, JSONObject.class);
        String data = jsonObject.getString("data");
        jsonObject.clear();
        logger.info(data+ " <<<< 接受");
        boolean result = false;
        if(data == null){
            jsonObject.put("result","未知指令!");
        }else if(data.startsWith("cm")){
            logger.info(data+ " <<<< 进入进程检查");

            String ip = data.substring(2);
            result = AllUtil.checkMetricbeatPid(ip);
            jsonObject.put("result",result);
        }else if(data.startsWith("init")) {
            logger.info(data+ " <<<< 进入部署");

            String ip = data.substring(4);
            result = AllUtil.checkMetricbeatPid(ip);
            if(!result) {
                logger.info(data+ " <<<< 代理部署中");
                AllUtil.initAgent(ip);
                result = AllUtil.checkMetricbeatPid(ip);
            }
            jsonObject.put("result",result);
        }
        CustomBotReq customBotReq = new CustomBotReq("text", new Content((result?"成功":"失败") ));
        data = JSON.toJSONString(customBotReq);
        doPost(webHook[0].trim(), data, "POST");
        return jsonObject;
    }



}
