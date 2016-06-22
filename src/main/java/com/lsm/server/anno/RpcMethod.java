package com.lsm.server.anno;

import java.lang.annotation.*;

/**
 * 类的功能描述:用于扫描方法的注解类 2016/6/21
 * @author lishiming(lishimingfx@feinno.com)
 * @date 2016/6/21 17:38
 * @since V1.0
 */

@Documented
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
public @interface RpcMethod {
    String value() default "";
}
