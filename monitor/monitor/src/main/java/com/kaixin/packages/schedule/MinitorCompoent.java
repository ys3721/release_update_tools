package com.kaixin.packages.schedule;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.kaixin.packages.model.esresult.EsResultBean;
import com.kaixin.packages.model.feishubean.Content;
import com.kaixin.packages.model.feishubean.CustomBotReq;
import org.dom4j.DocumentException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.Map;

import static com.kaixin.packages.util.AllUtil.doPost;
import static com.kaixin.packages.util.AllUtil.getFileList;

@Component
public class MinitorCompoent {
    private final static Logger logger = LoggerFactory.getLogger(MinitorCompoent.class);

    @Value("${es.url}")
    private String esUrl;
    @Value("${scheduling.filePath}")
    private String filePareant;
    @Value("${scheduling.webhook}")
    private String[] webHook;
    @Value("${scheduling.platmName}")
    private String[] platmName;

    private boolean check = true;

    @Scheduled(cron="${scheduling.monitor}")
    public void minitor() throws DocumentException {
        if(!check){
            return;
        }
        Map<String,String> fileList = getFileList(filePareant,platmName);
        for(String keyIp : fileList.keySet().toArray(new String[0])) {
            String path = fileList.get(keyIp);
            String[] split = keyIp.split(" ");
            String ip = split[0];
            int totalValue = requestByIpAndWorkDir(ip, path);
            if(totalValue == 0){
                for(String web : webHook) {
                    CustomBotReq customBotReq = new CustomBotReq("text", new Content(split[1] + " 服务器进程日志异常  请检查 " + ip + " 下 " + path + " 所属进程!"));
                    String data = JSON.toJSONString(customBotReq);
                    doPost(web.trim(), data, "POST");
                    logger.info( web + "    汇报   " + data);
                }
            }
        }
    }

    @Scheduled(cron="0 30 18 * * ?")
    public void checkSwich(){
        if(!check){
            CustomBotReq customBotReq = new CustomBotReq("text", new Content( " 当前监控程序未开启！"));
            String data = JSON.toJSONString(customBotReq);
            for(String web : webHook) {
                doPost(web.trim(), data, "POST");
            }
            return;
        }
        CustomBotReq customBotReq = new CustomBotReq("text", new Content( " 当前监控程序运行中！"));
        String data = JSON.toJSONString(customBotReq);
        for(String web : webHook) {
            doPost(web.trim(), data, "POST");
        }
    }

    public int requestByIpAndWorkDir(String ip,String workDir) {
        String reqBean = "{\n" +
                "  \"version\": true,\n" +
                "  \"size\": 0,\n" +
                "  \"from\": 0, \n" +
                "  \"query\": {\n" +
                "    \"bool\": {\n" +
                "      \"must\": [],\n" +
                "      \"filter\": [\n" +
                "        {\n" +
                "          \"bool\": {\n" +
                "            \"should\": [\n" +
                "              {\n" +
                "                \"match_phrase\": {\n" +
                "                  \"host.ip\": \""+ip+"\"\n" +
                "                }\n" +
                "              }\n" +
                "            ],\n" +
                "            \"minimum_should_match\": 1\n" +
                "          }\n" +
                "        },\n" +
                "        {\n" +
                "          \"bool\": {\n" +
                "            \"minimum_should_match\": 1,\n" +
                "            \"should\": [\n" +
                "              {\n" +
                "                \"match_phrase\": {\n" +
                "                  \"process.working_directory\": \""+workDir+"\"\n" +
                "                }\n" +
                "              }\n" +
                "            ]\n" +
                "          }\n" +
                "        },\n" +
                "        {\n" +
                "          \"range\": {\n" +
                "            \"@timestamp\": {\n" +
                "              \"gte\": \"now-1m\",\n" +
                "              \"lte\": \"now\",\n" +
                "              \"format\": \"strict_date_optional_time\"\n" +
                "            }\n" +
                "          }\n" +
                "        }\n" +
                "      ]\n" +
                "    }\n" +
                "  }\n" +
                "}";
        String x = doPost("http://106.52.90.51:8308/_search",
                reqBean,"POST");
        logger.info( ip + "   " + workDir + "ES汇报   " + x);
        EsResultBean parse = JSONObject.parseObject(x, EsResultBean.class);
        return parse.getHits().getTotal().getValue();
    }


    public boolean isCheck() {
        return check;
    }

    public void setCheck(boolean check) {
        this.check = check;
    }
}
