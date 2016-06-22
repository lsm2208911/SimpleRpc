package com.lsm;


import com.lsm.server.RpcServer;
import com.lsm.server.anno.RpcService;
import org.apache.log4j.BasicConfigurator;
import org.apache.log4j.Logger;

import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.List;

public class RpcServiceBootstrap {

    private static Logger logger = Logger.getLogger(RpcServiceBootstrap.class);

    private static int port;
    private static ServerSocket serverSocket;
    private static Object service;
    private static List<String> methodList;
    private static Socket socket;

    public static void registerChannel(int port1){
        port = port1;
    }


    public static void registerService(Object serviceClass) throws RpcException {
        service = serviceClass;
//        if (iClass.isAnnotationPresent(RpcService.class)){
//            serviceClass = iClass;
//            Method[] methods = iClass.getMethods();
//            for (Method method : methods) {
//                if (method.isAnnotationPresent(RpcMethod.class)){
//                    methodList.add(method.getName());
//                }
//            }
//        }
//        else{
//            throw new RpcException("注册service时出错！");
//        }

    }

    public static void start() throws IOException {
        BasicConfigurator.configure();
        serverSocket = new ServerSocket(port);
        logger.info("开始监听"+port+"端口...");
        socket = serverSocket.accept();
        new Thread(new RpcServer(socket,service)).start();


    }

    public static void stop() throws IOException{
        socket.close();
        serverSocket.close();
        logger.info("停止监听端口");
    }


    public static void setMethodList(List<String> methodList) {
        RpcServiceBootstrap.methodList = methodList;
    }
}
