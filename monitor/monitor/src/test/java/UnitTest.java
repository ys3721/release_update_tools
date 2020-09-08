import com.alibaba.fastjson.JSONObject;
import com.jcraft.jsch.*;
import com.kaixin.packages.model.JSCHUserInfo;
import com.kaixin.packages.model.esresult.EsResultBean;
import com.kaixin.packages.util.AllUtil;
import org.junit.Test;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Properties;

import static com.kaixin.packages.util.AllUtil.*;

public class UnitTest {


    @Test
    public void test1() throws IOException {
//        String exec = "ssh -o StrictHostKeyChecking=no -i C:\\Users\\89264\\Desktop\\id_rsa_ios root@106.52.79.53 \"ls;ls;ls\"";
//        String s = doExec(exec);
//        System.out.println(s);

//        String exec = "ssh -o StrictHostKeyChecking=no -i C:\\Users\\89264\\Desktop\\id_rsa_ios root@119.29.73.125 \"ps aux | grep metricbeat | grep -v grep \"";
//        String s = doExec(exec);
//        System.out.println(s);

//        String exec = "ssh -o StrictHostKeyChecking=no -i C:\\Users\\89264\\Desktop\\id_rsa_ios root@119.29.73.125 \"wget -nc -P /data0 http://10.10.6.140:8080/metricbeat.tar;ls\"";
////        String exec = "ssh -o StrictHostKeyChecking=no -i C:\\Users\\89264\\Desktop\\id_rsa_ios root@119.29.73.125 \"renice -n -5 $(lsof -i :22 | grep \"*\" | awk '{print $2}') ; wget -nc -P /data0 http://10.10.6.140:8080/metricbeat.tar ; tar -xzvf /data0/metricbeat.tar \"";
//        String s = doExec(exec);
//        System.out.println(s);

//        String wget = "scp -o StrictHostKeyChecking=no -i "+"C:\\Users\\89264\\Desktop\\id_rsa_ios"+" C:/Users/89264/Desktop/id_rsa_ios root@"+"119.29.73.125"+":/data0/";
//        String s = doExec(wget);
//        System.out.println(s);

    }

    @Test
    public void test2() {
        String ip = "10.10.6.86";
        String workDir = "/data1/wg_script";
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
    }

//    @Test
    public void test3() throws JSchException, IOException {
        StringBuilder stringBuilder = new StringBuilder();

        String rsaPath = "C:\\Users\\89264\\Desktop\\id_rsa_ios";
//        String rsaPath = "/root/.ssh/id_rsa_ios";
        String ipStr = "119.29.73.125";

        JSch jsch = new JSch();
        jsch.addIdentity(rsaPath,"");
        Session session=jsch.getSession("root", ipStr, 22);
        UserInfo ui= new JSCHUserInfo("") ;
        session.setUserInfo(ui);
        Properties config = new Properties();
        config.put("StrictHostKeyChecking", "no");
        session.setConfig(config);
        session.connect();

//        com.jcraft.jsch.Channel.getChannel(java.lang.String)
        ChannelExec channelExec = (ChannelExec)  session.openChannel("exec");
        String command = "ls";
        channelExec.setCommand(command);
        channelExec.setInputStream(null);
        BufferedReader input = new BufferedReader(new InputStreamReader
                (channelExec.getInputStream()));
        String line;
        while ((line = input.readLine()) != null) {
            stringBuilder.append(line + "\n");
        }
        input.close();
        // 得到returnCode
        if (channelExec.isClosed()) {
//            returnCode = channelExec.getExitStatus();
        }

        // 关闭通道
        channelExec.disconnect();
        //关闭session
        session.disconnect();

        System.out.println(stringBuilder.toString());
    }

//    @Test
    public void test4() throws Exception {
        Session jschSession = getJSCHSession("119.29.73.125");
        ArrayList<String> strings = new ArrayList<String>();
        strings.add("pwd");
        String s = doExecJSCH(jschSession,strings);
        System.out.println(s);
    }
}
