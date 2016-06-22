package com.lsm.server.args;

import static javafx.scene.input.KeyCode.T;

/**
 * 类的功能描述:Rpc入参 2016/6/21
 * @author lishiming(lishimingfx@feinno.com)
 * @date 2016/6/21 17:03
 * @since V1.0
 */
public class Input {

    private String methos;

    private Object args;

    public Object getArgs() {
        return args;
    }

    public void setArgs(Object args) {
        this.args = args;
    }

    public String getMethos() {
        return methos;
    }

    public void setMethos(String methos) {
        this.methos = methos;
    }
}
