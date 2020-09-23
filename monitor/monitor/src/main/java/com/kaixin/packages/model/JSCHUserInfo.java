package com.kaixin.packages.model;

import com.jcraft.jsch.UserInfo;

public class JSCHUserInfo implements UserInfo {
    private String passphrase = null;

    public JSCHUserInfo(String passphrase) {
        this.passphrase = passphrase;
    }

    public String getPassphrase() {
        return passphrase;
    }

    public String getPassword() {
        return null;
    }

    public boolean promptPassphrase(String s) {
        return true;
    }

    public boolean promptPassword(String s) {
        return true;
    }

    public boolean promptYesNo(String s) {
        return true;
    }

    public void showMessage(String s) {
        System.out.println(s);
    }
}
