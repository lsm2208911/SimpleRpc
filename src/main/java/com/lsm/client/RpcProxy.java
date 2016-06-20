package com.lsm.client;

import com.alibaba.fastjson.JSON;

import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.net.Socket;

import static javafx.scene.input.KeyCode.T;

/**
 * Created by Administrator on 2016/6/20.
 */
public class RpcProxy {

    private static Socket socket;
    private String host;
    private int port;

    public RpcProxy(String host,int port) throws IOException {
        this.port = port;
        this.host = host;
        socket = new Socket(host,port);
    }

    public static RpcProxy getProxy(String host, int port) throws IOException {
        return new RpcProxy(host,port);

    }

    public void invoke(Class tClass ,Object o) throws IOException {
        Writer writer = new OutputStreamWriter(socket.getOutputStream());
        String s = JSON.toJSONString(o);
        System.out.println(s);
        writer.write(s);
        writer.flush();
        writer.close();
        socket.close();
    }
}
