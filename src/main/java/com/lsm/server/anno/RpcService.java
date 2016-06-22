package com.lsm.server.anno;

import java.lang.annotation.*;

/**
 * 类的功能描述:用于扫描service类的注解类 2016/6/21
 * @author lishiming(lishimingfx@feinno.com)
 * @date 2016/6/21 17:39
 * @since V1.0
 */
@Inherited
@Documented
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.TYPE)
public @interface RpcService {
    String value() default "";
}
