package com.kaixin.packages.model.feishubean;

public class CustomBotReq {
    private String title ;
    private String text ;

    public CustomBotReq() {
    }

    public CustomBotReq(String title, String text) {
        this.title = title;
        this.text = text;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getText() {
        return text;
    }

    public void setText(String text) {
        this.text = text;
    }
}
