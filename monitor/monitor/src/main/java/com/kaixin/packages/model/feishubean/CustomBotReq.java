package com.kaixin.packages.model.feishubean;

public class CustomBotReq {
    private String msg_type ;
    private Content content ;

    public CustomBotReq() {
    }

    public CustomBotReq(String msg_type,Content content) {
        this.msg_type = msg_type;
        this.content = content;
    }

    public String getMsg_type() {
        return msg_type;
    }

    public void setMsg_type(String msg_type) {
        this.msg_type = msg_type;
    }

    public Content getContent() {
        return content;
    }

    public void setContent(Content content) {
        this.content = content;
    }
}
