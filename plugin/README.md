# 独立项目创建Gradle Plugin

> 注意，当前demo非buildSrc方式

## 最简必要步骤

1. 文件目录

下面的目录是最简的目录了，连gradle wrapper都省略了
```shell
.
|____build.gradle
|____src
| |____main
| | |____resources
| | | |____META-INF
| | | | |____gradle-plugins
| | | | | |____org.example.greeting.properties
| | |____java
| | | |____org
| | | | |____example
| | | | | |____greeting
| | | | | | |____GreetingPlugin.java
| | | | | | |____Greeting.java
```

主要有3部分：
- build.gradle

```groovy
apply plugin: 'groovy'
apply plugin: 'maven'

repositories {
  mavenCentral()
}

dependencies {
  compile gradleApi()
  compile localGroovy()
}

//设置maven deployer
uploadArchives {
  repositories {
    mavenDeployer {
      //设置插件的GAV参数
      pom.groupId = 'com.example.greeting'
      pom.artifactId = 'hello'
      pom.version = '1.0.0'
      //文件发布到下面目录
      repository(url: uri('../repo'))
    }
  }
}
```

- properties

文件名格式<plugin-id>.properties
```properties
implementation-class=org.example.greeting.GreetingPlugin
```

- src

插件实现源码

