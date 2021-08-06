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

