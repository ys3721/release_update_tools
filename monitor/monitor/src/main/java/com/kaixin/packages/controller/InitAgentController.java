package com.kaixin.packages.controller;


import com.jcraft.jsch.*;
import com.kaixin.packages.model.JSCHUserInfo;
import com.kaixin.packages.schedule.MinitorCompoent;
import com.kaixin.packages.util.AllUtil;
import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.io.SAXReader;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Properties;

import static com.kaixin.packages.util.AllUtil.*;

@Controller
public class InitAgentController {

    @Autowired
    private MinitorCompoent minitorCompoent;
    @Value("${h5.export.switch}")
    private boolean exportSwitch;

    private final static Logger logger = LoggerFactory.getLogger(MinitorCompoent.class);

    @GetMapping("initAgentHtml")
    public String initAgent(){
        return "/initAgent";
    }

    @GetMapping("")
    public String index(){
        return "/index";
    }

    @GetMapping("exportHtml")
    public String exportHtml(){
        return "/export";
    }
    @GetMapping("exportIosHtml")
    public String exportIosHtml(){
        return "/exportIos";
    }
    @GetMapping("exportAndHtml")
    public String exportAndHtml(){
        return "/exportAnd";
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
        return AllUtil.initAgent(ip);
    }

    @RequestMapping(value = "/opearAgentForm", method = RequestMethod.POST)
    public @ResponseBody String opearAgentForm(
            @RequestParam(value = "switchClose") String switchClose,
            HttpServletResponse httpServletResponse) throws IOException, JSchException {
        logger.info("switchClose"+ switchClose);
        if("0".equals(switchClose)){
            minitorCompoent.setCheck(false);
        }else {
            AllUtil.updateServer("10.10.6.140");
            minitorCompoent.setCheck(true);
        }
        return "success";
    }

    @RequestMapping(value = "/exportForm", method = RequestMethod.POST)
    public @ResponseBody String exportForm(
            @RequestParam(value = "charId") String charId,
            @RequestParam(value = "serverId") String serverId,
            @RequestParam(value = "testIp") String testIp,
            @RequestParam(value = "testPort") String testPort,
            @RequestParam(value = "bindAccount") String bindAccount,
            HttpServletResponse httpServletResponse) throws IOException, JSchException, DocumentException {
        if(!exportSwitch){
            return "当前角色导出功能关闭，监控功能打开";
        }

        logger.info(charId +" | "+serverId+" | " + " | " +testIp+" | "+testPort+" | "+bindAccount);
        //找IP /data0/wg_gmserver/WEB-INF/classes/conf/db1/h109_db.xml
        String filePath = "/data0/wg_gmserver/WEB-INF/classes/conf/db1/"+serverId.trim()+"_db.xml";
//        String filePath = "D:/"+serverId.trim()+"_db.xml";
        SAXReader reader = new SAXReader();
        Document document = reader.read(new File(filePath));
        String dbIp = document.getRootElement().element("database").attribute("dbIp").getValue();
        String dbPort = document.getRootElement().element("database").attribute("dbPort").getValue().trim();

        dbIp = dbIp.trim();
        charId = charId.trim();
        serverId = serverId.trim();
        testIp = testIp.trim();
        testPort = testPort.trim();
        bindAccount = bindAccount.trim();

        ArrayList<String> strings = new ArrayList<String>();
        strings.add("rm -rf /root/charInfo/"+charId+".sql \n\r");
        strings.add("mysqldump -t -c -umysqlac -P"+dbPort+" -ppassword -h"+dbIp+" wg_lj t_character --where='id='+"+charId+" >> /root/charInfo/"+charId+".sql \n\r");
        strings.add("mysqldump -t -c -umysqlac -P"+dbPort+" -ppassword -h"+dbIp+" wg_lj t_hero --where='charId='+"+charId+" >> /root/charInfo/"+charId+".sql \n\r");
        strings.add("mysqldump -t -c -umysqlac -P"+dbPort+" -ppassword -h"+dbIp+" wg_lj t_item --where='charId='+"+charId+" >> /root/charInfo/"+charId+".sql \n\r");
        strings.add("mysqldump -t -c -umysqlac -P"+dbPort+" -ppassword -h"+dbIp+" wg_lj t_quest --where='id='+"+charId+" >> /root/charInfo/"+charId+".sql \n\r");
        strings.add("mysqldump -t -c -umysqlac -P"+dbPort+" -ppassword -h"+dbIp+" wg_lj t_pet --where='charId='+"+charId+" >> /root/charInfo/"+charId+".sql \n\r");
        strings.add("mysqldump -t -c -umysqlac -P"+dbPort+" -ppassword -h"+dbIp+" wg_lj t_character_offline --where='id='+"+charId+" >> /root/charInfo/"+charId+".sql \n\r");
        //导出到sql 完成 mysql -umysqlac -ppassword -P3309 -h10.10.6.59 -A -N
        strings.add("mysql -umysqlac -ppassword -P"+testPort+" -h"+testIp+" wg_lj -A -N -e \"source /root/charInfo/"+charId+".sql;\" \n\r");
        strings.add("mysql -umysqlac -ppassword -P"+testPort+" -h"+testIp+" wg_lj -A -N -e \"UPDATE t_character SET passportId="+bindAccount+" WHERE id = "+charId+";\" \n\r");
        strings.add("mysql -umysqlac -ppassword -P"+testPort+" -h"+testIp+" wg_lj -A -N -e \"UPDATE t_character SET guildId=0 WHERE id = "+charId+";\" \n\r");
        //执行
        Session jschSession = getJSCHSession("10.10.9.103");//h5 GM后台
        String s = doExecJSCH(jschSession,strings);
        return "success";
    }

    @RequestMapping(value = "/exportIosForm", method = RequestMethod.POST)
    public @ResponseBody String exportIosForm(
            @RequestParam(value = "charId") String charId,
            @RequestParam(value = "serverId") String serverId,
            @RequestParam(value = "testIp") String testIp,
            @RequestParam(value = "testPort") String testPort,
            @RequestParam(value = "bindAccount") String bindAccount,
            HttpServletResponse httpServletResponse) throws IOException, JSchException, DocumentException {
        if(!exportSwitch){
            return "当前角色导出功能关闭，监控功能打开";
        }
        logger.info(charId +" | "+serverId+" | " + " | " +testIp+" | "+testPort+" | "+bindAccount);
        //找IP /data0/wg_gmserver/WEB-INF/classes/conf/db1/h109_db.xml
        String filePath = "/data0/wg_gmserver/WEB-INF/classes/conf/db1/"+serverId.trim()+"_db.xml";
//        String filePath = "D:/"+serverId.trim()+"_db.xml";
        SAXReader reader = new SAXReader();
        Document document = reader.read(new File(filePath));
        String dbIp = document.getRootElement().element("database").attribute("dbIp").getValue();
        String dbPort = document.getRootElement().element("database").attribute("dbPort").getValue().trim();

        dbIp = dbIp.trim();
        charId = charId.trim();

        testIp = testIp.trim();
        testPort = testPort.trim();
        bindAccount = bindAccount.trim();

        ArrayList<String> strings = new ArrayList<String>();
        strings.add("rm -rf /root/charInfo/"+charId+".sql \n\r");
        strings.add("mysqldump -t -c -umysqlac -P"+dbPort+" -ppassword -h"+dbIp+" wg_lj t_character --where='id='+"+charId+" >> /root/charInfo/"+charId+".sql \n\r");
        strings.add("mysqldump -t -c -umysqlac -P"+dbPort+" -ppassword -h"+dbIp+" wg_lj t_hero --where='charId='+"+charId+" >> /root/charInfo/"+charId+".sql \n\r");
        strings.add("mysqldump -t -c -umysqlac -P"+dbPort+" -ppassword -h"+dbIp+" wg_lj t_item --where='charId='+"+charId+" >> /root/charInfo/"+charId+".sql \n\r");
        strings.add("mysqldump -t -c -umysqlac -P"+dbPort+" -ppassword -h"+dbIp+" wg_lj t_quest --where='id='+"+charId+" >> /root/charInfo/"+charId+".sql \n\r");
        strings.add("mysqldump -t -c -umysqlac -P"+dbPort+" -ppassword -h"+dbIp+" wg_lj t_pet --where='charId='+"+charId+" >> /root/charInfo/"+charId+".sql \n\r");
        strings.add("mysqldump -t -c -umysqlac -P"+dbPort+" -ppassword -h"+dbIp+" wg_lj t_character_offline --where='id='+"+charId+" >> /root/charInfo/"+charId+".sql \n\r");
        strings.add("echo \"delete from t_enfeoffs_city where charId="+charId+";\" >> /root/charInfo/"+charId+".sql \n\r");
        strings.add("mysqldump -t -c -umysqlac -P"+dbPort+" -ppassword -h"+dbIp+" wg_lj t_enfeoffs_city --where='charId='+"+charId+" >> /root/charInfo/"+charId+".sql \n\r");
        //导出到sql 完成 mysql -umysqlac -ppassword -P3309 -h10.10.6.59 -A -N
        strings.add("mysql -umysqlac -ppassword -P"+testPort+" -h"+testIp+" wg_lj -A -N -e \"source /root/charInfo/"+charId+".sql;\" \n\r");
        strings.add("mysql -umysqlac -ppassword -P"+testPort+" -h"+testIp+" wg_lj -A -N -e \"UPDATE t_character SET passportId="+bindAccount+" WHERE id = "+charId+";\" \n\r");
        strings.add("mysql -umysqlac -ppassword -P"+testPort+" -h"+testIp+" wg_lj -A -N -e \"UPDATE t_character SET guildId=0 WHERE id = "+charId+";\" \n\r");
        //执行
        Session jschSession = getJSCHSession("10.10.2.3");//ios GM后台
        String s = doExecJSCH(jschSession,strings);
        logger.info(s);
        return "success";
    }

    @RequestMapping(value = "/exportAndForm", method = RequestMethod.POST)
    public @ResponseBody String exportAndForm(
            @RequestParam(value = "charId") String charId,
            @RequestParam(value = "serverId") String serverId,
            @RequestParam(value = "testIp") String testIp,
            @RequestParam(value = "testPort") String testPort,
            @RequestParam(value = "bindAccount") String bindAccount,
            HttpServletResponse httpServletResponse) throws IOException, JSchException, DocumentException {
        if(!exportSwitch){
            return "当前角色导出功能关闭，监控功能打开";
        }
        logger.info(charId +" | "+serverId+" | " + " | " +testIp+" | "+testPort+" | "+bindAccount);
        //找IP /data0/wg_gmserver/WEB-INF/classes/conf/db1/h109_db.xml
//        String filePath = "/data0/wg_gmserver/WEB-INF/classes/conf/db1/"+serverId.trim()+"_db.xml";
        String filePath = "D:/"+serverId.trim()+"_db.xml";
        SAXReader reader = new SAXReader();
        Document document = reader.read(new File(filePath));
        String dbIp = document.getRootElement().element("database").attribute("dbIp").getValue();
        String dbPort = document.getRootElement().element("database").attribute("dbPort").getValue().trim();

        dbIp = dbIp.trim();
        charId = charId.trim();
        serverId = serverId.trim();
        testIp = testIp.trim();
        testPort = testPort.trim();
        bindAccount = bindAccount.trim();

        ArrayList<String> strings = new ArrayList<String>();
        strings.add("rm -rf /root/charInfo/"+charId+".sql \n\r");
        strings.add("mysqldump -t -c -umysqlac -P"+dbPort+" -ppassword -h"+dbIp+" wg_lj t_character --where='id='+"+charId+" >> /root/charInfo/"+charId+".sql \n\r");
        strings.add("mysqldump -t -c -umysqlac -P"+dbPort+" -ppassword -h"+dbIp+" wg_lj t_hero --where='charId='+"+charId+" >> /root/charInfo/"+charId+".sql \n\r");
        strings.add("mysqldump -t -c -umysqlac -P"+dbPort+" -ppassword -h"+dbIp+" wg_lj t_item --where='charId='+"+charId+" >> /root/charInfo/"+charId+".sql \n\r");
        strings.add("mysqldump -t -c -umysqlac -P"+dbPort+" -ppassword -h"+dbIp+" wg_lj t_quest --where='id='+"+charId+" >> /root/charInfo/"+charId+".sql \n\r");
        strings.add("mysqldump -t -c -umysqlac -P"+dbPort+" -ppassword -h"+dbIp+" wg_lj t_pet --where='charId='+"+charId+" >> /root/charInfo/"+charId+".sql \n\r");
        strings.add("mysqldump -t -c -umysqlac -P"+dbPort+" -ppassword -h"+dbIp+" wg_lj t_character_offline --where='id='+"+charId+" >> /root/charInfo/"+charId+".sql \n\r");
        strings.add("echo \"delete from t_enfeoffs_city where charId="+charId+";\" >> /root/charInfo/"+charId+".sql \n\r");
        strings.add("mysqldump -t -c -umysqlac -P"+dbPort+" -ppassword -h"+dbIp+" wg_lj t_enfeoffs_city --where='charId='+"+charId+" >> /root/charInfo/"+charId+".sql \n\r");
        //导出到sql 完成 mysql -umysqlac -ppassword -P3309 -h10.10.6.59 -A -N
        strings.add("mysql -umysqlac -ppassword -P"+testPort+" -h"+testIp+" wg_lj -A -N -e \"source /root/charInfo/"+charId+".sql;\" \n\r");
        strings.add("mysql -umysqlac -ppassword -P"+testPort+" -h"+testIp+" wg_lj -A -N -e \"UPDATE t_character SET passportId="+bindAccount+" WHERE id = "+charId+";\" \n\r");
        strings.add("mysql -umysqlac -ppassword -P"+testPort+" -h"+testIp+" wg_lj -A -N -e \"UPDATE t_character SET guildId=0 WHERE id = "+charId+";\" \n\r");
        //执行
        Session jschSession = getJSCHSession("10.10.2.153");//and GM后台
        String s = doExecJSCH(jschSession,strings);
        logger.info(s);
        return "success";
    }

}
