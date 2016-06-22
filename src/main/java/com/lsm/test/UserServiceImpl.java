package com.lsm.test;

import com.lsm.Entity.User;
import com.lsm.server.anno.RpcMethod;
import com.lsm.server.anno.RpcService;


@RpcService
public class UserServiceImpl {

    @RpcMethod
    public void use() {
        System.out.println("use is run");
    }

    @RpcMethod
    public String run(User user) {
        return user.toString();
    }
}
