package com.kaixin.packages.schedule;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.kaixin.packages.model.esresult.EsResultBean;
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

    @Scheduled(cron="${scheduling.monitor}")
    public void minitor() throws DocumentException {
        Map<String,String> fileList = getFileList(filePareant,platmName);
        for(String keyIp : fileList.keySet().toArray(new String[0])) {
            String path = fileList.get(keyIp);
            int totalValue = requestByIpAndWorkDir(keyIp, path);
            if(totalValue == 0){
                for(String web : webHook) {
                    String data = JSON.toJSONString(new CustomBotReq("服务器进程日志异常","请检查 "+keyIp+" 下 "+path+"所属进程"));
                    doPost(web.trim(), data, "POST");
                    logger.info( web + "    汇报   " + data);
                }
            }
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
        System.out.println(x);
        EsResultBean parse = JSONObject.parseObject(x, EsResultBean.class);
        System.out.println(parse.getHits().getTotal().getValue());
        return parse.getHits().getTotal().getValue();
    }


}
