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
        System.out.printf("%s, %s!\n", getMessage(), getRecipient()); 
    }
}
