import com.alibaba.fastjson.JSONObject;
import com.kaixin.packages.model.esresult.EsResultBean;
import org.junit.Test;

import java.io.IOException;

import static com.kaixin.packages.util.AllUtil.*;

public class UnitTest {


    @Test
    public void test1() throws IOException {
        String exec = "ssh -o StrictHostKeyChecking=no -i C:\\Users\\89264\\Desktop\\id_rsa_ios root@106.52.79.53 \"ls\"";
        String s = doExec(exec);
        System.out.println(s);
    }

    @Test
    public void test() {
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

}
