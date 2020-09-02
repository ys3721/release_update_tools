package com.kaixin.packages;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import org.apache.commons.io.FileUtils;
import org.apache.commons.io.IOUtils;
import org.apache.commons.io.LineIterator;
import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.HashSet;
import java.util.Set;

@SpringBootApplication
@EnableScheduling
public class Start {
    @Value("${scheduling.filePath}")
    private String filePareant;
    @Value("${scheduling.webhook}")
    private String[] webHook;

    private final static Logger logger = LoggerFactory.getLogger(Start.class);

    public static void main(String[] args) {
        SpringApplication.run(Start.class, args);
    }

    @Scheduled(cron="${scheduling.monitor}")
    public void minitor(){
        Set<String> fileList = getFileList(filePareant);
        System.out.println("======================================");
        for(String string : fileList) {
            String ip = string;
            String ips = "{\"version\":true,\"size\":0,\"from\":0,\"sort\":[{\"@timestamp\":{\"order\":\"desc\",\"unmapped_type\":\"boolean\"}}],\"stored_fields\":[\"*\"],\"script_fields\":{},\"_source\":{\"excludes\":[\"*\"]},\"query\":{\"bool\":{\"must\":[],\"filter\":[{\"bool\":{\"should\":[{\"match_phrase\":{\"host.ip\":\"" + ip + "\"}}],\"minimum_should_match\":1}},{\"range\":{\"@timestamp\":{\"gte\":\"now-15s\",\"lte\":\"now\",\"format\":\"strict_date_optional_time\"}}}]}}}";
            String x = doPost("http://106.52.90.51:8308/_search",
                    ips,"POST");
            logger.info(x);
            JsonRootBean jsonRootBean = JSONObject.parseObject(x, JsonRootBean.class);
            int value = jsonRootBean.getHits().getTotal().getValue();
            if(value == 0){
                //send feishu
                for(String web : webHook) {
                    String reason = doPost(web.trim(), "{\n" +
                            "    \"events\":[\n" +
                            "        {\n" +
                            "            \"data\":\"" + ip + "\"\n" +
                            "        }\n" +
                            "    ]\n" +
                            "}", "POST");

                    logger.info(web+"    汇报");
                }
            }
        }
        System.out.println("======================================");
    }

    public static String doPost(String httpUrl, String param,String method) {
        HttpURLConnection connection = null;
        InputStream is = null;
        OutputStream os = null;
        BufferedReader br = null;
        String result = null;
        try {
            URL url = new URL(httpUrl);
            // 通过远程url连接对象打开连接
            connection = (HttpURLConnection) url.openConnection();
            // 设置连接请求方式
            connection.setRequestMethod(method);
            // 设置连接主机服务器超时时间：15000毫秒
            connection.setConnectTimeout(15000);
            // 设置读取主机服务器返回数据超时时间：60000毫秒
            connection.setReadTimeout(60000);
            // 默认值为：false，当向远程服务器传送数据/写数据时，需要设置为true
            connection.setDoOutput(true);
            // 默认值为：true，当前向远程服务读取数据时，设置为true，该参数可有可无
            connection.setDoInput(true);
            // 设置传入参数的格式:请求参数应该是 name1=value1&name2=value2 的形式。
            connection.setRequestProperty("Content-Type", "application/json");
            // 通过连接对象获取一个输出流
            os = connection.getOutputStream();
            // 通过输出流对象将参数写出去/传输出去,它是通过字节数组写出的
            os.write(param.getBytes());
            // 通过连接对象获取一个输入流，向远程读取
            if (connection.getResponseCode() == 200) {

                is = connection.getInputStream();
                // 对输入流对象进行包装:charset根据工作项目组的要求来设置
                br = new BufferedReader(new InputStreamReader(is, "UTF-8"));

                StringBuffer sbf = new StringBuffer();
                String temp = null;
                // 循环遍历一行一行读取数据
                while ((temp = br.readLine()) != null) {
                    sbf.append(temp);
                    sbf.append("\r\n");
                }
                result = sbf.toString();
            }
        } catch (MalformedURLException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            // 关闭资源
            if (null != br) {
                try {
                    br.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
            if (null != os) {
                try {
                    os.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
            if (null != is) {
                try {
                    is.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
            // 断开与远程地址url的连接
            connection.disconnect();
        }
        return result;
    }

    public static Set<String> getFileList(String parentDirFile){
        HashSet<String> strings = new HashSet<String>();
        File file = new File(parentDirFile);
        if(file.isDirectory()){
            String[] list = file.list();
            for(String fileTemp : list){
                File file1 = new File(parentDirFile + "/"+fileTemp);
                if(file1.isDirectory()){
                    continue;
                }
                FileInputStream inputStream = null;
                try {
                    inputStream = FileUtils.openInputStream(file1);
                    LineIterator it = IOUtils.lineIterator(inputStream, "UTF-8");
                    String line = it.nextLine();
                    System.out.println(line);
                    String[] s1 = line.split(" ");
                    if(s1.length == 7) {
                        strings.add(s1[3]);
                    }
                } catch (IOException e) {
                    e.printStackTrace();
                }finally {
                    if(inputStream!=null){
                        try {
                            inputStream.close();
                        } catch (IOException e) {
                            e.printStackTrace();
                        }
                    }
                }
            }
        }
        return strings;

    }

    @Test
    public void test1() {
        Set<String> fileList = getFileList("D:\\file");
    }

    @Test
    public void test() {
        String ip = "10.10.6.140";
        String ips = "{\"version\":true,\"size\":0,\"from\":0,\"sort\":[{\"@timestamp\":{\"order\":\"desc\",\"unmapped_type\":\"boolean\"}}],\"stored_fields\":[\"*\"],\"script_fields\":{},\"_source\":{\"excludes\":[\"*\"]},\"query\":{\"bool\":{\"must\":[],\"filter\":[{\"bool\":{\"should\":[{\"match_phrase\":{\"host.ip\":\"" + ip + "\"}}],\"minimum_should_match\":1}},{\"range\":{\"@timestamp\":{\"gte\":\"now-15s\",\"lte\":\"now\",\"format\":\"strict_date_optional_time\"}}}]}}}";
        String x = doPost("http://106.52.90.51:8308/_search",
                ips,"POST");
    }
}