package com.kaixin.packages.controller;


import com.jcraft.jsch.*;
import com.kaixin.packages.model.JSCHUserInfo;
import com.kaixin.packages.schedule.MinitorCompoent;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Properties;

import static com.kaixin.packages.util.AllUtil.*;

@Controller
public class InitAgentController {

    @Autowired
    private MinitorCompoent minitorCompoent;

    private final static Logger logger = LoggerFactory.getLogger(MinitorCompoent.class);

    @GetMapping("initAgentHtml")
    public String initAgent(){
        return "/initAgent";
    }

    @GetMapping("")
    public String index(){
        return "/index";
    }

    @GetMapping("opearAgentHtml")
    public String opearAgent(){
        return "/opearAgent";
    }

    @GetMapping("opearAgentCheck")
    public @ResponseBody String opearAgentCheck(){
        return minitorCompoent.isCheck() ? "开" : "关";
    }

    @RequestMapping(value = "/initAgentForm", method = RequestMethod.POST)
    public @ResponseBody String initAgentForm(
            @RequestParam(value = "IP") String ip,
            @RequestParam(value = "platform") String platform,
            HttpServletResponse httpServletResponse) throws IOException, JSchException, InterruptedException {
        logger.info(ip + " platform " + platform);
        StringBuilder stringBuilder = new StringBuilder();
        String ipStr = ip.trim();
        Session jschSession = getJSCHSession(ipStr);
        ArrayList<String> strings = new ArrayList<String>();
        strings.add("cd /data0 \n\r");
        strings.add("renice -n -5 $(lsof -i :22 | grep \"*\" | awk '{print $2}') \n\r");
        strings.add("ps aux | grep metricbeat | grep -v grep \n\r");
        strings.add("wget -nc -P /data0 http://10.10.6.140:8080/metricbeat.tar \n\r");
        strings.add("tar -xzvf /data0/metricbeat.tar -C /data0/ \n\r");
        strings.add("nohup /data0/metricbeat/metricbeat -e -c /data0/metricbeat/metricbeat.yml > /dev/null 2>&1 & \n\r");
        strings.add("pwd \n\r");
        //  nohup /root/metricbeat/metricbeat -e -c /root/metricbeat/metricbeat.yml 2 > /dev/null
        String s = doExecJSCH(jschSession,strings);
        return s;
    }

    @RequestMapping(value = "/opearAgentForm", method = RequestMethod.POST)
    public @ResponseBody String opearAgentForm(
            @RequestParam(value = "switchClose") String switchClose,
            HttpServletResponse httpServletResponse) throws IOException {
        logger.info("switchClose"+ switchClose);
        if("0".equals(switchClose)){
            minitorCompoent.setCheck(false);
        }else {
            minitorCompoent.setCheck(true);
        }
        return "success";
    }

}
