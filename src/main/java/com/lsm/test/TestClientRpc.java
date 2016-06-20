package com.lsm.test;

import com.lsm.Entity.User;
import com.lsm.client.RpcProxy;

import java.io.IOException;

/**
 * Created by Administrator on 2016/6/20.
 */
public class TestClientRpc {

    public static void main(String[] args) {
        User user = new User("lishiming","2208911");
        try {
            RpcProxy proxy = RpcProxy.getProxy("127.0.0.1", 5801);
            proxy.invoke(user.getClass(),user);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

}
