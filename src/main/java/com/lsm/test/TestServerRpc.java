package com.lsm.test;

import com.lsm.RpcServiceBootstrap;

import java.io.IOException;

/**
 * Created by Administrator on 2016/6/20.
 */
public class TestServerRpc {
    public static void main(String[] args) {
        try {
            RpcServiceBootstrap.registerChannel(5801);
            RpcServiceBootstrap.start();

        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
