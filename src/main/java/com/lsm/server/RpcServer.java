package com.lsm.server;

import com.alibaba.fastjson.JSON;
import com.lsm.Entity.User;
import com.lsm.server.args.Input;
import com.lsm.server.args.Output;
import org.apache.log4j.Logger;

import java.io.*;
import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.net.Socket;

import static com.alibaba.fastjson.JSON.toJSONString;

/**
 * Created by Administrator on 2016/6/21.
 */
public class RpcServer implements Runnable{

    private static Logger logger = Logger.getLogger(RpcServer.class);

    private Socket socket;
    private Object serviceClass;

    public RpcServer(Socket socket, Object serviceClass) {
        this.socket = socket;
        this.serviceClass = serviceClass;
    }

    public void run() {
        Reader reader = null;
        Writer writer = null;
        try {
            reader = new BufferedReader(new InputStreamReader(socket.getInputStream()));
            char chars[] = new char[1024];
            int len;
            String temp;
            int index;
            StringBuilder sb = new StringBuilder();
            while ((len=reader.read(chars)) != -1) {
                temp = new String(chars,0,len);
                if ((index = temp.indexOf("eof")) != -1){
                    sb.append(temp.substring(0,index));
                    break;
                }
            }
            Input input = JSON.parseObject(sb.toString(), Input.class);
            String argString = JSON.toJSONString(input.getArgs());
            String iMethod = input.getMethos();
            String result = "";
            Method[] declaredMethods = serviceClass.getClass().getDeclaredMethods();
            for (Method method : declaredMethods) {
                if (iMethod.equals(method.getName())) {
                    Class<?>[] parameterTypes = method.getParameterTypes();
                    Object o = JSON.parseObject(argString, parameterTypes[0]);
                    Object invoke = method.invoke(serviceClass,o);
                    result = JSON.toJSONString(invoke);
                    break;
                }
            }
            writer = new OutputStreamWriter(socket.getOutputStream());
            writer.write(result);
            writer.write("eof");
            writer.flush();
        } catch (IOException e) {
            e.printStackTrace();
        } catch (InvocationTargetException e) {
            e.printStackTrace();
            logger.error("执行方法时出错");
        } catch (IllegalAccessException e) {
            e.printStackTrace();
            logger.error("执行方法时出错");
        } finally {
            try {
                reader.close();
                writer.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
//
    }
}
