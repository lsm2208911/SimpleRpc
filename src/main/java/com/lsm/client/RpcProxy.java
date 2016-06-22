package com.lsm.client;

import com.alibaba.fastjson.JSON;
import com.lsm.server.args.Input;
import com.lsm.server.args.Output;

import java.io.*;
import java.net.Socket;

import static javafx.scene.input.KeyCode.R;

/**
 * 类的功能描述:TODO 2016/6/22
 * @author lishiming(lishimingfx@feinno.com)
 * @date 2016/6/22 10:12
 * @since V1.0
 */
public class RpcProxy {

    private static Socket socket;

    private RpcProxy(String host, int port) throws IOException {
        socket = new Socket(host,port);
    }

    public static RpcProxy getProxy(String host, int port) throws IOException {
        return new RpcProxy(host,port);

    }

    /**
     *
     * @param rClass
     * @param args
     * @param method
     * @return
     * @throws IOException
     */
    public <R> R syncInvoke(Class<R> rClass,Object args,String method) {
        Writer writer = null;
        Reader reader = null;
        R result = null;
        try {
            writer = new OutputStreamWriter(socket.getOutputStream());
            Input input = new Input();
            input.setMethos(method);
            input.setArgs(args);
            String s = JSON.toJSONString(input);
            System.out.println(s);
            writer.write(s);
            writer.write("eof");
            writer.flush();
            InputStream inputStream = socket.getInputStream();
            reader = new InputStreamReader(inputStream);
            char[] chars = new char[1024];
            int len;
            StringBuffer s1 = new StringBuffer();
            String temp;
            int index;
            while((len = reader.read(chars)) != -1){
               temp = new String(chars, 0, len);
                if ((index = temp.indexOf("eof")) != -1){
                    s1.append(temp.substring(0,index));
                    break;
                }

            }
            result = JSON.parseObject(s1.toString(), rClass);
            return result;
        } catch (IOException e) {
            e.printStackTrace();
        }finally {
            try {
                writer.close();
                reader.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        return result;
    }
}
