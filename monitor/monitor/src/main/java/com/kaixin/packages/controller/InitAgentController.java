package com.kaixin.packages.controller;


import com.kaixin.packages.schedule.MinitorCompoent;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

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
            HttpServletResponse httpServletResponse) throws IOException {
        logger.info(ip + "platform");
        logger.info(platform);
        Process exec = Runtime.getRuntime().exec("");
        return "success";
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
