package com.lsm.test;

import com.lsm.server.anno.RpcMethod;
import com.lsm.server.anno.RpcService;

/**
 * Created by Administrator on 2016/6/21.
 */

@RpcService
public interface UserService {

    @RpcMethod
    public void use();

    @RpcMethod
    public String run();
}
