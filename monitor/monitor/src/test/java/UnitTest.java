import com.alibaba.fastjson.JSON;
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
import java.util.List;
import java.util.Properties;

import static com.kaixin.packages.util.AllUtil.*;

public class UnitTest {


//    @Test
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

//    @Test
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

//    @Test
    public void test5() throws Exception {
        Session jschSession = getJSCHSession("106.52.24.200");
        ArrayList<String> strings = new ArrayList<String>();
        strings.add("ps aux | grep metricbeat | grep -v grep \n\r");
        String s = doExecJSCH(jschSession,strings);
        if(s.contains("metricbeat.yml")){
            System.out.println("true");
        }
        System.out.println(s);
    }

//    @Test
    public void test6() throws InterruptedException {
        String ips = "[\"10.10.6.51\",\"10.10.6.52\",\"10.10.6.54\",\"10.10.6.50\",\"10.10.6.108\",\"10.10.6.229\",\"10.10.6.228\",\"10.10.6.107\",\"10.10.9.49\",\"10.10.6.56\",\"10.10.6.57\",\"10.10.9.167\",\"10.10.9.200\",\"10.10.9.166\",\"10.10.6.58\",\"10.10.6.199\",\"10.10.6.111\",\"10.10.6.198\",\"10.10.6.110\",\"10.10.6.234\",\"10.10.6.113\",\"10.10.6.233\",\"10.10.6.115\",\"10.10.6.236\",\"10.10.6.235\",\"10.10.6.117\",\"10.10.6.116\",\"10.10.6.190\",\"10.10.6.192\",\"10.10.6.195\",\"10.10.6.194\",\"10.10.6.197\",\"10.10.9.35\",\"10.10.6.41\",\"10.10.6.42\",\"10.10.6.218\",\"10.10.6.48\",\"10.10.6.217\",\"10.10.6.49\",\"10.10.6.219\",\"10.10.9.179\",\"10.10.2.209\",\"10.10.6.221\",\"10.10.6.188\",\"10.10.6.220\",\"10.10.6.187\",\"10.10.6.102\",\"10.10.6.101\",\"10.10.9.203\",\"10.10.6.225\",\"10.10.6.182\",\"10.10.6.181\",\"10.10.6.184\",\"10.10.6.186\",\"10.10.6.30\",\"10.10.6.31\",\"10.10.2.153\",\"10.10.6.32\",\"10.10.9.20\",\"10.10.9.143\",\"10.10.6.38\",\"10.10.6.35\",\"10.10.6.36\",\"10.10.6.133\",\"10.10.6.132\",\"10.10.6.135\",\"10.10.6.137\",\"10.10.6.138\",\"10.10.6.130\",\"10.10.6.20\",\"10.10.9.150\",\"10.10.6.26\",\"10.10.6.118\",\"10.10.6.239\",\"10.10.6.28\",\"10.10.2.149\",\"10.10.2.69\",\"10.10.6.22\",\"10.10.6.23\",\"10.10.6.24\",\"10.10.6.25\",\"10.10.6.121\",\"10.10.6.242\",\"10.10.6.124\",\"10.10.6.123\",\"10.10.6.244\",\"10.10.6.19\",\"10.10.6.246\",\"10.10.6.249\",\"10.10.6.127\",\"10.10.6.241\",\"10.10.6.120\",\"10.10.6.240\",\"10.10.6.96\",\"10.10.6.93\",\"10.10.6.94\",\"10.10.6.15\",\"10.10.6.18\",\"10.10.9.124\",\"10.10.6.12\",\"10.10.6.13\",\"10.10.6.14\",\"10.10.6.155\",\"10.10.6.154\",\"10.10.6.156\",\"10.10.9.236\",\"10.10.6.158\",\"10.10.9.82\",\"10.10.6.153\",\"10.10.6.152\",\"10.10.6.84\",\"10.10.6.85\",\"10.10.9.79\",\"10.10.6.86\",\"10.10.6.87\",\"10.10.6.80\",\"10.10.6.81\",\"10.10.6.88\",\"10.10.6.143\",\"10.10.6.146\",\"10.10.9.127\",\"10.10.6.145\",\"10.10.2.37\",\"10.10.6.148\",\"10.10.6.149\",\"10.10.6.142\",\"10.10.6.141\",\"10.10.9.67\",\"10.10.6.75\",\"10.10.2.196\",\"10.10.6.71\",\"10.10.9.181\",\"10.10.9.61\",\"10.10.6.207\",\"10.10.6.206\",\"10.10.9.186\",\"10.10.6.209\",\"10.10.6.77\",\"10.10.6.78\",\"10.10.6.79\",\"10.10.6.177\",\"10.10.2.2\",\"10.10.6.176\",\"10.10.6.212\",\"10.10.6.214\",\"10.10.6.216\",\"10.10.6.215\",\"10.10.6.6\",\"10.10.6.171\",\"10.10.6.5\",\"10.10.6.170\",\"10.10.6.4\",\"10.10.6.173\",\"10.10.6.3\",\"10.10.6.2\",\"10.10.6.175\",\"10.10.6.174\",\"10.10.6.62\",\"10.10.6.63\",\"10.10.6.64\",\"10.10.6.65\",\"10.10.6.9\",\"10.10.6.60\",\"10.10.9.50\",\"10.10.6.61\",\"10.10.9.230\",\"10.10.6.67\",\"10.10.6.69\",\"10.10.6.165\",\"10.10.6.201\",\"10.10.6.168\",\"10.10.6.167\",\"10.10.6.200\",\"10.10.6.203\",\"10.10.6.169\",\"10.10.6.202\",\"10.10.6.205\",\"10.10.6.204\",\"10.10.9.229\",\"10.10.6.160\",\"10.10.6.162\",\"10.10.6.161\",\"10.10.6.164\"]";
        List<String> arrayLists = JSON.parseArray(ips, String.class);
        for(String ip : arrayLists){
            System.out.println(ip);
            String get = doPost("http://106.52.90.51:8037/feiShuAgentOper", "{\n" +
                    "\t\"data\": \"init"+ip+"\"\n" +
                    "}", "POST");
//            Thread.sleep(1000);
        }
    }
}
