package com.lsm.server.args;

/**
 * 类的功能描述:Rpc返回参数 2016/6/21
 * @author lishiming(lishimingfx@feinno.com)
 * @date 2016/6/21 17:02
 * @since V1.0
 */
public class Output<T> {

    private int returnCode;
    private T result;

    public T getResult() {
        return result;
    }

    public void setResult(T result) {
        this.result = result;
    }

    public int getReturnCode() {
        return returnCode;
    }

    public void setReturnCode(int returnCode) {
        this.returnCode = returnCode;
    }
}
