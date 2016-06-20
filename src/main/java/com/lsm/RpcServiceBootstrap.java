package com.lsm;


import com.alibaba.fastjson.JSON;
import com.lsm.Entity.User;
import org.apache.log4j.BasicConfigurator;
import org.apache.log4j.Logger;

import java.io.*;
import java.net.ServerSocket;
import java.net.Socket;

public class RpcServiceBootstrap {

    private static Logger logger = Logger.getLogger(RpcServiceBootstrap.class);

    private static int port;
    private static ServerSocket serverSocket;

    public static void registerChannel(int port1){
        port = port1;
    }


    public static void registerService(Object service){
        //TODO
    }

    public static void start() throws IOException {
        BasicConfigurator.configure();
        serverSocket = new ServerSocket(port);
        logger.info("开始监听"+port+"端口...");
        Socket socket = serverSocket.accept();
        InputStream inputStream = socket.getInputStream();
//        Reader reader = new BufferedReader(new InputStreamReader(inputStream));
        byte chars[] = new byte[64];
        int len;
        StringBuilder sb = new StringBuilder();
        while ((len=inputStream.read(chars)) != -1) {
            sb.append(new String(chars, 0, len));
        }
        System.out.println(sb.toString());
        User user = JSON.parseObject(sb.toString(), User.class);
        logger.info(user.toString());
        inputStream.close();
        socket.close();

    }

    public static void stop() throws IOException{
        serverSocket.close();
        logger.info("停止监听端口");
    }


}
