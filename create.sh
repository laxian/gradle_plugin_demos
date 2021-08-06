#!/usr/bin/env bash

#-----------------------
# 创建插件module，可以是buildSrc，也可以是独立module
# 如果是独立module，会为其生成一个build.gradle
#-----------------------
function create_plugin_module() {

  echo -----------

  if [ -z $1 ]; then
      cat <<-EOF
Usage:
  创建buildSrc：
    create_plugin_module buildSrc [plugin_id]

  创建一个独立Plugin module，名字任意：
    create_plugin_module <your_plugin_module_name> [plugin_id]
EOF
      exit 1
  fi

  PLUGIN_TEMPLATE='''
package org.example.greeting;

import org.gradle.api.Plugin;
import org.gradle.api.Project;

public class GreetingPlugin implements Plugin<Project> {
    public void apply(Project project) {
        //创建一个名为hello的新任务，类型为Greeting(稍后将对此进行定义)
        project.getTasks().create("hello", Greeting.class, (task) -> {
            task.setMessage("Hello");//为新任务设置默认值
            task.setRecipient("World");//为新任务设置默认值
        });
    }
}
'''

    TASK_TAMPLATE='''
package org.example.greeting;

import org.gradle.api.DefaultTask;
import org.gradle.api.tasks.TaskAction;

public class Greeting extends DefaultTask {
    private String message;
    private String recipient;

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public String getRecipient() { return recipient; }
    public void setRecipient(String recipient) { this.recipient = recipient; }

    @TaskAction
    void sayGreeting() {
        //在任务运行时打印配置的问候语
        System.out.printf("%s, %s!", getMessage(), getRecipient());
    }
}
'''

      BUILD_TEMPLATE="""
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
"""

    # 创建项目目录
    PROJ=$1
    PLUGIN_ID=${2:-'org.example.greeting'}
    PACKAGE_DIR=`echo $PLUGIN_ID | tr '.' '/'`

    echo PLUGIN ID IS : $PLUGIN_ID
    PLUGIN_IMPL=${PLUGIN_TEMPLATE//org.example.greeting/$PLUGIN_ID}
    TASK_IMPL=${TASK_TAMPLATE//org.example.greeting/$PLUGIN_ID}
    echo $PLUGIN_IMPL

    # 创建Plugin
    mkdir -p $PROJ/src/main/java/$PACKAGE_DIR
    echo $PLUGIN_IMPL \
    > $PROJ/src/main/java/$PACKAGE_DIR/GreetingPlugin.java

    # 创建一个任务
    echo $TASK_IMPL \
    > $PROJ/src/main/java/$PACKAGE_DIR/Greeting.java

    # build.gradle 应用插件

    if [[ $PROJ == 'buildSrc' ]]; then
      echo 'buildSrc module'
      echo "apply plugin: $PLUGIN_ID.GreetingPlugin" > build.gradle
    else
      echo 'standolone module'
      echo $BUILD_TEMPLATE > $PROJ/build.gradle
    fi

    mkdir -p $PROJ/src/main/resources/META-INF/gradle-plugins
    echo "implementation-class=$PLUGIN_ID.GreetingPlugin" \
    > $PROJ/src/main/resources/META-INF/gradle-plugins/$PLUGIN_ID.properties

    # 执行任务
    type gradle >/dev/null 2>&1 && gradle hello || echo 'plugin创建完成，请部署gradle环境后运行：gradle hello或./gradlew hello'

    unset PLUGIN_IMPL TASK_IMPL BUILD_TEMPLATE TASK_TAMPLATE PROJ PLUGIN_ID
}

# 创建使用代码
function create_app_module() {
    echo "include 'app', 'plugin'" > settings.gradle
    echo """
    buildscript {
        repositories {
            maven {
                url uri('./repo')
            }
        }

        dependencies {
            classpath 'com.example.greeting:hello:1.0.0'
        }
    }
""" \
> build.gradle
mkdir -p app
echo "apply plugin: '$PLUGIN_ID'" > app/build.gradle
}


# 创建buildSrc module
create_plugin_module buildSrc
gradle hello

#创建独立plugin module
create_plugin_module myplugin
#编译并发布
gradle -p myplugin upload

# 创建使用demo文件
create_app_module
gradle app:hello


