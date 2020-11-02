package com.kaixin.packages.util;

import com.jcraft.jsch.ChannelShell;
import com.jcraft.jsch.JSch;
import com.jcraft.jsch.JSchException;
import com.jcraft.jsch.Session;
import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.io.SAXReader;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.*;

public class AllUtil {

    private final static Logger logger = LoggerFactory.getLogger(AllUtil.class);

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

    public static Map<String,String> getFileList(String parentDirFile, String[] platformName) throws DocumentException {
        HashMap<String,String> strings = new HashMap<String,String>();
        for(String platform : platformName) {
            String path = parentDirFile + platform;
            File file = new File(path);
            if (file.isDirectory()) {
                String[] list = file.list();
                for (String fileTemp : list) {
                    if(!fileTemp.endsWith(".xml")){
                        continue;
                    }
                    File file1 = new File(path + "/" +fileTemp);
                    if (file1.isDirectory()) {
                        continue;
                    }
                    SAXReader reader = new SAXReader();
                    Document document = reader.read(file1);
                    String database = document.getRootElement().element("database").attribute("dbIp").getValue();
                    String dbPort = document.getRootElement().element("database").attribute("dbPort").getValue();
                    String svrName = document.getRootElement().element("database").attribute("svrName").getValue();
                    if(dbPort.equals("3306")) {
                        strings.put(database+" "+svrName, "/data0/wg_script");
                    }
                    if(dbPort.equals("3307")) {
                        strings.put(database+" "+svrName, "/data1/wg_script");
                    }
                    if(dbPort.equals("3308")) {
                        strings.put(database+" "+svrName, "/data5/wg_script");
                    }
                    if(dbPort.equals("3309")) {
                        strings.put(database+" "+svrName, "/data6/wg_script");
                    }
                    logger.info(database + " " +svrName);
                }
            }
        }
        return strings;
    }

    public static Set<String> getAllIP(String parentDirFile, String[] platformName) throws DocumentException {
        HashSet<String> strings = new HashSet<String>();
        for(String platform : platformName) {
            String path = parentDirFile + platform;
            File file = new File(path);
            if (file.isDirectory()) {
                String[] list = file.list();
                for (String fileTemp : list) {
                    File file1 = new File(path + "/" +fileTemp);
                    if (file1.isDirectory()) {
                        continue;
                    }
                    SAXReader reader = new SAXReader();
                    Document document = reader.read(file1);
                    String dbIp = document.getRootElement().element("database").attribute("dbIp").getValue();
                    strings.add(dbIp);
                }
            }
        }
        return strings;
    }

    public static String doExec(String str) throws IOException, InterruptedException {
        Process exec = Runtime.getRuntime().exec(str);

        java.io.InputStream is = exec.getInputStream();
        java.util.Scanner s = new java.util.Scanner(is).useDelimiter("\\A");
        StringBuilder val = new StringBuilder();
        if (s.hasNext()) {
            val.append(s.next());
        }
        Thread.sleep(5000);
        s.close();
        is.close();
        return val.toString();
    }

    public static Session getJSCHSession(String ip) throws JSchException {
        return getJSCHSession(ip,"root","P7QQQo5o1yx9");
    }

    public static Session getJSCHSession(String ip,String account,String pwd) throws JSchException {
        JSch jsch = new JSch();
        Session session = jsch.getSession(account, ip, 22);
        session.setPassword(pwd);
        session.setConfig("StrictHostKeyChecking", "no");
        session.connect(60 * 1000);
        return session;
    }

    public static String doExecJSCH(Session session,List<String> commands) throws JSchException, IOException {
        ChannelShell channel = (ChannelShell) session.openChannel("shell");
        channel.connect();
        InputStream inputStream = channel.getInputStream();
        OutputStream outputStream = channel.getOutputStream();
        for(String command : commands){
            outputStream.write(command.getBytes());
        }
        String cmd4 = "exit \n\r";
        outputStream.write(cmd4.getBytes());
        outputStream.flush();
        BufferedReader in = new BufferedReader(new InputStreamReader(inputStream));
        StringBuilder sb = new StringBuilder();
        String msg = null;
        while((msg = in.readLine())!=null){
            sb.append("\n").append(msg);
        }
        in.close();
        return sb.toString();
    }

    public static boolean checkMetricbeatPid(String ip) throws JSchException, IOException {
        Session jschSession = getJSCHSession(ip);
        ArrayList<String> strings = new ArrayList<String>();
        strings.add("ps aux | grep metricbeat | grep -v grep \n\r");
        String s = doExecJSCH(jschSession,strings);
        if(s.contains("metricbeat.yml")){
            return true;
        }else{
            return false;
        }
    }

    public static String initAgent(String ip) throws JSchException, IOException {
        boolean result = AllUtil.checkMetricbeatPid(ip);
        if(result){
            return "已安装";
        }
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
        String s = doExecJSCH(jschSession,strings);
        return s;
    }
    public static String startAgent(String ip) throws JSchException, IOException {
        String ipStr = ip.trim();
        Session jschSession = getJSCHSession(ipStr);
        ArrayList<String> strings = new ArrayList<String>();
        strings.add("cd /data0 \n\r");
        strings.add("nohup /data0/metricbeat/metricbeat -e -c /data0/metricbeat/metricbeat.yml > /dev/null 2>&1 & \n\r");
        String s = doExecJSCH(jschSession,strings);
        return s;
    }

    public static String updateServer(String ip) throws JSchException, IOException {
        String ipStr = ip.trim();
        Session jschSession = getJSCHSession(ipStr);
        ArrayList<String> strings = new ArrayList<String>();
        strings.add("rm -rf /data/servers/* \n\r");
        strings.add("scp -r root@10.10.2.153:/data0/wg_gmserver/WEB-INF/classes/conf/db1 /data/servers/android/ \n\r");
        strings.add("scp -r root@10.10.2.3:/data0/wg_gmserver/WEB-INF/classes/conf/db1 /data/servers/ios/ \n\r");
        strings.add("scp -r root@10.10.9.103:/data0/wg_gmserver/WEB-INF/classes/conf/db1 /data/servers/h5/ \n\r");
        String s = doExecJSCH(jschSession,strings);
        return s;
    }
}
