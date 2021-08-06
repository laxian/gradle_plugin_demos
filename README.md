# 自定义Gradle Plugin最简项目

## 创建

参见`plugin` module的[README](https://github.com/laxian/gradle_plugin_demo/blob/master/plugin/README.md)

## 使用

`plugin` module是一个插件实现，发布到了当前目录的repo目录下。
如何使用呢？

创建一个module名叫`app`，目录下创建一个`build.gradle`文件

当前目录创建一个settings.gradle，内容：

```groovy
include ':app', ':plugin'
```

先生成一下插件代码工件：

```shell
./gradlew :plugin:upload
```

然后创建项目的build.gradle，内容：

```groovy
buildscript {
    repositories {
        maven {
            url uri('./repo')
        }
    }

    dependencies {
        classpath "com.example.greeting:hello:1.0.0"
    }
}
```

项目结构就好了

`app/build.gradle`内添加：

```groovy
apply plugin: 'org.example.greeting'
```

## 创建脚本

[create.sh](https://github.com/laxian/gradle_plugin_demo/blob/master/create.sh)

用于在已有项目中，或者新项目中创建插件初始结构
使用方法：

加载脚本
```
source ./create.sh
```

创建buildSrc module

```
create_plugin_module buildSrc
```

创建独立plugin module

```
create_plugin_module myplugin
```

创建使用gradle项目，并使用plugin

```
create_app_module
```
# gradleplugindemo
